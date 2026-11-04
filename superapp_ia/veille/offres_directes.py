"""
Enregistrement commun des offres lues directement sur les sites d'emploi sénégalais
(emploidakar.com, senjob.com, concoursn.com — voir les modules du même nom).

Mêmes règles pour tous les sites :
  - offre de moins de OFFRES_AGE_MAX_JOURS jours, date limite pas encore passée ;
  - annonce non vide ;
  - au Sénégal (une offre qui ne cite qu'un lieu étranger est écartée) ;
  - pas de doublon : même lien, ou même offre déjà publiée par un autre site (les sites se
    reprennent souvent entre eux : concoursn.com republie des offres d'emploidakar.com).
"""
import logging
import re
import ssl
from datetime import date, timedelta

import truststore

from django.db import IntegrityError
from django.utils import timezone

from services.cache import normaliser_texte

from . import back_office, commun, fiabilite, lieux
from .models import OffreEmploi

logger = logging.getLogger(__name__)

EN_TETES = {'User-Agent': 'Mozilla/5.0 (compatible; NdimbeulEtudiant/1.0; veille des offres pour etudiants)'}
NOUVELLES_MAX_PAR_SITE = 30
PAUSE_SECONDES = 1.0  # entre deux pages d'un même site
# Vérification des certificats par Windows : certains sites (senjob.com) n'envoient pas leur
# certificat intermédiaire ; Windows sait le récupérer, la vérification Python par défaut non.
# La sécurité reste entière (on ne désactive jamais la vérification).
VERIFICATION_SSL = truststore.SSLContext(ssl.PROTOCOL_TLS_CLIENT)

# Pays et grandes villes étrangères cités dans le lieu de certaines offres.
ETRANGER = {
    'addis', 'ababa', 'ethiopie', 'ethiopia', 'nairobi', 'kenya', 'kinshasa', 'congo', 'rdc', 'harare',
    'zimbabwe', 'bujumbura', 'burundi', 'mauritius', 'maurice', 'kigali', 'rwanda', 'abidjan', 'ivoire',
    'bamako', 'mali', 'conakry', 'guinee', 'nouakchott', 'mauritanie', 'banjul', 'gambie', 'gambia',
    'bissau', 'niamey', 'niger', 'ouagadougou', 'burkina', 'lome', 'togo', 'cotonou', 'benin', 'accra',
    'ghana', 'lagos', 'abuja', 'nigeria', 'douala', 'yaounde', 'cameroun', 'libreville', 'gabon',
    'rabat', 'casablanca', 'maroc', 'tunis', 'tunisie', 'alger', 'algerie', 'paris', 'france',
    'johannesburg', 'pretoria', 'afrique du sud', 'new york', 'geneve', 'suisse', 'bruxelles',
}
_MOTS_VIDES = {
    'recrutement', 'recrute', 'offre', 'emploi', 'poste', 'senegal', 'dakar', 'session', 'h/f', 'avis',
    'appel', 'candidature', 'candidatures', 'pour', 'des', 'les', 'une', 'son', 'ses', 'dans', 'avec',
}


def _mots_du_titre(titre):
    return {m for m in re.findall(r'[a-z0-9]+', normaliser_texte(titre)) if len(m) > 2 and m not in _MOTS_VIDES}


def deja_publiee(titre, entreprise=None):
    """Même offre déjà active, publiée par un autre site (titre quasi identique, et même
    entreprise quand on la connaît des deux côtés)."""
    mots = _mots_du_titre(titre)
    if len(mots) < 2:
        return False
    limite = timezone.now() - timedelta(days=fiabilite.OFFRES_AGE_MAX_JOURS)
    for intitule, autre_entreprise in OffreEmploi.objects.filter(
            statut='active', date_indexation__gte=limite).values_list('intitule', 'entreprise'):
        autres = _mots_du_titre(intitule)
        if not autres or len(mots & autres) / min(len(mots), len(autres)) < 0.8:
            continue
        connues = [normaliser_texte(e) for e in (entreprise, autre_entreprise)
                   if e and not normaliser_texte(e).startswith('non precis')]
        if len(connues) < 2 or connues[0][:12] == connues[1][:12]:
            return True
    return False


def a_l_etranger(lieu):
    """Vrai si le lieu ne cite qu'un pays ou une ville étrangère (une petite localité
    sénégalaise absente de nos listes, comme « Sandiara », reste acceptée)."""
    if not lieu:
        return False
    region, _ = lieux.localiser(lieu)
    texte = f' {normaliser_texte(lieu)} '
    return region is None and ' senegal ' not in texte and any(f' {e} ' in texte for e in ETRANGER)


def enregistrer(offre, stats, cle):
    """Enregistre une offre lue sur un site. `offre` : url, titre, entreprise, lieu, type,
    date_publication, description, date_limite (facultative), source. Retourne True si créée."""
    description = (offre.get('description') or '').strip()
    if len(description) < 80:
        stats[f'{cle}_vide'] = stats.get(f'{cle}_vide', 0) + 1
        return False
    publiee = offre.get('date_publication')
    if publiee and publiee < timezone.localdate() - timedelta(days=fiabilite.OFFRES_AGE_MAX_JOURS):
        return False
    limite = offre.get('date_limite') or back_office._date_limite(description)
    if isinstance(limite, str):
        limite = date.fromisoformat(limite)
    if limite and limite < timezone.localdate():
        stats[f'{cle}_expiree'] = stats.get(f'{cle}_expiree', 0) + 1
        return False
    if a_l_etranger(offre.get('lieu')):
        stats[f'{cle}_etranger'] = stats.get(f'{cle}_etranger', 0) + 1
        return False
    if deja_publiee(offre['titre'], offre.get('entreprise')):
        stats[f'{cle}_doublon'] = stats.get(f'{cle}_doublon', 0) + 1
        return False
    region, _ = lieux.localiser(offre.get('lieu') or '')
    maintenant = timezone.now()
    try:
        OffreEmploi.objects.create(
            hash_dedoublonnage=commun.hash_dedoublonnage(offre['url'], offre['titre']),
            intitule=offre['titre'][:255],
            entreprise=(offre.get('entreprise') or 'Non précisé')[:255],
            type=offre.get('type') or 'emploi',
            region=(region or offre.get('lieu') or 'Non précisée')[:255],
            description=description,
            resume=description[:400],
            source_url=offre['url'][:500],
            source=offre['source'],
            fiabilite=fiabilite.PLATEFORME,
            date_publication=publiee,
            date_limite=limite,
            statut='active',
            date_indexation=maintenant,
            date_collecte=maintenant,
        )
    except IntegrityError:
        return False
    return True


def type_selon_titre(titre, defaut='emploi'):
    """Type d'offre d'après les mots de son titre (« Stagiaire… », « Concours… », « Bourse… »)."""
    t = normaliser_texte(titre)
    if re.search(r'\bconcours\b', t):
        return 'concours'
    if re.search(r'\bbourses?\b', t):
        return 'bourse'
    if re.search(r'\b(stage|stages|stagiaire|stagiaires)\b', t):
        return 'stage'
    if re.search(r'\balternance\b', t):
        return 'alternance'
    return defaut


def deja_connues(urls):
    return set(OffreEmploi.objects.filter(source_url__in=[u[:500] for u in urls]).values_list('source_url', flat=True))
