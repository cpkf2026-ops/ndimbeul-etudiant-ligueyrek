"""
Enrichissement des fiches d'établissements sans site officiel (commande
`python manage.py enrichir_fiches`) : une description tirée de pages web qui parlent
vraiment de l'établissement, et des images candidates (photo, logo).

Rien n'est enregistré directement : la commande écrit des PROPOSITIONS dans un fichier
JSON, relues (en particulier les images, qu'aucun code ne sait vérifier) avant d'être
appliquées avec `--appliquer`. Une description n'est proposée que si chacune de ses
phrases s'appuie sur une page trouvée (contrôles de services/texte.py).
"""
import hashlib
import json
import logging
import re
from pathlib import Path

import httpx
from django.conf import settings

from services import llm_service, tavily_service, texte
from services.cache import normaliser_texte

from . import fiabilite, recherche_web
from .models import Universite
from .sites_officiels import identifiants

logger = logging.getLogger(__name__)

FICHIER_PROPOSITIONS = Path(settings.BASE_DIR) / 'logs' / 'fiches_propositions.json'
DOSSIER_LOGOS = Path(settings.BASE_DIR).parent / 'backend' / 'storage' / 'app' / 'public' / 'logos'
NB_IMAGES_CANDIDATES = 2
MOTS_UTILES = ('formation', 'formations', 'diplome', 'diplomes', 'bts', 'licence', 'master', 'agree',
               'fonde', 'cree', 'situe', 'ecole', 'institut', 'etudiants', 'filieres', 'metiers')

_PROMPT = (
    "Tu rédiges la fiche d'un établissement d'enseignement au Sénégal pour une application "
    "d'orientation. À partir UNIQUEMENT des extraits fournis, écris 2 ou 3 phrases factuelles "
    "qui présentent l'établissement : ce qu'il propose, où il se trouve, son statut si connu. "
    "N'ajoute aucun fait, chiffre ou date absent des extraits. Réponds seulement avec les phrases."
)


def _sans_parentheses(nom):
    return re.sub(r'\(.*?\)', '', nom).strip()


def pages_pertinentes(nom, resultats):
    """Pages qui parlent vraiment de l'établissement : un de ses identifiants dans le titre,
    ou l'essentiel de son nom dans le texte. Réseaux sociaux et annuaires exclus."""
    ids = identifiants(nom)
    retenues = []
    for r in resultats:
        hote = fiabilite.domaine(r['url'])
        if any(hote == d or hote.endswith('.' + d) for d in fiabilite.domaines_bloques()):
            continue
        titre = normaliser_texte(r['titre'])
        if any(i in titre.split() or (len(i) > 4 and i in titre) for i in ids) or texte.present_dans(
            _sans_parentheses(nom), r['contenu'], seuil=0.8,
        ):
            retenues.append(r)
    return retenues


def rediger_description(nom, pages):
    """2-3 phrases sourcées, ou None. Modèle local d'abord, puis extraction par règles."""
    extraits = [texte.extrait_pertinent(p['contenu'], list(identifiants(nom)) + list(MOTS_UTILES), 500)
                for p in pages[:3]]
    source = ' '.join(extraits)
    if len(source) < 60:
        return None
    try:
        proposition = llm_service.generer(
            [{'role': 'system', 'content': _PROMPT},
             {'role': 'user', 'content': f"ÉTABLISSEMENT : {nom}\nEXTRAITS :\n" + '\n'.join(extraits)}],
            modele=llm_service.modele_rapide(), temperature=0.1, num_predict=160, timeout=180,
        )
    except llm_service.LLMIndisponibleError:
        proposition = ''
    sourcee = texte.phrases_sourcees(proposition, source)
    if sourcee and not texte.chiffres_inventes(sourcee, source):
        return texte.resume_court(sourcee, max_phrases=3, max_caracteres=450)
    # Repli : les phrases utiles des pages, telles quelles.
    return texte.resume_court(extraits[0], max_phrases=3, max_caracteres=450) if len(extraits[0]) >= 60 else None


def images_candidates(pages, images_tavily):
    """Image de partage (og:image) des pages pertinentes, puis images Tavily."""
    candidates = []
    for page in pages[:2]:
        image = recherche_web.extraire_metadonnees_article(page['url']).get('image')
        if image and image not in candidates:
            candidates.append(image)
    for image in images_tavily:
        if image and image not in candidates:
            candidates.append(image)
    return candidates[:NB_IMAGES_CANDIDATES]


def collecter(universite):
    images = []
    try:
        resultats = tavily_service.rechercher(
            f'{_sans_parentheses(universite.nom)} Sénégal école formation', module='fiches',
            max_results=6, exclude_domains=fiabilite.domaines_bloques(), timeout=20, images=images,
        )
    except tavily_service.TavilyIndisponibleError as exc:
        return {'id': universite.id, 'nom': universite.nom, 'erreur': str(exc)}
    pages = pages_pertinentes(universite.nom, resultats)
    return {
        'id': universite.id,
        'nom': universite.nom,
        'description_actuelle': universite.description,
        'description_proposee': rediger_description(universite.nom, pages) if pages else None,
        'sources': [p['url'] for p in pages[:3]],
        'images': images_candidates(pages, images),
    }


def telecharger_image(url, nom_fichier_base):
    """Télécharge l'image retenue dans storage/app/public/logos (servie par Laravel) et
    retourne son chemin « /storage/logos/... », ou None si ce n'est pas une image."""
    try:
        reponse = httpx.get(url, headers=recherche_web.EN_TETES, timeout=15, follow_redirects=True)
        reponse.raise_for_status()
    except httpx.HTTPError as exc:
        logger.info('Image injoignable %s : %s', url, exc)
        return None
    type_contenu = reponse.headers.get('content-type', '').split(';')[0].strip()
    extension = {'image/png': 'png', 'image/jpeg': 'jpg', 'image/jpg': 'jpg',
                 'image/webp': 'webp', 'image/gif': 'gif'}.get(type_contenu)
    if not extension or len(reponse.content) < 2000:
        return None
    nom = f"{nom_fichier_base}-{hashlib.sha256(url.encode()).hexdigest()[:8]}.{extension}"
    DOSSIER_LOGOS.mkdir(parents=True, exist_ok=True)
    (DOSSIER_LOGOS / nom).write_bytes(reponse.content)
    return f'/storage/logos/{nom}'


def appliquer(decisions):
    """`decisions` : [{'id', 'description'?, 'image'?}] relues. Retourne le nombre de fiches modifiées."""
    modifiees = 0
    for decision in decisions:
        universite = Universite.objects.filter(id=decision['id']).first()
        if universite is None:
            continue
        champs = []
        if decision.get('description'):
            universite.description = decision['description']
            champs.append('description')
        if decision.get('image'):
            base = re.sub(r'[^a-z0-9]+', '-', normaliser_texte(universite.nom))[:40].strip('-')
            chemin = telecharger_image(decision['image'], base)
            if chemin:
                universite.image_url = chemin
                champs.append('image_url')
        if champs:
            universite.save(update_fields=champs + ['updated_at'])
            modifiees += 1
    return modifiees


def ecrire_propositions(propositions):
    FICHIER_PROPOSITIONS.write_text(json.dumps(propositions, ensure_ascii=False, indent=1), encoding='utf-8')
