"""
Assistance au back-office : l'administrateur tape un nom d'établissement ou colle un lien
d'actualité / d'offre, le service IA va chercher les informations publiques et renvoie une
PROPOSITION que l'administrateur relit, corrige puis enregistre (rien n'est publié ici).

Règle de toute l'application : aucune donnée inventée. Les textes proposés sont des extraits
des pages trouvées (pas de rédaction par le modèle), un champ introuvable reste vide
(statut, lieu, date limite...) et chaque proposition indique ses sources.
"""
import html
import logging
import re
import urllib.parse
from datetime import datetime

import httpx
from bs4 import BeautifulSoup
from django.utils import timezone

from services import tavily_service, texte
from services.cache import normaliser_texte

from . import commun, fiabilite, lieux, recherche_web
from .fiches_etablissements import MOTS_UTILES, _sans_parentheses, pages_pertinentes
from .models import Actualite, OffreEmploi, Universite
from .pipeline import _tokens_significatifs
from .sites_officiels import adresse_candidate, identifiants, site_confirme

logger = logging.getLogger(__name__)

MODULE_TAVILY = 'back_office'  # crédits « interactifs » (hors quota de la veille)
PRIVE = re.compile(r"\b(établissement|institut|école|université|institution)\b[^.]{0,50}\bprivée?\b", re.I)
PUBLIC = re.compile(r"\b(établissement|structure|institution|université|école)\s+publique?\b", re.I)
DOMAINES_PUBLICS = ('ucad.sn', 'ugb.sn', 'univ-thies.sn', 'uadb.edu.sn', 'univ-zig.sn', 'uam.edu.sn', 'gouv.sn',
                    'ussein.edu.sn', 'unchk.edu.sn')


# --- Établissements -----------------------------------------------------------------

def etablissements_proches(nom, limite=5):
    """Établissements déjà au catalogue dont le nom ressemble (évite les doublons)."""
    t = _tokens_significatifs(_sans_parentheses(nom))
    sigles = {normaliser_texte(s) for s in re.findall(r'\b[A-Z][A-Z0-9]{2,}\b', nom)}
    proches = []
    for u in Universite.objects.filter(statut_actif=True, deleted_at__isnull=True):
        tu = _tokens_significatifs(_sans_parentheses(u.nom))
        score = len(t & tu) / max(1, min(len(t), len(tu))) if t and tu else 0
        sigles_u = {normaliser_texte(s) for s in re.findall(r'\b[A-Z][A-Z0-9]{2,}\b', u.nom)}
        if sigles & (sigles_u | {normaliser_texte(u.code_unique)}):
            score = max(score, 0.9)
        if score >= 0.7:
            proches.append((score, {'id': u.id, 'nom': u.nom, 'commune': u.commune, 'region': u.region}))
    return [p for _, p in sorted(proches, key=lambda x: -x[0])[:limite]]


def _nettoyer_extrait(extrait, nom):
    """Retire titres Markdown, fils d'Ariane et menus que Tavily laisse dans le contenu, puis
    commence à la première phrase qui nomme l'établissement."""
    t = re.sub(r'#+\s*', ' ', extrait or '')
    t = re.sub(r'(\b[\w’\'-]+(?:\s[\w’\'-]+){0,4}\s/\s){1,}', ' ', t)  # « Accueil / Écoles / ... »
    t = re.split(r'\d+\s+commentaires?|\[\.\.\.\]|\[…\]', t)[0]  # avis des lecteurs : hors fiche
    t = ' '.join(t.split()).strip(' …')
    phrases = re.split(r'(?<=[.!?])\s+', t)
    ids = [i for i in identifiants(nom) if len(i) > 2]
    # Nom fait de mots génériques (« Institut supérieur de management… ») : pas d'identifiant,
    # on repère alors le début du nom lui-même.
    debut_nom = ' '.join(normaliser_texte(_sans_parentheses(nom)).split()[:4])

    def position(phrase):
        """Position (dans le texte ORIGINAL) du premier identifiant cité comme MOT ENTIER
        (« ism » ≠ « tourisme ») ou du début du nom de l'établissement."""
        cibles = [i for i in ids if re.search(r'\b' + re.escape(i) + r'\b', normaliser_texte(phrase))]
        if len(debut_nom) > 10 and debut_nom in normaliser_texte(phrase):
            cibles.append(debut_nom)
        # La normalisation (accents, apostrophes) décale les positions : on cherche donc le
        # premier indice du texte original à partir duquel le texte normalisé commence par la cible.
        for j in range(len(phrase)):
            if (j == 0 or not phrase[j - 1].isalnum()) and any(
                    normaliser_texte(phrase[j:j + len(c) + 12]).startswith(c) for c in cibles):
                return j
        return None

    for k, phrase in enumerate(phrases):
        pos = position(phrase)
        if pos is not None:
            # La phrase peut commencer par un reste de menu : on la coupe au premier identifiant.
            phrases = [phrase[pos:] if pos > 40 else phrase] + phrases[k + 1:]
            break
    return ' '.join(phrases).strip()


