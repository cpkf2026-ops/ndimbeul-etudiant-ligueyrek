import sys
import threading

from django.apps import AppConfig


class IaConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ia'
    verbose_name = 'Assistant IA (RAG + Ollama)'

    def ready(self):
        # Au démarrage de `runserver`, on charge le modèle Ollama en mémoire (sinon le premier
        # message utilisateur paie le chargement, ~10-20 s) et on le garde chaud (keep_alive).
        #
        # Le modèle d'embeddings (torch, ~1 Go) est chargé en arrière-plan, sans bloquer le
        # démarrage : sans lui, la première recommandation attendait ~45 s de chargement et
        # dépassait le délai de 30 s de l'application.
        if 'runserver' not in sys.argv:
            return

        def _precharger():
            # Modèle de comparaison passions/formations (~1 Go, ~45 s) : chargé en arrière-plan
            # pour que les recommandations de l'écran Orientation répondent en quelques
            # secondes. Possible depuis le retrait de Mistral 7B (4,4 Go) sur ce PC.
            from .embeddings import get_model
            get_model()

            from . import llm_gateway
            llm_gateway.precharger_modele()

        threading.Thread(target=_precharger, daemon=True).start()
