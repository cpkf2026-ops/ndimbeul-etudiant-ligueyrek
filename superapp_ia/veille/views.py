"""Endpoints de lecture de la veille (appelés par Laravel uniquement)."""
from django.db.models import F
from rest_framework.exceptions import ValidationError
from rest_framework.generics import ListAPIView
from rest_framework.response import Response
from rest_framework.views import APIView

from services import tavily_service

from . import actualites, back_office, commun, opportunites
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


class VeilleEtatView(APIView):
    """GET /api/ia/veille/etat/ — dernier passage de chaque veille (heure, trouvés, ajoutés)
    et heure prévue du prochain. Permet à l'application d'afficher « vérifié il y a 20 min,
    aucune nouveauté » au lieu de la seule date du dernier ajout."""

    def get(self, request):
        return Response({nom: commun.etat(nom) for nom in (actualites.NOM, opportunites.NOM)})


class RechercheEtablissementView(APIView):
    """POST /api/ia/back-office/etablissement/ {"nom": "..."} — proposition de fiche
    (site, description extraite, statut prouvé ou vide, lieu, images, sources, doublons)."""

    def post(self, request):
        nom = str(request.data.get('nom') or '').strip()
        if len(nom) < 3:
            raise ValidationError({'nom': 'Indiquez le nom de l\'établissement (3 caractères au moins).'})
        try:
            return Response(back_office.rechercher_etablissement(nom))
        except tavily_service.TavilyIndisponibleError as exc:
            return Response({'erreur': f'Recherche web indisponible : {exc}'}, status=503)


class AnalyseLienView(APIView):
    """POST /api/ia/back-office/lien/ {"url": "...", "genre": "actualite"|"offre"} —
    titre, résumé, date, image (et pour une offre : type, organisme, lieu, date limite)."""

    def post(self, request):
        genre = request.data.get('genre')
        if genre not in ('actualite', 'offre'):
            raise ValidationError({'genre': 'Valeurs possibles : actualite, offre.'})
        try:
            return Response(back_office.analyser_lien(request.data.get('url'), genre))
        except ValueError as exc:
            raise ValidationError({'url': str(exc)}) from exc


class PublicationView(APIView):
    """POST /api/ia/back-office/publier/ {"genre": "etablissement"|"actualite"|"offre", "donnees": {...}}
    Enregistre la proposition RELUE par l'administrateur, comme le fait la veille IA."""

    FONCTIONS = {'etablissement': 'publier_etablissement', 'actualite': 'publier_actualite', 'offre': 'publier_offre'}

    def post(self, request):
        genre = request.data.get('genre')
        if genre not in self.FONCTIONS:
            raise ValidationError({'genre': 'Valeurs possibles : etablissement, actualite, offre.'})
        donnees = request.data.get('donnees') or {}
        try:
            return Response(getattr(back_office, self.FONCTIONS[genre])(donnees), status=201)
        except back_office.PublicationRefusee as exc:
            return Response({'erreur': str(exc)}, status=409)