def _statut(extraits, site):
    hote = urllib.parse.urlparse(site or '').hostname or ''
    if any(hote == d or hote.endswith('.' + d) for d in DOMAINES_PUBLICS):
        return 'public', f'site officiel sous un domaine public ({hote})'
    prive, public = PRIVE.search(extraits), PUBLIC.search(extraits)
    if prive and not public:
        return 'prive', f'« {prive.group(0)} »'
    if public and not prive:
        return 'public', f'« {public.group(0)} »'
    return None, 'aucune source ne le précise clairement : à vérifier (ANAQ-Sup, MESRI)'


def rechercher_etablissement(nom):
    """Proposition de fiche pour `nom`, ou erreur si la recherche web est impossible."""
    nom = ' '.join((nom or '').split())
    proposition = {'nom': nom, 'deja_present': etablissements_proches(nom), 'site_web_officiel': None,
                   'description': None, 'type': None, 'preuve_type': None, 'region': None, 'commune': None,
                   'images': [], 'sources': []}
    images_tavily = []
    resultats = tavily_service.rechercher(
        f'{_sans_parentheses(nom)} Sénégal', module=MODULE_TAVILY, max_results=8,
        exclude_domains=fiabilite.domaines_bloques(), timeout=25, images=images_tavily,
    )
    pages = pages_pertinentes(nom, resultats)
    proposition['sources'] = [p['url'] for p in pages[:4]]

    site = adresse_candidate(nom, resultats)
    if site and site_confirme(nom, site):
        proposition['site_web_officiel'] = site

    mots = list(identifiants(nom)) + list(MOTS_UTILES)
    extraits = [_nettoyer_extrait(texte.extrait_pertinent(p['contenu'], mots, 900), nom) for p in pages[:3]]
    tout = ' '.join(extraits)
    meilleur = next((e for e in extraits if len(e) >= 60), None)
    if meilleur:
        proposition['description'] = texte.resume_court(meilleur, max_phrases=3, max_caracteres=450)
    proposition['type'], proposition['preuve_type'] = _statut(tout, proposition['site_web_officiel'])
    proposition['region'], proposition['commune'] = lieux.localiser(tout)

    images = []
    if proposition['site_web_officiel']:
        logo = recherche_web.extraire_logo(proposition['site_web_officiel'])
        image_site = recherche_web.extraire_metadonnees_article(proposition['site_web_officiel']).get('image')
        images += [i for i in (logo, image_site) if i]
    images += images_tavily
    proposition['images'] = list(dict.fromkeys(images))[:4]
    return proposition


# --- Actualités et offres (lien collé par l'administrateur) ----------------------------

MOIS = {'janvier': 1, 'fevrier': 2, 'mars': 3, 'avril': 4, 'mai': 5, 'juin': 6, 'juillet': 7, 'aout': 8,
        'septembre': 9, 'octobre': 10, 'novembre': 11, 'decembre': 12}
