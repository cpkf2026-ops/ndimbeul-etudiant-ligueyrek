"""
Cache Redis des réponses fréquentes (chatbot : 24 h, orientation : 7 jours).

Le cache est une OPTIMISATION, pas une dépendance : si Redis est arrêté, les
lectures renvoient None et les écritures sont ignorées (avec un avertissement
dans les logs), et le service continue de répondre normalement, juste moins vite.
"""
import hashlib
import logging
import re
import unicodedata

from django.core.cache import cache

logger = logging.getLogger(__name__)


def normaliser_texte(texte):
    """'  Quelles sont les DATES du Bac ?! ' -> 'quelles sont les dates du bac'.
    Deux questions qui ne diffèrent que par la casse, les accents ou la ponctuation
    partagent ainsi la même entrée de cache."""
    texte = unicodedata.normalize('NFKD', str(texte or '')).encode('ascii', 'ignore').decode('ascii')
    texte = re.sub(r'[^\w\s]', ' ', texte.lower())
    return ' '.join(texte.split())


def cle(espace, *parties):
    """Clé courte et stable : 'ia:chat:<sha256 des parties normalisées>'."""
    brut = '|'.join(normaliser_texte(p) for p in parties)
    return f'ia:{espace}:{hashlib.sha256(brut.encode("utf-8")).hexdigest()}'


def lire(cle_cache):
    try:
        return cache.get(cle_cache)
    except Exception as exc:  # Redis arrêté ou injoignable
        logger.warning('Cache Redis indisponible (lecture ignorée) : %s', exc)
        return None


def ecrire(cle_cache, valeur, ttl_secondes):
    try:
        cache.set(cle_cache, valeur, ttl_secondes)
    except Exception as exc:
        logger.warning('Cache Redis indisponible (écriture ignorée) : %s', exc)


def disponible():
    """Vrai si Redis répond (endpoint de santé)."""
    try:
        cache.set('ia:sante', 'ok', 10)
        return cache.get('ia:sante') == 'ok'
    except Exception:
        return False
