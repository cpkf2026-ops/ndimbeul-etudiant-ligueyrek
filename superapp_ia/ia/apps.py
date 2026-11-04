import sys
import time
import threading

from django.apps import AppConfig


class IaConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ia'
    verbose_name = 'Assistant IA (RAG + Ollama)'

    def ready(self):
        # Au démarrage de `runserver`, le modèle d'embeddings (torch, ~1 Go) est chargé en
        # arrière-plan, 2 min après le lancement (voir _precharger) : sans lui, la première
        # recommandation attendait ~45 s de chargement et dépassait le délai de 30 s de
        # l'application. Le modèle de chat Ollama, lui, se charge à la première question.
        if 'runserver' not in sys.argv:
            return

        def _precharger():
            # Attente avant de charger quoi que ce soit : au lancement de l'application,
            # Laravel, Celery, Chrome… démarrent en même temps ; tout charger d'un coup
            # figeait la machine (21/10/2026).
            time.sleep(120)
            # Modèle de comparaison passions/formations (~1 Go, ~45 s) : chargé en arrière-plan
            # pour que les recommandations de l'écran Orientation répondent en quelques
            # secondes. Le modèle de chat (Ollama, ~2-3 Go) n'est PLUS préchargé : il se
            # charge à la première question (~10-20 s) et se décharge après 5 min sans usage.
            from .embeddings import get_model
            get_model()

        threading.Thread(target=_precharger, daemon=True).start()