DATE_LIMITE = re.compile(r"(date limite|au plus tard|avant le|clôture|cloture|deadline)[^0-9]{0,40}"
                         r"(\d{1,2})(?:er)?[\s/.-]+([a-zéû]+|\d{1,2})[\s/.-]+(\d{4})", re.I)


def _date_limite(contenu):
    m = DATE_LIMITE.search(contenu or '')
    if not m:
        return None
    jour, mois, annee = int(m.group(2)), m.group(3), int(m.group(4))
    mois = int(mois) if mois.isdigit() else MOIS.get(normaliser_texte(mois))
    try:
        return datetime(annee, mois, jour).date().isoformat() if mois else None
    except ValueError:
        return None


def analyser_lien(url, genre):
    """Lit la page collée : titre, résumé, date, image, et pour une offre organisme,
    lieu et date limite. `genre` = 'actualite' ou 'offre'."""
    url = (url or '').strip()
    if not re.match(r'^https?://', url):
        raise ValueError('Lien invalide : il doit commencer par http:// ou https://')
    deja = (Actualite if genre == 'actualite' else OffreEmploi).objects.filter(source_url=url).exists()
    try:
        reponse = httpx.get(url, headers=recherche_web.EN_TETES, timeout=15, follow_redirects=True)
        reponse.raise_for_status()
    except httpx.HTTPError as exc:
        raise ValueError(f'Page injoignable : {exc}') from exc
    soup = BeautifulSoup(reponse.text, 'html.parser')

    def meta(*noms):
        for n in noms:
            b = soup.find('meta', attrs={'property': n}) or soup.find('meta', attrs={'name': n})
            if b and b.get('content'):
                return ' '.join(b['content'].split())
        return None

    titre = meta('og:title', 'twitter:title') or (soup.title.string.strip() if soup.title and soup.title.string else '')
    # « Senjob.com - Commercial terrain », « Titre | MESRI SÉNÉGAL » : on retire le nom du site.
    site = normaliser_texte((urllib.parse.urlparse(url).hostname or '').removeprefix('www.').split('.')[0])
    morceaux = [m.strip() for m in re.split(r'\s+[|–-]\s+', titre) if m.strip()]
    utiles = [m for m in morceaux if site not in normaliser_texte(m).replace(' ', '') and
              normaliser_texte(m) != normaliser_texte(meta('og:site_name') or '')]
    titre = ' - '.join(utiles) if utiles else titre
    description = meta('og:description', 'description', 'twitter:description')
    if description:  # certaines descriptions contiennent du HTML (« <br /> »)
        description = ' '.join(re.sub(r'<[^>]+>', ' ', html.unescape(description)).split())
    infos = recherche_web.extraire_metadonnees_article(url)
    corps = recherche_web.extraire_texte_page(url, max_chars=8000)
    # Une description qui ne fait que répéter le titre n'apporte rien : on prend le texte de la page.
    if not description or normaliser_texte(description) == normaliser_texte(titre) or len(description) < 60:
        description = None
    # Paragraphes du corps de l'article (balises <p> de vrai texte), sans menus ni bandeaux.
    paragraphes = [' '.join(p.get_text(' ').split()) for p in (soup.select('article p') or soup.select('main p')
                                                                  or soup.find_all('p'))]
    paragraphes = [p for p in paragraphes if len(p) >= 80 and 'cookie' not in p.lower()]
    texte_article = ' '.join(paragraphes) or corps
    # Les pages ont souvent d'autres articles en colonne : on garde les phrases liées au titre.
    mots_titre = list(_tokens_significatifs(titre))
    extrait = ''
    if mots_titre:
        for source in (texte_article, corps):
            # Vraies phrases seulement (ni menus ni bandeaux « | ») qui reprennent au moins
            # 2 mots du titre : sinon c'est un autre article de la page.
            phrases = [p.strip() for p in re.split(r'(?<=[.!?])\s+', source.replace(titre, ' '))]
            retenues = [p for p in phrases if 60 <= len(p) <= 400 and '|' not in p
                        and len(_tokens_significatifs(p) & set(mots_titre)) >= min(2, len(mots_titre))]
            if retenues:
                extrait = ' '.join(retenues[:3])
                break
    # Rien de lié au titre (contenu chargé en JavaScript, page de liste...) : résumé laissé vide,
    # l'administrateur le rédige plutôt que de publier un texte d'une autre actualité.
    resume = description or (texte.resume_court(extrait, max_phrases=3, max_caracteres=450) if extrait else None)
    proposition = {
        'source_url': str(reponse.url), 'deja_present': deja, 'titre': titre[:255], 'resume': resume,
        'image': infos.get('image'),
        'date_publication': infos['date_publication'].isoformat() if infos.get('date_publication') else None,
        'source_nom': fiabilite.nom_source_lisible(url), 'fiabilite': fiabilite.niveau_fiabilite(url),
    }
    if genre == 'offre':
        # Type deviné sur le titre et la description seulement (les menus du site citent « stage »...).
        bas = normaliser_texte(f'{titre} {resume or ""}')
        genre_offre = next((g for g, mots in (('stage', ('stage', 'stagiaire')), ('alternance', ('alternance',)),
                                              ('concours', ('concours',)), ('bourse', ('bourse',)),
                                              ('formation', ('formation',))) if any(m in bas for m in mots)), 'emploi')
        proposition.update({
            'type': genre_offre, 'entreprise': meta('og:site_name'),
            'region': lieux.localiser(corps[:3000])[0], 'date_limite': _date_limite(corps),
        })
    else:
        bas = normaliser_texte(titre)
        proposition['categorie'] = next((c for c, mots in (('bourse', ('bourse',)), ('concours', ('concours',)),
                                                            ('formation', ('formation', 'inscription')),
                                                            ('evenement', ('forum', 'salon', 'ceremonie', 'journee')))
                                         if any(m in bas for m in mots)), 'general')
    return proposition


