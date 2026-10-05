"""POST /internal/recommendations (PARTIE 8)."""
import json
import logging

from django.utils import timezone
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

from ia import llm_gateway
from ia.prompts import construire_messages_explications_groupees, parser_explications_groupees

from .models import Recommandation
from .scoring import generer_recommandations

logger = logging.getLogger(__name__)


def _generer_explications(resultats, profil):
    """Une explication par formation, en UN SEUL appel LLM (voir ia/prompts.py) : sur un LLM
    local CPU, dix appels séquentiels prendraient plusieurs minutes."""
    messages = construire_messages_explications_groupees(resultats, profil)
    try:
        # ~40 tokens/formation suffisent largement pour "1 phrase" et bornent le temps de
        # génération sur un LLM local CPU (sans ça, le modèle peut partir dans de longues
        # réponses malgré la consigne, avec un vrai risque de timeout HTTP en aval).
        reponse = llm_gateway.generer_reponse_sync(
            messages, temperature=0.4, max_tokens=40 * len(resultats)
        )
    except llm_gateway.LLMIndisponibleError as exc:
        logger.warning('Explications LLM indisponibles : %s', exc)
        return [None] * len(resultats)
    return parser_explications_groupees(reponse, len(resultats))


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

    resultats = generer_recommandations(profil, limite=5)
    if not resultats:
        return JsonResponse({'data': [], 'message': 'Aucune formation disponible pour le moment.'})

    maintenant = timezone.now()
    explications = _generer_explications(resultats, profil)

    donnees = []
    recommandations_a_creer = []

    for resultat, explication in zip(resultats, explications):
        formation = resultat['formation']

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
        })

    Recommandation.objects.bulk_create(recommandations_a_creer)

    return JsonResponse({'data': donnees})
