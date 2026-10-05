import sys
import threading

from django.apps import AppConfig


class IaConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ia'
    verbose_name = 'Assistant IA (RAG + Ollama)'

    def ready(self):
        # Le modèle sentence-transformers met ~30-40s à charger la première fois
        # (import torch/transformers + poids). Sans préchargement, ce coût tombe sur la
        # toute première requête chat/recommandation après chaque démarrage serveur, et
        # dépasse alors le timeout du client (Flutter/Laravel) — ce qui donnait l'impression
        # que le chat "ne marche pas". On le charge donc en tâche de fond dès le démarrage.
        # Uniquement pour `runserver` : pas pour `manage.py shell`/`migrate`/`veiller`/celery,
        # qui n'ont pas besoin du modèle et seraient inutilement ralentis au démarrage.
        if 'runserver' not in sys.argv:
            return

        def _precharger():
            from .embeddings import get_model
            get_model()

            # Force aussi le chargement du modèle Ollama en mémoire dès le démarrage (sinon
            # le premier message utilisateur paie le rechargement, ~10-20s) et le garde chaud
            # (keep_alive) pour que les messages suivants restent rapides.
            from . import llm_gateway
            llm_gateway.precharger_modele()

        threading.Thread(target=_precharger, daemon=True).start()
