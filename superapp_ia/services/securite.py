"""
Sécurité de l'intégration Laravel → Django (§ 6 du cahier des charges).

Ce service n'est appelé QUE par Laravel. Toute requête vers /api/ia/* (et les
anciennes routes /internal/*) doit porter l'en-tête X-Service-Token, égal à
LARAVEL_SHARED_TOKEN (même valeur que DJANGO_IA_INTERNAL_KEY dans backend/.env).

L'ancien en-tête X-Internal-Key reste accepté pendant la transition, pour que le
client Laravel actuel continue de fonctionner jusqu'à sa mise à jour.
"""
import hmac

from django.conf import settings
from django.http import JsonResponse

PREFIXES_PROTEGES = ('/api/ia/', '/internal/')


def jeton_recu(request):
    return request.headers.get('X-Service-Token') or request.headers.get('X-Internal-Key') or ''


class ServiceTokenMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path.startswith(PREFIXES_PROTEGES):
            refus = self._verifier(request)
            if refus is not None:
                return refus
        return self.get_response(request)

    @staticmethod
    def _verifier(request):
        attendu = settings.LARAVEL_SHARED_TOKEN
        if not attendu:
            return JsonResponse({
                'erreur': 'configuration',
                'message': "LARAVEL_SHARED_TOKEN n'est pas configuré dans le .env du service IA.",
            }, status=500)

        recu = jeton_recu(request)
        # compare_digest : comparaison en temps constant (pas de fuite par mesure du temps).
        if not recu or not hmac.compare_digest(recu, attendu):
            return JsonResponse({
                'erreur': 'non_autorise',
                'message': 'En-tête X-Service-Token absent ou invalide.',
            }, status=401)
        return None
