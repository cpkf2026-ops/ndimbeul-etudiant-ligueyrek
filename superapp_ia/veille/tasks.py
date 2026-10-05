"""Tâches Celery de la veille, déclenchées toutes les 2 h par Celery Beat
(CELERY_BEAT_SCHEDULE dans settings.py).

Ce n'est pas un modèle « entraîné » : c'est une tâche planifiée qui va chercher
des articles récents sur Internet (flux d'actualités), applique des règles de
fiabilité vérifiables (source, date réelle, lien vivant), puis demande à un LLM
local de trier et résumer — sans jamais inventer d'information.
"""
from celery import shared_task

from . import pipeline


@shared_task
def veiller_actualites_task():
    """Nouvelles actualités vérifiées, puis complétion des images manquantes,
    déduplication et archivage des actualités trop anciennes ou non fiables.
    Retourne les statistiques du passage (créées / rejetées par motif)."""
    stats = pipeline.veiller_actualites()
    pipeline.backfiller_metadonnees_actualites()
    pipeline.dedupliquer_actualites_similaires()
    pipeline.archiver_actualites_obsoletes()
    return stats


@shared_task
def veiller_offres_task():
    """Nouvelles offres vérifiées, puis expiration des offres dépassées, trop
    anciennes ou non vérifiées. Retourne les statistiques du passage."""
    stats = pipeline.veiller_offres()
    pipeline.archiver_offres_obsoletes()
    return stats


@shared_task
def veiller_universites_task():
    nb = pipeline.veiller_universites()
    pipeline.backfiller_logos_universites()
    return nb
