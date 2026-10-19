"""GET /api/ia/sante/ : état de chaque brique du service (pratique pour la démo)."""
from django.conf import settings
from django.db import DatabaseError, connection
from rest_framework.response import Response
from rest_framework.views import APIView

from . import cache, credits, llm_service


class SanteView(APIView):
    def get(self, request):
        try:
            with connection.cursor() as curseur:
                curseur.execute('SELECT 1')
            base_ok = True
        except DatabaseError:
            base_ok = False

        ollama = llm_service.etat()
        try:
            etat_credits = credits.etat()
        except DatabaseError:
            etat_credits = None

        statut = 'ok' if (base_ok and ollama['disponible']) else 'degrade'
        return Response({
            'statut': statut,
            'base_donnees': 'ok' if base_ok else 'erreur',
            'redis': 'ok' if cache.disponible() else 'indisponible',
            'ollama': ollama,
            'tavily': {
                'cle_configuree': bool(settings.TAVILY_API_KEY),
                'credits': etat_credits,
            },
        }, status=200 if statut == 'ok' else 503)