def empreinte(url, titre):
    """Même empreinte anti-doublon que la veille IA (index unique en base)."""
    return commun.hash_dedoublonnage(url, titre)


# --- Publication (après relecture par l'administrateur) ---------------------------------
# Même enregistrement que la veille IA (empreinte anti-doublon, image stockée localement,
# nom et fiabilité de la source) : ce qu'ajoute un administrateur s'affiche exactement
# comme ce qu'a trouvé l'IA. Seule différence visible : la source « administration »
# quand le lien n'est pas une source reconnue.
FIABILITE_ADMIN = 'administration'


class PublicationRefusee(Exception):
    """Doublon ou donnée manquante : message destiné à l'administrateur."""


def _texte(donnees, cle, maxi=None):
    valeur = ' '.join(str(donnees.get(cle) or '').split())
    return (valeur[:maxi] if maxi else valeur) or None


def _code_unique(nom):
    sigles = re.findall(r'\(([^)]{2,25})\)', nom) or re.findall(r'\b[A-Z][A-Z0-9]{2,}\b', nom)
    base = sigles[-1] if sigles else ' '.join(w[0] for w in _sans_parentheses(nom).split() if len(w) > 2)
    base = re.sub(r'[^A-Z0-9]+', '-', normaliser_texte(base).upper()).strip('-')[:30] or 'ETAB'
    code, k = base, 2
    while Universite.objects.filter(code_unique=code).exists():
        code, k = f'{base}-{k}', k + 1
    return code


