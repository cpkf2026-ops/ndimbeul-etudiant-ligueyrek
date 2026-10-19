"""Tâches Celery de la veille, déclenchées toutes les 2 h par Celery Beat
(CELERY_BEAT_SCHEDULE dans settings.py).

Ce n'est pas un modèle « entraîné » : c'est une tâche planifiée qui va chercher
des articles récents sur Internet (flux d'actualités), applique des règles de
fiabilité vérifiables (source, date réelle, lien vivant), puis demande à un LLM
local de trier et résumer — sans jamais inventer d'information.
"""
from celery import shared_task

from . import actualites, opportunites, pipeline


@shared_task
def veille_actualites():
    """Module 3 : actualités éducation via Tavily + Mistral (repli sur les sources
    gratuites si le quota est épuisé), puis déduplication des quasi-doublons et
    archivage des actualités trop anciennes. Retourne les statistiques du passage."""
    stats = actualites.veille_actualites()
    if stats.get('mode') != 'ignore':
        pipeline.dedupliquer_actualites_similaires()
        pipeline.archiver_actualites_obsoletes()
    return stats


@shared_task
def veille_opportunites():
    """Module 2 : emplois, stages, formations, bourses et concours via Tavily +
    Mistral (repli sur les sources gratuites si le quota est épuisé), puis
    expiration des offres dépassées. Retourne les statistiques du passage."""
    return opportunites.veille_opportunites()


@shared_task
def veiller_universites_task():
    nb = pipeline.veiller_universites()
    pipeline.backfiller_logos_universites()
    return nb
