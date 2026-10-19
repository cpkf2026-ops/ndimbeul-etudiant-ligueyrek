"""
Recherche du site officiel des établissements qui n'en ont pas encore en base
(commande `python manage.py trouver_sites`).

Tavily propose des pages ; une adresse n'est retenue que si elle passe deux contrôles
vérifiables, sans jamais être devinée :
  1. l'ADRESSE ressemble au site de l'établissement : son nom de domaine contient un
     sigle (« ism », « dit ») ou un mot distinctif (« supdeco », « ipformed ») de son nom,
     et ce n'est ni un réseau social, ni un annuaire, ni un journal ;
  2. le SITE répond, et sa page d'accueil cite bien ce sigle ou ce mot.
Sinon, l'établissement reste sans site (sa fiche reste affichée dans l'application).
"""
import logging
import re
import urllib.parse

import httpx
from django.utils import timezone

from services import tavily_service
from services.cache import normaliser_texte

from . import fiabilite
from .models import Universite
from .recherche_web import EN_TETES

logger = logging.getLogger(__name__)

# Mots trop courants pour identifier un établissement à eux seuls.
_MOTS_GENERIQUES = {
    'universite', 'institut', 'ecole', 'superieur', 'superieure', 'superieurs', 'groupe', 'centre',
    'formation', 'formations', 'professionnelle', 'professionnel', 'professionnels', 'metiers',
    'enseignement', 'etudes', 'dakar', 'senegal', 'thies', 'matam', 'saint', 'louis', 'sante',
    'gestion', 'commerce', 'management', 'technique', 'techniques', 'technologies', 'technology',
    'institute', 'school', 'business', 'national', 'nationale', 'office', 'lycee', 'industriel',
    'parameditcal', 'paramedicale', 'paramedicales', 'paramedicaux', 'services', 'digital',
    'polytechnique', 'ouest', 'africain', 'informatique', 'ingenieurs', 'prepa', 'bts', 'des',
    'les', 'de', 'du', 'la', 'le', 'et', 'aux', 'of', 'the',
    # Réseaux à plusieurs établissements : « isep » désigne 6 ISEP différents.
    'isep', 'ucao',
}
# Annuaires, plateformes d'avis et agrégateurs : jamais le site officiel d'un établissement.
_DOMAINES_NON_OFFICIELS = {
    'leadersenegalais.com', 'senpanorama.com', 'edusenegal.com', 'etudier.com', 'senecole.com',
    'goafricaonline.com', 'pagesjaunesdusenegal.com', 'universites-senegal.com', 'campus-senegal.com',
    'jumia.sn', 'expat-dakar.com', 'yoonir.app', 'studyrama.com', 'letudiant.fr', 'thotismedia.com',
    'senjob.com', 'emploisenegal.com', 'google.com', 'maps.google.com', 'mapcarta.com',
    'africabizinfo.com', 'educarriere.ci', 'scholarvox.com', 'univ-online.net', 'kerawa.com',
}


def identifiants(nom):
    """Sigles (« (DIT) », mots en capitales comme « ECPI ») et mots distinctifs du nom,
    normalisés, qui doivent se retrouver dans l'adresse du site officiel."""
    entre_parentheses = ' '.join(re.findall(r'\(([^)]{2,20})\)', nom))
    sigles = set(normaliser_texte(entre_parentheses).split())
    sigles |= {normaliser_texte(m) for m in re.findall(r'\b[A-Z][A-Z0-9]{1,9}\b', nom)}
    mots = {
        m for m in normaliser_texte(nom).split()
        if len(m) >= 4 and not m.isdigit()
    }
    ids = {i for i in sigles | mots if len(i) >= 3 and i not in _MOTS_GENERIQUES}
    # Nom très court (« Institut 3i ») : le nom complet collé (« institut3i ») sert d'identifiant.
    compact = normaliser_texte(re.sub(r'\(.*?\)', '', nom)).replace(' ', '')
    if len(compact) <= 14:
        ids.add(compact)
    return ids


def _domaine_racine(url):
    hote = fiabilite.domaine(url)  # sans « www. »
    return hote


def _est_exclu(hote):
    return any(hote == d or hote.endswith('.' + d) for d in (
        _DOMAINES_NON_OFFICIELS | set(fiabilite.domaines_bloques()) | fiabilite._DOMAINES_PRESSE
    ))


def adresse_candidate(nom, resultats):
    """Premier résultat Tavily dont le DOMAINE contient un identifiant de l'établissement."""
    ids = identifiants(nom)
    for resultat in resultats:
        hote = _domaine_racine(resultat['url'])
        if not hote or _est_exclu(hote):
            continue
        etiquettes = normaliser_texte(hote.replace('.', ' ').replace('-', ' ')).split()
        nom_domaine = ''.join(etiquettes[:-1]) or hote  # sans l'extension (.sn, .com…)
        if any(_identifiant_dans_domaine(i, nom_domaine) for i in ids):
            return f'https://{hote}'
    return None


def _identifiant_dans_domaine(identifiant, nom_domaine):
    # Sigle court (« dit ») : en début ou fin de domaine seulement (dit.sn, ditdakar.sn),
    # sinon « editions.sn » passerait. Identifiant long : n'importe où (« groupesupdeco »).
    if len(identifiant) <= 4:
        return nom_domaine.startswith(identifiant) or nom_domaine.endswith(identifiant)
    return identifiant in nom_domaine


def site_confirme(nom, url, timeout=12):
    """Vrai si le site répond et que sa page d'accueil cite un identifiant de l'établissement.
    Un 403 (protection anti-robots) est accepté : le site existe, son domaine a déjà été
    vérifié à l'étape précédente."""
    try:
        reponse = httpx.get(url, headers=EN_TETES, timeout=timeout, follow_redirects=True)
    except httpx.HTTPError as exc:
        logger.info('Site injoignable %s : %s', url, exc)
        return False
    if reponse.status_code == 403:
        return True
    if reponse.status_code >= 400:
        return False
    page = normaliser_texte(reponse.text[:200_000])
    mots_page = set(page.split())
    # Sigle court : comme mot entier (« dit » est aussi un verbe français).
    return any((i in mots_page) if len(i) <= 4 else (i in page) for i in identifiants(nom))


def etablissements_sans_site():
    return Universite.objects.filter(statut_actif=True).filter(
        site_web_officiel__isnull=True,
    ) | Universite.objects.filter(statut_actif=True, site_web_officiel='')


def trouver(universite):
    """Retourne (url | None, explication)."""
    try:
        resultats = tavily_service.rechercher(
            f'{universite.nom} Sénégal site officiel', module='orientation', max_results=6,
            exclude_domains=fiabilite.domaines_bloques(), timeout=20,
        )
    except tavily_service.TavilyIndisponibleError as exc:
        return None, f'recherche impossible ({exc})'
    url = adresse_candidate(universite.nom, resultats)
    if not url:
        return None, 'aucun site à son nom parmi les résultats'
    if not site_confirme(universite.nom, url):
        return None, f'{url} ne répond pas ou ne cite pas l\'établissement'
    return url, 'confirmé'


def enregistrer(universite, url):
    universite.site_web_officiel = url
    universite.source = 'tavily (site officiel vérifié)'
    universite.date_verification = timezone.localdate()
    universite.save(update_fields=['site_web_officiel', 'source', 'date_verification', 'updated_at'])
