"""
Format d'erreur unique de l'API : {"erreur": "<code>", "message": "<texte lisible>"}.

Laravel peut ainsi afficher `message` tel quel et décider selon `erreur`
(ex. « llm_indisponible » → proposer de réessayer plus tard).
Branché via REST_FRAMEWORK['EXCEPTION_HANDLER'] dans settings.py.
"""
import logging

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import exception_handler

from .llm_service import LLMIndisponibleError, LLMReponseInvalideError, LLMTimeoutError
from .tavily_service import QuotaTavilyAtteintError, TavilyIndisponibleError

logger = logging.getLogger(__name__)

# L'ordre compte : les sous-classes avant leur classe parente.
_ERREURS_METIER = [
    (QuotaTavilyAtteintError, status.HTTP_429_TOO_MANY_REQUESTS, 'quota_tavily_atteint'),
    (TavilyIndisponibleError, status.HTTP_503_SERVICE_UNAVAILABLE, 'tavily_indisponible'),
    (LLMTimeoutError, status.HTTP_504_GATEWAY_TIMEOUT, 'llm_timeout'),
    (LLMIndisponibleError, status.HTTP_503_SERVICE_UNAVAILABLE, 'llm_indisponible'),
    (LLMReponseInvalideError, status.HTTP_502_BAD_GATEWAY, 'llm_reponse_invalide'),
]


def gestionnaire_exceptions(exc, context):
    for classe, code_http, code in _ERREURS_METIER:
        if isinstance(exc, classe):
            logger.error('%s : %s', code, exc)
            return Response({'erreur': code, 'message': str(exc)}, status=code_http)

    # Erreurs DRF classiques (validation 400, 404, 405…) : on garde le détail par champ.
    reponse = exception_handler(exc, context)
    if reponse is not None:
        detail = reponse.data
        message = detail.get('detail') if isinstance(detail, dict) and 'detail' in detail else 'Requête invalide.'
        corps = {'erreur': getattr(exc, 'default_code', 'erreur'), 'message': str(message)}
        if not (isinstance(detail, dict) and set(detail) == {'detail'}):
            corps['details'] = detail
        reponse.data = corps
        return reponse

    # Erreur imprévue : tracée en entier dans logs/ia.log, message neutre pour le client.
    logger.exception('Erreur interne non gérée', exc_info=exc)
    return Response(
        {'erreur': 'erreur_interne', 'message': 'Erreur interne du service IA.'},
        status=status.HTTP_500_INTERNAL_SERVER_ERROR,
    )
