"""Tâches Celery de la veille, déclenchées toutes les 2 h par Celery Beat
(CELERY_BEAT_SCHEDULE dans settings.py).

Ce n'est pas un modèle « entraîné » : c'est une tâche planifiée qui va chercher
des articles récents sur Internet (flux d'actualités), applique des règles de
fiabilité vérifiables (source, date réelle, lien vivant), puis demande à un LLM
local de trier et résumer — sans jamais inventer d'information.
"""
import logging
import time

from celery import shared_task
from django.conf import settings

from . import actualites, commun, opportunites, pipeline

logger = logging.getLogger(__name__)

# Heure de démarrage du worker. Au lancement de l'application, la veille est presque
# toujours « en retard » (PC éteint depuis plus de 2 h) : Celery Beat la déclenchait
# aussitôt, en même temps que Django, Ollama, Chrome… et la machine se figeait
# (observé le 21/10/2026 : processeur à 100 %, Redis ne répondait plus). On laisse
# donc le PC finir de démarrer : le passage est REPORTÉ, pas annulé.
_DEMARRAGE_WORKER = time.monotonic()


def _reporter_si_demarrage(tache, decalage=0):
    """Vrai si la tâche a été replanifiée parce que le worker vient de démarrer.
    `decalage` (secondes) espace les deux veilles pour qu'elles ne s'enchaînent pas."""
    delai = settings.VEILLE_DELAI_DEMARRAGE_MINUTES * 60
    ecoule = time.monotonic() - _DEMARRAGE_WORKER
    if ecoule >= delai:
        return False
    attente = int(delai - ecoule) + decalage
    tache.apply_async(countdown=attente)
    logger.info('Veille %s reportée de %d min (démarrage du PC en cours).', tache.name, attente // 60)
    return True


def _reessayer_si_hors_ligne(tache, stats):
    """PC sans Internet (Wi-Fi pas encore connecté…) : nouvel essai dans 15 min au lieu
    d'attendre le créneau suivant de Celery Beat (2 h)."""
    if stats.get('mode') == 'hors_ligne':
        tache.apply_async(countdown=commun.RETRY_HORS_LIGNE_MINUTES * 60)
    return stats


@shared_task(bind=True)
def veille_actualites(self):
    """Module 3 : actualités éducation via Tavily + Mistral (repli sur les sources
    gratuites si le quota est épuisé), puis déduplication des quasi-doublons et
    archivage des actualités trop anciennes. Retourne les statistiques du passage."""
    if _reporter_si_demarrage(self):
        return {'mode': 'reporte', 'raison': 'démarrage du PC : passage reporté'}
    stats = _reessayer_si_hors_ligne(self, actualites.veille_actualites())
    if stats.get('mode') not in ('ignore', 'hors_ligne'):
        pipeline.dedupliquer_actualites_similaires()
        pipeline.archiver_actualites_obsoletes()
    return stats


@shared_task(bind=True)
def veille_opportunites(self):
    """Module 2 : emplois, stages, formations, bourses et concours via Tavily +
    Mistral (repli sur les sources gratuites si le quota est épuisé), puis
    expiration des offres dépassées. Retourne les statistiques du passage."""
    if _reporter_si_demarrage(self, decalage=5 * 60):
        return {'mode': 'reporte', 'raison': 'démarrage du PC : passage reporté'}
    return _reessayer_si_hors_ligne(self, opportunites.veille_opportunites())


@shared_task
def veiller_universites_task():
    nb = pipeline.veiller_universites()
    pipeline.backfiller_logos_universites()
    return nb