def publier_etablissement(donnees):
    from .fiches_etablissements import telecharger_image

    nom = _texte(donnees, 'nom', 255)
    if not nom:
        raise PublicationRefusee("Le nom de l'établissement est obligatoire.")
    if Universite.objects.filter(statut_actif=True, deleted_at__isnull=True, nom__iexact=nom).exists():
        raise PublicationRefusee('Cet établissement est déjà dans le catalogue.')
    code = _code_unique(nom)
    image = _texte(donnees, 'image')
    image_locale = telecharger_image(image, re.sub(r'[^a-z0-9]+', '-', normaliser_texte(nom))[:40] + '-' + code.lower()) if image else None
    type_ = donnees.get('type') if donnees.get('type') in ('public', 'prive') else None
    sources = [s for s in (donnees.get('sources') or []) if isinstance(s, str)]
    u = Universite.objects.create(
        nom=nom, code_unique=code, type=type_, region=_texte(donnees, 'region', 255),
        commune=_texte(donnees, 'commune', 255), adresse=_texte(donnees, 'adresse', 255),
        site_web_officiel=_texte(donnees, 'site_web_officiel', 255), description=_texte(donnees, 'description'),
        image_url=image_locale, source="Ajouté par l'administration (recherche web)",
        source_infos=(_texte(donnees, 'site_web_officiel') or (sources[0] if sources else None)),
        date_verification=timezone.localdate(), statut_actif=True,
    )
    return {'id': u.id, 'nom': u.nom, 'code_unique': u.code_unique, 'image_url': u.image_url}


def publier_actualite(donnees):
    titre, url = _texte(donnees, 'titre', 255), _texte(donnees, 'source_url', 255)
    contenu = _texte(donnees, 'resume')
    if not titre or not contenu:
        raise PublicationRefusee('Le titre et le résumé sont obligatoires.')
    categorie = donnees.get('categorie') if donnees.get('categorie') in dict(Actualite.CATEGORIE_CHOICES) else 'general'
    empreinte_ = empreinte(url or titre, titre)
    if Actualite.objects.filter(hash_dedoublonnage=empreinte_).exists() or (url and Actualite.objects.filter(source_url=url).exists()):
        raise PublicationRefusee('Cette actualité est déjà publiée.')
    date = commun.parser_date_tavily(donnees.get('date_publication')) or timezone.now()
    a = Actualite.objects.create(
        hash_dedoublonnage=empreinte_, titre=titre, contenu=contenu, categorie=categorie, source_url=url,
        image_url=recherche_web.telecharger_image_locale(_texte(donnees, 'image')) if donnees.get('image') else None,
        date_publication=date, source_nom=(fiabilite.nom_source_lisible(url) if url else 'Administration'),
        fiabilite=(fiabilite.niveau_fiabilite(url) if url else None) or FIABILITE_ADMIN, statut='publie',
    )
    return {'id': a.id, 'titre': a.titre}


def publier_offre(donnees):
    intitule, url = _texte(donnees, 'titre', 255), _texte(donnees, 'source_url', 255)
    if not intitule or not url:
        raise PublicationRefusee("L'intitulé et le lien de candidature sont obligatoires.")
    type_ = donnees.get('type') if donnees.get('type') in dict(OffreEmploi.TYPE_CHOICES) else 'emploi'
    empreinte_ = empreinte(url, intitule)
    if OffreEmploi.objects.filter(hash_dedoublonnage=empreinte_).exists() or OffreEmploi.objects.filter(source_url=url, intitule=intitule).exists():
        raise PublicationRefusee('Cette offre est déjà publiée.')
    date_limite = donnees.get('date_limite') or None
    maintenant = timezone.now()
    o = OffreEmploi.objects.create(
        hash_dedoublonnage=empreinte_, intitule=intitule, entreprise=_texte(donnees, 'entreprise', 255) or 'Non précisé',
        type=type_, region=_texte(donnees, 'region', 255), description=_texte(donnees, 'resume'),
        resume=texte.resume_court(_texte(donnees, 'resume') or '', max_phrases=2) or None, source_url=url,
        source=fiabilite.nom_source_lisible(url), fiabilite=fiabilite.niveau_fiabilite(url) or FIABILITE_ADMIN,
        date_publication=(commun.parser_date_tavily(donnees.get('date_publication')) or maintenant).date(),
        date_limite=date_limite, statut='active', date_indexation=maintenant, date_collecte=maintenant,
    )
    return {'id': o.id, 'intitule': o.intitule}
