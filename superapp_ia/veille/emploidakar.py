"""
Offres d'emploi et de stage d'emploidakar.com, ajoutées à chaque passage de la veille des
opportunités (demande du 30/10/2026 : « il y a beaucoup de travail sur ce site »).

Accès respectueux du site :
  - son robots.txt autorise les pages d'offres (seuls l'administration et les CV sont exclus) ;
  - on lit la liste par l'adresse publique que sa propre page utilise pour afficher les offres
    (WP Job Manager, `jm-ajax/get_listings`), puis la page de chaque NOUVELLE offre ;
  - peu de requêtes (une liste + les nouvelles offres seulement), avec une pause entre deux ;
  - l'API WordPress du site est protégée par Cloudflare : on ne la contourne pas.

Les données de la liste sont déjà structurées (intitulé, entreprise, lieu, type, date) : pas
besoin du modèle d'IA. Règles communes d'enregistrement : voir offres_directes.py.
"""
import html
import logging
import re
import time
from datetime import date, timedelta

import httpx
from bs4 import BeautifulSoup
from django.utils import timezone

from . import fiabilite, offres_directes

logger = logging.getLogger(__name__)

SITE = 'https://www.emploidakar.com'
URL_LISTE = f'{SITE}/jm-ajax/get_listings/'
OFFRES_PAR_PAGE = 30
PAGES_MAX = 3  # 90 offres au plus parcourues par passage

# Fin de la description utile sur la page d'une offre (blocs du site qui suivent l'annonce).
_FIN_DESCRIPTION = re.compile(r"M'envoyer des offres similaires|Je dépose mon CV|Recevez le", re.I)


def _type_offre(types):
    """Types du site (cdd, cdi, stage, prestation…) -> type de l'application."""
    if 'alternance' in types:
        return 'alternance'
    if 'stage' in types and not types & {'cdd', 'cdi', 'interim', 'prestation-de-services', 'freelance'}:
        return 'stage'
    return 'emploi'


def lire_liste(page=1):
    """Offres d'une page de la liste, les plus récentes d'abord."""
    reponse = httpx.post(URL_LISTE, headers=offres_directes.EN_TETES, verify=offres_directes.VERIFICATION_SSL, timeout=20, data={
        'per_page': OFFRES_PAR_PAGE, 'orderby': 'date', 'order': 'DESC', 'page': page,
        'show_pagination': 'false',
    })
    reponse.raise_for_status()
    soup = BeautifulSoup(reponse.json().get('html') or '', 'html.parser')
    offres = []
    for li in soup.select('li.job_listing'):
        lien = li.find('a', href=True)
        titre = li.select_one('.position h3')
        if not lien or not titre:
            continue
        date_tag = li.find('time')
        try:
            publiee = date.fromisoformat(date_tag['datetime']) if date_tag and date_tag.get('datetime') else None
        except ValueError:
            publiee = None
        types = {c.removeprefix('job-type-') for c in li.get('class', []) if c.startswith('job-type-')}
        entreprise = li.select_one('.company strong')
        lieu = li.select_one('.location')
        offres.append({
            'url': lien['href'].strip(),
            'titre': html.unescape(titre.get_text(' ', strip=True)),
            'entreprise': entreprise.get_text(' ', strip=True) if entreprise else None,
            'lieu': lieu.get_text(' ', strip=True) if lieu else None,
            'types': types,
            'date_publication': publiee,
        })
    return offres


def lire_description(url):
    """Texte de l'annonce (page de l'offre), sans les blocs du site qui la suivent."""
    reponse = httpx.get(url, headers=offres_directes.EN_TETES, verify=offres_directes.VERIFICATION_SSL, timeout=20, follow_redirects=True)
    reponse.raise_for_status()
    bloc = BeautifulSoup(reponse.text, 'html.parser').select_one('.job_description')
    if bloc is None:
        return ''
    texte = re.sub(r'\s+', ' ', bloc.get_text(' ', strip=True))
    return _FIN_DESCRIPTION.split(texte)[0].strip()


def veiller(stats=None):
    """Ajoute les nouvelles offres d'emploidakar.com. Retourne le nombre d'offres créées."""
    stats = stats if stats is not None else {}
    limite_age = timezone.localdate() - timedelta(days=fiabilite.OFFRES_AGE_MAX_JOURS)
    candidats = []
    for page in range(1, PAGES_MAX + 1):
        try:
            offres = lire_liste(page)
        except (httpx.HTTPError, ValueError) as exc:
            logger.warning('emploidakar.com : liste indisponible (page %d) : %s', page, exc)
            stats['emploidakar_erreur'] = str(exc)[:200]
            break
        recentes = [o for o in offres if o['date_publication'] and o['date_publication'] >= limite_age]
        candidats += recentes
        if len(recentes) < len(offres) or len(offres) < OFFRES_PAR_PAGE:
            break  # on a atteint des offres trop anciennes, ou la dernière page
        time.sleep(offres_directes.PAUSE_SECONDES)

    connues = offres_directes.deja_connues([o['url'] for o in candidats])
    nouvelles = [o for o in candidats if o['url'][:500] not in connues][:offres_directes.NOUVELLES_MAX_PAR_SITE]
    stats['emploidakar_candidats'] = len(candidats)
    creees = 0
    for offre in nouvelles:
        time.sleep(offres_directes.PAUSE_SECONDES)
        try:
            description = lire_description(offre['url'])
        except httpx.HTTPError as exc:
            logger.info('emploidakar.com : annonce illisible %s (%s)', offre['url'], exc)
            continue
        creees += offres_directes.enregistrer(
            {**offre, 'type': _type_offre(offre['types']), 'description': description, 'source': 'emploidakar.com'},
            stats, 'emploidakar')
    stats['creees_emploidakar'] = creees
    logger.info('emploidakar.com : %d nouvelle(s) offre(s) sur %d récente(s) parcourue(s).', creees, len(candidats))
    return creees
