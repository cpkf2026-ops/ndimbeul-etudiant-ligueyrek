"""
Réglages des tests : SQLite en mémoire et cache local, pour que les tests
tournent sans MySQL, Redis, Ollama ni Tavily (tous deux mockés).

Lancement :
    venv\\Scripts\\python manage.py test tests --settings=tests.settings_test
"""
import tempfile

from superapp_ia.settings import *  # noqa: F401,F403

DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3', 'NAME': ':memory:'}}
CACHES = {'default': {'BACKEND': 'django.core.cache.backends.locmem.LocMemCache'}}

# Les apps n'ont pas de migrations Django (le schéma appartient à Laravel) : on
# crée les tables directement à partir des modèles (voir tests/runner.py).
MIGRATION_MODULES = {app: None for app in ('ia', 'recommandations', 'veille', 'services')}
TEST_RUNNER = 'tests.runner.RunnerModelesNonGeres'

LARAVEL_SHARED_TOKEN = 'jeton-de-test'
TAVILY_API_KEY = 'tvly-test'
TAVILY_MONTHLY_LIMIT = 1000
TAVILY_RESERVE_INTERACTIF = 200
OLLAMA_URL = 'http://ollama-test:11434'
CELERY_TASK_ALWAYS_EAGER = True

# Pas d'écriture dans logs/ia.log pendant les tests.
LOGGING = {'version': 1, 'disable_existing_loggers': False, 'root': {'level': 'CRITICAL'}}

# Heure des derniers passages de veille : dossier temporaire, vidé avant chaque test de veille.
VEILLE_ETAT_DIR = tempfile.mkdtemp(prefix='ndimbeul_veille_')
