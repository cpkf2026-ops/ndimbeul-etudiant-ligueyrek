"""
Sécurité interne (PARTIE 3 du cahier des charges) : toutes les routes /internal/*
doivent porter le header X-Internal-Key, identique à DJANGO_IA_INTERNAL_KEY côté
Laravel (backend/.env). Ce service n'est jamais exposé publiquement — ce header
est la seule barrière entre Laravel et Django.
"""
import hmac

from django.conf import settings
from django.http import JsonResponse


class InternalKeyMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path.startswith('/internal/'):
            reponse_invalide = self._verifier_cle(request)
            if reponse_invalide is not None:
                return reponse_invalide
        return self.get_response(request)

    @staticmethod
    def _verifier_cle(request):
        cle_attendue = settings.INTERNAL_API_KEY
        cle_recue = request.headers.get('X-Internal-Key', '')

        if not cle_attendue:
            return JsonResponse(
                {'error': "INTERNAL_API_KEY n'est pas configurée côté Django (.env)."}, status=500
            )

        if not cle_recue or not hmac.compare_digest(cle_recue, cle_attendue):
            return JsonResponse({'error': 'Clé interne (X-Internal-Key) absente ou invalide.'}, status=401)

        return None
