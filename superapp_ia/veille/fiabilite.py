"""
Règles de fiabilité et de fraîcheur de la veille actualités.

Une actualité n'est publiée dans l'app que si TOUTES ces conditions sont vraies :
  1. sa source est un site OFFICIEL (État, université, organisme public) ou un
     média de PRESSE reconnu — tout domaine inconnu, réseau social, blog,
     agrégateur ou site publicitaire est rejeté ;
  2. sa date de publication RÉELLE est connue (flux d'actualités ou métadonnées
     de l'article) et récente — jamais de date inventée ;
  3. la page de l'article répond (lien vivant) ;
  4. le LLM confirme qu'il s'agit d'un fait précis lié à l'éducation au Sénégal.
"""
import os
import urllib.parse
from datetime import timedelta

from django.utils import timezone

OFFICIEL = 'officiel'
PRESSE = 'presse'
PLATEFORME = 'plateforme'

# Âge maximal d'une actualité au moment de son indexation, et durée pendant
# laquelle elle reste affichée avant archivage automatique.
AGE_MAX_JOURS = int(os.getenv('VEILLE_ACTUALITES_AGE_MAX_JOURS', '21'))
RETENTION_JOURS = int(os.getenv('VEILLE_ACTUALITES_RETENTION_JOURS', '30'))

# Offres : publiées il y a moins de 30 jours, et retirées de l'app 30 jours après
# leur publication (ou dès que leur date limite est passée).
OFFRES_AGE_MAX_JOURS = int(os.getenv('VEILLE_OFFRES_AGE_MAX_JOURS', '30'))

# Plateformes d'offres reconnues (sites spécialisés emploi/concours/bourses qui
# autorisent l'indexation dans leur robots.txt). Acceptées pour les OFFRES
# uniquement — pas comme source d'actualités.
_PLATEFORMES_OFFRES = {'senjob.com', 'anpej.sn', 'emploidakar.com', 'emploisenegal.com'}

# Suffixes de domaines institutionnels sénégalais (ministères, universités…).
_SUFFIXES_OFFICIELS = ('.gouv.sn', '.edu.sn')

# Sites officiels hors suffixes ci-dessus (universités, offices, plateformes d'État,
# organisations internationales de l'éducation).
_DOMAINES_OFFICIELS = {
    'ucad.sn', 'ugb.sn', 'uasz.sn', 'uadb.sn', 'uam.sn', 'uvs.sn', 'unchk.sn',
    'ussein.sn', 'uidt.sn', 'esp.sn', 'ept.sn', 'isep-thies.sn', 'isepdiamniadio.sn',
    'campusen.sn', 'officedubac.sn', 'education.sn', 'mesri.gouv.sn', 'mesrisenegal.sn',
    'primature.sn', 'presidence.sn', 'sec.gouv.sn', 'fongip.sn', 'anpej.sn',
    'onfp.sn', '3fpt.sn', 'cesag.sn', 'campusfrance.org', 'unesco.org',
    'unicef.org', 'banquemondiale.org', 'worldbank.org', 'auf.org',
}

# Médias de presse reconnus (sénégalais, panafricains et internationaux).
_DOMAINES_PRESSE = {
    'aps.sn', 'lesoleil.sn', 'seneweb.com', 'dakaractu.com', 'pressafrik.com',
    'senego.com', 'igfm.sn', 'lequotidien.sn', 'sudquotidien.sn', 'emedia.sn',
    'senenews.com', 'leral.net', 'walf-groupe.com', 'dakarmatin.com', 'rewmi.com',
    'seneplus.com', 'lejecos.com', 'enqueteplus.com', 'xibaaru.sn', 'senxibaar.com',
    'actusen.sn', 'ndarinfo.com', 'kewoulo.info', 'sanslimitesn.com', 'rts.sn',
    'tfm.sn', 'dakarbuzz.net', 'bbc.com', 'rfi.fr', 'france24.com', 'jeuneafrique.com',
    'lemonde.fr', 'allafrica.com', 'fr.allafrica.com', 'apanews.net', 'agenceecofin.com',
    'africanews.com', 'tv5monde.com', 'lepoint.fr', 'theconversation.com',
    'socialnetlink.org', 'financialafrik.com',
}

# Jamais publiés : réseaux sociaux, vidéos, forums, agrégateurs de bourses,
# sites de révision commerciaux, annuaires.
_DOMAINES_BLOQUES = {
    'facebook.com', 'm.facebook.com', 'twitter.com', 'x.com', 'instagram.com',
    'tiktok.com', 'youtube.com', 'youtu.be', 'linkedin.com', 'pinterest.com',
    'reddit.com', 'quora.com', 'wikipedia.org', 'scribd.com', 'slideshare.net',
    'trouvetabourse.com', 'greatyop.com', 'pass-ton-bacsn.com', 'acacile.com',
    'opportunitiesforafricans.com', 'afterschoolafrica.com', 'concoursn.com',
}


def domaine(url):
    """'https://www.aps.sn/actu/123' -> 'aps.sn'."""
    hote = (urllib.parse.urlparse(url or '').hostname or '').lower()
    return hote[4:] if hote.startswith('www.') else hote


def _correspond(hote, ensemble):
    """Vrai si l'hôte est un domaine listé ou l'un de ses sous-domaines."""
    return any(hote == d or hote.endswith('.' + d) for d in ensemble)


def niveau_fiabilite(url):
    """Retourne OFFICIEL, PRESSE, ou None si la source n'est pas jugée fiable."""
    hote = domaine(url)
    if not hote or _correspond(hote, _DOMAINES_BLOQUES):
        return None
    if hote.endswith(_SUFFIXES_OFFICIELS) or _correspond(hote, _DOMAINES_OFFICIELS):
        return OFFICIEL
    if _correspond(hote, _DOMAINES_PRESSE):
        return PRESSE
    return None


def niveau_fiabilite_offre(url):
    """Comme niveau_fiabilite, en acceptant en plus les plateformes d'offres reconnues.
    Retourne OFFICIEL, PRESSE, PLATEFORME ou None."""
    hote = domaine(url)
    if hote and _correspond(hote, _PLATEFORMES_OFFRES):
        # anpej.sn est un organisme public : il reste classé 'officiel'.
        return OFFICIEL if _correspond(hote, _DOMAINES_OFFICIELS) else PLATEFORME
    return niveau_fiabilite(url)


def est_recente(date_publication, jours=AGE_MAX_JOURS):
    """Vrai si la date est connue, pas dans le futur (tolérance 1 jour) et a moins
    de `jours` jours."""
    if date_publication is None:
        return False
    if timezone.is_naive(date_publication):
        date_publication = timezone.make_aware(date_publication, timezone.get_current_timezone())
    maintenant = timezone.now()
    return maintenant - timedelta(days=jours) <= date_publication <= maintenant + timedelta(days=1)


def nom_source_lisible(url, nom_fourni=None):
    """Nom affiché dans l'app : celui du flux d'actualités s'il existe
    ('Seneweb', 'APS - Agence de Presse Sénégalaise'), sinon le domaine."""
    if nom_fourni:
        return nom_fourni.strip()[:120]
    return domaine(url)


def domaines_bloques():
    """Domaines jamais acceptés comme source (réseaux sociaux, forums, agrégateurs) :
    transmis à Tavily en `exclude_domains` quand la recherche n'est pas restreinte."""
    return sorted(_DOMAINES_BLOQUES)
