"""
Réglages Django du micro-service IA de Ndimbeul-Etudiant.

Ce service n'est JAMAIS exposé directement à Flutter : seul Laravel l'appelle,
en HTTP interne, avec le header X-Internal-Key (voir ia/middleware.py).
"""
from pathlib import Path
import os

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / '.env')


def _env_bool(name, default=False):
    return os.getenv(name, str(default)).strip().lower() in ('1', 'true', 'yes', 'on')


def _env_list(name, default=''):
    raw = os.getenv(name, default)
    return [item.strip() for item in raw.split(',') if item.strip()]


SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'insecure-dev-key-a-changer')
DEBUG = _env_bool('DJANGO_DEBUG', True)
ALLOWED_HOSTS = _env_list('DJANGO_ALLOWED_HOSTS', '127.0.0.1,localhost')

# Clé partagée avec backend/.env (DJANGO_IA_INTERNAL_KEY) — voir ia/middleware.py.
INTERNAL_API_KEY = os.getenv('INTERNAL_API_KEY', '')

INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'ia',
    'recommandations',
    'veille',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'ia.middleware.InternalKeyMiddleware',
]

ROOT_URLCONF = 'superapp_ia.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {'context_processors': []},
    },
]

WSGI_APPLICATION = 'superapp_ia.wsgi.application'
ASGI_APPLICATION = 'superapp_ia.asgi.application'

# Base MySQL PARTAGÉE avec Laravel (mêmes tables : documents_rag, conversations_ia,
# cache_reponses, recommandations, formations, universites, bourses, frais_scolarite...).
# Tous les modèles Django qui pointent vers ces tables sont managed=False : c'est
# Laravel qui possède les migrations, Django ne fait que lire/écrire les lignes.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('DB_NAME', 'backendpff'),
        'USER': os.getenv('DB_USER', 'root'),
        'PASSWORD': os.getenv('DB_PASSWORD', ''),
        'HOST': os.getenv('DB_HOST', '127.0.0.1'),
        'PORT': os.getenv('DB_PORT', '3306'),
        'OPTIONS': {'charset': 'utf8mb4'},
    }
}

# Aucune app Django "système" (auth/admin/sessions) n'est installée : ce service
# n'a pas d'interface d'administration ni de comptes utilisateurs propres, et on
# évite ainsi de polluer la base partagée avec des tables Django (auth_user, etc.).
AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = 'fr'
TIME_ZONE = 'Africa/Dakar'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

REST_FRAMEWORK = {
    'DEFAULT_RENDERER_CLASSES': ['rest_framework.renderers.JSONRenderer'],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
        'rest_framework.parsers.MultiPartParser',
        'rest_framework.parsers.FormParser',
    ],
}

# Communication interne uniquement (Laravel -> Django) : pas d'appel navigateur prévu,
# mais on garde la possibilité de whitelister des origines pour les tests (Postman/Swagger).
CORS_ALLOWED_ORIGINS = _env_list('CORS_ALLOWED_ORIGINS', '')
CORS_ALLOW_ALL_ORIGINS = False

# --- Ollama (LLM local — voir ia/llm_gateway.py) ---
OLLAMA_BASE_URL = os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434/v1')
OLLAMA_API_KEY = os.getenv('OLLAMA_API_KEY', 'ollama')
OLLAMA_MODEL = os.getenv('OLLAMA_MODEL', 'mistral:7b-instruct')

# --- RAG (voir ia/embeddings.py, ia/rag_pipeline.py) ---
EMBEDDING_MODEL_NAME = os.getenv('EMBEDDING_MODEL_NAME', 'paraphrase-multilingual-MiniLM-L12-v2')
RAG_TOP_K = int(os.getenv('RAG_TOP_K', '6'))
FAISS_INDEX_DIR = BASE_DIR / 'faiss_index'

# --- Cache des réponses (PARTIE 7 du cahier des charges) ---
CACHE_REPONSE_TTL_HEURES = int(os.getenv('CACHE_REPONSE_TTL_HEURES', '24'))

# --- Veille internet (app veille) : recherche web (DuckDuckGo, voir veille/recherche_web.py)
# + classification LLM, alimente en tâche de fond les tables Laravel `actualites`,
# `offres_emploi` et `universites` (déjà lues par Flutter, aucun changement front requis). ---

# --- Celery (exécute la veille en arrière-plan, à intervalle régulier) ---
CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')
CELERY_RESULT_BACKEND = os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE
CELERY_BEAT_SCHEDULE = {
    'veille-actualites-toutes-les-2h': {
        'task': 'veille.tasks.veiller_actualites_task',
        'schedule': int(os.getenv('VEILLE_INTERVALLE_SECONDES', str(2 * 60 * 60))),
    },
    'veille-offres-toutes-les-2h': {
        'task': 'veille.tasks.veiller_offres_task',
        'schedule': int(os.getenv('VEILLE_INTERVALLE_SECONDES', str(2 * 60 * 60))),
    },
    'veille-universites-quotidienne': {
        'task': 'veille.tasks.veiller_universites_task',
        # La liste des établissements change rarement : un passage par jour suffit
        # largement (contrairement aux actualités/offres, plus volatiles).
        'schedule': int(os.getenv('VEILLE_UNIVERSITES_INTERVALLE_SECONDES', str(24 * 60 * 60))),
    },
}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {'console': {'class': 'logging.StreamHandler'}},
    'root': {'handlers': ['console'], 'level': 'INFO'},
}
