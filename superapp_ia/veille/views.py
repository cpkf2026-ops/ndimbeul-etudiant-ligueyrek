"""Endpoints de lecture de la veille (appelés par Laravel uniquement)."""
from django.db.models import F
from rest_framework.exceptions import ValidationError
from rest_framework.generics import ListAPIView

from . import actualites, opportunites
from .models import Actualite, OffreEmploi
from .serializers import ActualiteSerializer, OpportuniteSerializer


def _filtrer_categorie(requete, queryset, valeurs_possibles, champ):
    categorie = requete.query_params.get('categorie')
    if not categorie:
        return queryset
    if categorie not in valeurs_possibles:
        raise ValidationError({
            'categorie': f"Valeur inconnue « {categorie} ». Valeurs possibles : {', '.join(valeurs_possibles)}.",
        })
    return queryset.filter(**{champ: categorie})


class OpportuniteListView(ListAPIView):
    """GET /api/ia/opportunites/?categorie=stage&page=1&par_page=20

    Offres actives uniquement (les expirées restent en base mais ne sont plus
    proposées), les plus récemment collectées d'abord."""

    serializer_class = OpportuniteSerializer

    def get_queryset(self):
        offres = _filtrer_categorie(
            self.request, OffreEmploi.objects.filter(statut='active'), opportunites.CATEGORIES, 'type',
        )
        return offres.order_by(F('date_collecte').desc(nulls_last=True), '-date_indexation')


class ActualiteListView(ListAPIView):
    """GET /api/ia/actualites/?page=1&categorie=bourse

    Actualités publiées (les archivées restent en base), les plus récentes d'abord."""

    serializer_class = ActualiteSerializer

    def get_queryset(self):
        publiees = _filtrer_categorie(
            self.request, Actualite.objects.filter(statut='publie'), actualites.CATEGORIES, 'categorie',
        )
        return publiees.order_by(F('date_publication').desc(nulls_last=True), '-created_at')
