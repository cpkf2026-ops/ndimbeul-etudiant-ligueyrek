"""
Économie des crédits Tavily (§ 4 du cahier des charges).

Le plan gratuit Tavily donne TAVILY_MONTHLY_LIMIT crédits par mois (1 000 par
défaut, 1 crédit par recherche « basic »). Chaque appel réussi est compté ici,
par jour, en séparant :
  - la VEILLE automatique (modules 2 et 3), qui ne peut consommer que
    LIMITE − RÉSERVE : au-delà, elle passe en mode réduit (toutes les 6 h,
    sources gratuites) ;
  - les usages INTERACTIFS (chatbot, orientation), qui gardent la réserve
    TAVILY_RESERVE_INTERACTIF pour eux et ne s'arrêtent qu'à la limite totale.
"""
import logging

from django.conf import settings
from django.db import DatabaseError, IntegrityError, transaction
from django.db.models import F, Sum
from django.utils import timezone

from .models import CreditTavily

logger = logging.getLogger(__name__)

VEILLE = 'veille'
INTERACTIF = 'interactif'

# Coût d'une recherche selon sa profondeur (grille Tavily).
COUT_PAR_PROFONDEUR = {'basic': 1, 'advanced': 2}

_COLONNE_PAR_USAGE = {VEILLE: 'credits_veille', INTERACTIF: 'credits_interactif'}


def enregistrer(credits, usage):
    """Ajoute `credits` au compteur du jour. L'UPDATE avec F() est atomique côté
    MySQL : deux process (Django + worker Celery) peuvent compter en même temps
    sans perdre d'incrément."""
    colonne = _COLONNE_PAR_USAGE[usage]
    jour = timezone.localdate()
    increments = {colonne: F(colonne) + credits, 'nb_requetes': F('nb_requetes') + 1}

    # Deux tentatives : si la ligne du jour est créée par un autre process entre
    # notre UPDATE (0 ligne) et notre INSERT, l'INSERT échoue et on refait l'UPDATE.
    for _ in range(2):
        if CreditTavily.objects.filter(jour=jour).update(**increments):
            return
        try:
            with transaction.atomic():
                CreditTavily.objects.create(jour=jour, nb_requetes=1, **{colonne: credits})
            return
        except IntegrityError:
            continue
    logger.error('Crédits Tavily non enregistrés pour le %s (%s crédit(s), %s)', jour, credits, usage)


def credits_du_mois():
    """Crédits consommés depuis le 1er du mois : {'veille', 'interactif', 'total'}."""
    debut_mois = timezone.localdate().replace(day=1)
    sommes = CreditTavily.objects.filter(jour__gte=debut_mois).aggregate(
        veille=Sum('credits_veille'), interactif=Sum('credits_interactif'),
    )
    veille = sommes['veille'] or 0
    interactif = sommes['interactif'] or 0
    return {'veille': veille, 'interactif': interactif, 'total': veille + interactif}


def plafond(usage):
    """Nombre de crédits mensuels au-delà duquel `usage` n'appelle plus Tavily."""
    limite = settings.TAVILY_MONTHLY_LIMIT
    if usage == VEILLE:
        return max(limite - settings.TAVILY_RESERVE_INTERACTIF, 0)
    return limite


def quota_atteint(usage):
    """Vrai si `usage` ne doit plus appeler Tavily ce mois-ci. En cas d'erreur de
    base, on bloque par prudence : mieux vaut une réponse sans Tavily qu'un
    dépassement de quota non maîtrisé."""
    try:
        return credits_du_mois()['total'] >= plafond(usage)
    except DatabaseError as exc:
        logger.error('Compteur de crédits Tavily illisible, Tavily suspendu par prudence : %s', exc)
        return True


def mode_reduit():
    """La veille passe en mode réduit (toutes les 6 h, sources gratuites) dès
    qu'elle a épuisé sa part du quota mensuel."""
    return quota_atteint(VEILLE)


def etat():
    """Résumé pour l'endpoint de santé et les logs."""
    consommes = credits_du_mois()
    return {
        'mois': timezone.localdate().strftime('%Y-%m'),
        'consommes': consommes,
        'limite_mensuelle': settings.TAVILY_MONTHLY_LIMIT,
        'reserve_interactif': settings.TAVILY_RESERVE_INTERACTIF,
        'restants': max(settings.TAVILY_MONTHLY_LIMIT - consommes['total'], 0),
        'mode_reduit_veille': consommes['total'] >= plafond(VEILLE),
    }
