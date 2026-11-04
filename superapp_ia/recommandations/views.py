"""POST /internal/recommendations (PARTIE 8) et POST /api/ia/orientation/ (module 1)."""
import json
import logging

from django.db import DatabaseError
from django.utils import timezone
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from rest_framework.response import Response
from rest_framework.views import APIView

from . import orientation
from .models import Recommandation
from .scoring import generer_recommandations
from .serializers import OrientationEntreeSerializer

logger = logging.getLogger(__name__)


def _generer_explications(resultats, profil):
    """Une justification par formation, construite à partir du détail de son score
    (série, moyenne, passions, région, bourse) : instantané et toujours exact.

    Avant : le modèle local rédigeait ces explications. Mesuré le 18/10/2026 sur le PC de
    démonstration : ~4 min pour 5 formations, alors que l'application n'attend que 30 s,
    donc les recommandations n'arrivaient jamais après une mise à jour du profil."""
    donnees = {
        'serie_bac': profil.get('serie_bac') or '',
        'moyenne': profil.get('moyenne_generale'),
        'passions': list(profil.get('passions') or []),
        'ville': profil.get('region_cible'),
    }
    contexte = {'mobilite': bool(profil.get('mobilite'))}
    return [orientation.justifier_formation(r, donnees, contexte) for r in resultats]


@csrf_exempt
@require_http_methods(['POST'])
def recommendations(request):
    try:
        payload = json.loads(request.body or '{}')
    except (json.JSONDecodeError, UnicodeDecodeError):
        return JsonResponse({'error': 'Corps JSON invalide (encodage ou syntaxe).'}, status=400)

    utilisateur_id = payload.get('utilisateur_id')
    profil = payload.get('profil') or {}
    if not utilisateur_id:
        return JsonResponse({'error': 'Le champ "utilisateur_id" est requis.'}, status=400)

    # Catalogue élargi : formations détaillées + établissements qui proposent un domaine d'après
    # leur fiche ; au plus 2 propositions par établissement pour garder de la variété.
    resultats = generer_recommandations(profil, limite=8, inclure_domaines=True, max_par_etablissement=2)
    if not resultats:
        return JsonResponse({'data': [], 'message': 'Aucune formation disponible pour le moment.'})

    maintenant = timezone.now()
    explications = _generer_explications(resultats, profil)

    donnees = []
    recommandations_a_creer = []

    for resultat, explication in zip(resultats, explications):
        formation = resultat['formation']
        est_domaine = getattr(formation, 'est_domaine', False)

        # L'historique (table recommandations) référence une vraie formation : un domaine de
        # fiche n'y est pas enregistré, il est seulement renvoyé à l'application.
        if not est_domaine:
            recommandations_a_creer.append(Recommandation(
                utilisateur_id=utilisateur_id,
                formation_id=formation.id,
                score_correspondance=resultat['score'],
                explication_llm=explication,
                sources_infos={'details_score': resultat['details']},
                date_generation=maintenant,
            ))

        donnees.append({
            'formation_id': str(formation.id),
            'intitule': formation.intitule,
            'niveau': formation.niveau,
            'domaine': formation.domaine,
            'universite': {
                'id': str(formation.universite_id),
                'nom': formation.universite.nom,
                'region': formation.universite.region,
                'type': formation.universite.type,
            },
            'conditions_admission': {
                'series_acceptees': formation.series_acceptees,
                'moyenne_minimale': formation.moyenne_minimale,
                'prerequis': formation.prerequis,
            },
            'debouches': formation.debouches,
            # Fiche complète de l'établissement (formations, filières, etc.) — Flutter
            # navigue vers /universities/{id}, la formation n'a pas d'écran dédié séparé.
            'lien_fiche': f'/universities/{formation.universite_id}',
            'score_correspondance': resultat['score'],
            'details_score': resultat['details'],
            'explication': explication,
            # « formation » (programme détaillé en base) ou « domaine » (domaine affiché sur la
            # fiche de l'établissement, conditions d'admission à vérifier).
            'type_proposition': 'domaine' if est_domaine else 'formation',
            'domaines_communs': resultat.get('domaines_communs', []),
        })

    # L'historique est un plus : s'il ne peut pas être enregistré, l'élève reçoit quand même
    # ses recommandations (avant : erreur 500 et page Orientation vide).
    try:
        Recommandation.objects.bulk_create(recommandations_a_creer)
    except DatabaseError as exc:
        logger.warning('Historique des recommandations non enregistré (%s) : %s', utilisateur_id, exc)

    return JsonResponse({'data': donnees})


# --------------------------------------------------------------------------
# POST /api/ia/orientation/  (module 1 du service IA)
# --------------------------------------------------------------------------

class OrientationView(APIView):
    """Recommandations personnalisées : métiers, formations et universités, chacun avec
    une justification, un score de compatibilité 0-100 et un lien source."""

    def post(self, request):
        entree = OrientationEntreeSerializer(data=request.data)
        entree.is_valid(raise_exception=True)
        return Response(orientation.recommander(entree.validated_data))
