"""
Offres de senjob.com (principal site d'emploi sénégalais), lues à chaque passage de la veille.

Accès respectueux : le robots.txt du site n'interdit que les CV et l'espace employeur ; on lit
la page publique « Offres d'emploi », puis la page de chaque NOUVELLE offre (une seconde de
pause entre deux pages). Règles communes d'enregistrement : voir offres_directes.py.
"""
import logging
import re
import time
from datetime import date

import httpx
from bs4 import BeautifulSoup
from django.utils import timezone

from services.cache import normaliser_texte

from . import offres_directes

logger = logging.getLogger(__name__)

URL_LISTE = 'https://senjob.com/sn/offres-d-emploi.php'
_LIEN_OFFRE = re.compile(r'/jobseekers/[^"\s]+_e_\d+\.html$')
_MOIS = {
    'jan': 1, 'janv': 1, 'janvier': 1, 'fev': 2, 'fevr': 2, 'fevrier': 2, 'mars': 3, 'mar': 3, 'avr': 4,
    'avril': 4, 'mai': 5, 'juin': 6, 'juil': 7, 'juillet': 7, 'aout': 8, 'sept': 9, 'sep': 9,
    'septembre': 9, 'oct': 10, 'octobre': 10, 'nov': 11, 'novembre': 11, 'dec': 12, 'decembre': 12,
}


def _date(texte, annee=None):
    """« 26 Oct. » ou « 08 Novembre 2026 » -> date. Sans année : l'année en cours, ou la
    précédente si la date tomberait dans le futur (offre publiée fin décembre, lue en janvier)."""
    m = re.search(r'(\d{1,2})\s+([a-z]+)\.?\s*(\d{4})?', normaliser_texte(texte or ''))
    if not m or m.group(2) not in _MOIS:
        return None
    aujourd_hui = timezone.localdate()
    try:
        resultat = date(int(m.group(3) or annee or aujourd_hui.year), _MOIS[m.group(2)], int(m.group(1)))
    except ValueError:
        return None
    if not m.group(3) and annee is None and resultat > aujourd_hui:
        resultat = resultat.replace(year=resultat.year - 1)
    return resultat


def lire_liste():
    reponse = httpx.get(URL_LISTE, headers=offres_directes.EN_TETES, verify=offres_directes.VERIFICATION_SSL, timeout=25, follow_redirects=True)
    reponse.raise_for_status()
    soup = BeautifulSoup(reponse.text, 'html.parser')
    offres, vues = [], set()
    for lien in soup.find_all('a', href=_LIEN_OFFRE):
        url = lien['href'].strip()
        titre = lien.get_text(' ', strip=True)
        if url in vues or not titre:
            continue
        vues.add(url)
        ligne = lien.find_parent('tr')
        texte = re.sub(r'\s+', ' ', ligne.get_text(' ', strip=True)) if ligne else ''
        publiee = re.search(r'Publi\w*\s*:\s*(\d{1,2}\s+\S+)', texte)
        lieu = texte.replace(titre, '', 1).split('Publi')[0].strip(' -/')
        offres.append({
            'url': url, 'titre': titre, 'lieu': lieu or None,
            'date_publication': _date(publiee.group(1)) if publiee else None,
        })
    return offres


def lire_offre(url):
    """(description, date limite, lieu) depuis la page de l'offre."""
    reponse = httpx.get(url, headers=offres_directes.EN_TETES, verify=offres_directes.VERIFICATION_SSL, timeout=25, follow_redirects=True)
    reponse.raise_for_status()
    texte = re.sub(r'\s+', ' ', BeautifulSoup(reponse.text, 'html.parser').get_text(' ', strip=True))
    description = texte.split("Description de l'offre", 1)[-1].split('Partagez cette offre', 1)[0].strip()
    if "Description de l'offre" not in texte:
        description = ''
    expiration = re.search(r'Expiration\s+(\d{1,2}\s+\w+\s+\d{4})', texte)
    lieu = re.search(r'Localisation\s+(.+?)\s+Expiration', texte)
    return description, (_date(expiration.group(1)) if expiration else None), (lieu.group(1) if lieu else None)


def veiller(stats=None):
    """Ajoute les nouvelles offres de senjob.com. Retourne le nombre d'offres créées."""
    stats = stats if stats is not None else {}
    try:
        offres = lire_liste()
    except httpx.HTTPError as exc:
        logger.warning('senjob.com : liste indisponible : %s', exc)
        stats['senjob_erreur'] = str(exc)[:200]
        return 0
    connues = offres_directes.deja_connues([o['url'] for o in offres])
    nouvelles = [o for o in offres if o['url'][:500] not in connues][:offres_directes.NOUVELLES_MAX_PAR_SITE]
    stats['senjob_candidats'] = len(offres)
    creees = 0
    for offre in nouvelles:
        time.sleep(offres_directes.PAUSE_SECONDES)
        try:
            description, limite, lieu = lire_offre(offre['url'])
        except httpx.HTTPError as exc:
            logger.info('senjob.com : annonce illisible %s (%s)', offre['url'], exc)
            continue
        creees += offres_directes.enregistrer({
            **offre, 'lieu': lieu or offre['lieu'], 'description': description, 'date_limite': limite,
            'type': offres_directes.type_selon_titre(offre['titre']), 'source': 'senjob.com',
        }, stats, 'senjob')
    stats['creees_senjob'] = creees
    logger.info('senjob.com : %d nouvelle(s) offre(s) sur %d parcourue(s).', creees, len(offres))
    return creees
