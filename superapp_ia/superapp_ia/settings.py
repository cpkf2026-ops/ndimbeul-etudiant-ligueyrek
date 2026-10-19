"""
Réglages Django du micro-service IA de Ndimbeul-Etudiant.

Ce service n'est JAMAIS exposé directement à Flutter : seul Laravel l'appelle,
en HTTP interne, avec l'en-tête X-Service-Token (voir services/securite.py).
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

# Secret partagé avec backend/.env (DJANGO_IA_INTERNAL_KEY) — voir services/securite.py.
# INTERNAL_API_KEY : ancien nom de la variable, encore lu pour ne rien casser.
LARAVEL_SHARED_TOKEN = os.getenv('LARAVEL_SHARED_TOKEN') or os.getenv('INTERNAL_API_KEY', '')

INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'ia',
    'recommandations',
    'veille',
    'services',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'services.securite.ServiceTokenMiddleware',
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
    # Format d'erreur unique {"erreur", "message"} (voir services/erreurs.py).
    'EXCEPTION_HANDLER': 'services.erreurs.gestionnaire_exceptions',
    # Le service n'a pas de comptes utilisateurs : l'authentification est le jeton
    # Laravel, vérifié par le middleware avant même d'arriver aux vues.
    'DEFAULT_AUTHENTICATION_CLASSES': [],
    'DEFAULT_PERMISSION_CLASSES': [],
    'UNAUTHENTICATED_USER': None,
    'DEFAULT_PAGINATION_CLASS': 'services.pagination.PaginationIA',
}

# Communication interne uniquement (Laravel -> Django) : pas d'appel navigateur prévu,
# mais on garde la possibilité de whitelister des origines pour les tests (Postman/Swagger).
CORS_ALLOWED_ORIGINS = _env_list('CORS_ALLOWED_ORIGINS', '')
CORS_ALLOW_ALL_ORIGINS = False

# --- Ollama (LLM local — voir services/llm_service.py) ---
# OLLAMA_BASE_URL (avec /v1) : ancien nom, encore lu si OLLAMA_URL est absent.
OLLAMA_BASE_URL = os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434/v1')
OLLAMA_URL = (os.getenv('OLLAMA_URL') or OLLAMA_BASE_URL).rstrip('/').removesuffix('/v1')
OLLAMA_API_KEY = os.getenv('OLLAMA_API_KEY', 'ollama')
# Veille automatique (Celery, sans contrainte de temps). Par défaut le même modèle léger
# que le chat : un seul modèle en mémoire (2,7 Go), indispensable sur un PC de 8-10 Go.
# Sur un PC de 16 Go ou plus, mistral:7b-instruct rédige mieux (4,4 Go en plus).
OLLAMA_MODEL = os.getenv('OLLAMA_MODEL', 'qwen3.5:2b')
# Chatbot et orientation (réponse < 30 s exigée) : modèle léger, rapide sur CPU.
OLLAMA_MODEL_RAPIDE = os.getenv('OLLAMA_MODEL_RAPIDE', 'qwen3.5:2b')
# La veille partage le CPU avec le chat : elle n'utilise que N cœurs (0 = tous) et
# libère la RAM peu après son passage (Mistral 7B occupe ~4,5 Go).
OLLAMA_VEILLE_NUM_THREAD = int(os.getenv('OLLAMA_VEILLE_NUM_THREAD', '4'))
OLLAMA_VEILLE_KEEP_ALIVE = os.getenv('OLLAMA_VEILLE_KEEP_ALIVE', '5m')

# --- Tavily (recherche web — voir services/tavily_service.py et services/credits.py) ---
TAVILY_API_KEY = os.getenv('TAVILY_API_KEY', '')
TAVILY_MONTHLY_LIMIT = int(os.getenv('TAVILY_MONTHLY_LIMIT', '1000'))
# Part du quota réservée au chatbot et à l'orientation (la veille s'arrête avant).
TAVILY_RESERVE_INTERACTIF = int(os.getenv('TAVILY_RESERVE_INTERACTIF', '200'))
TAVILY_TIMEOUT_SECONDES = int(os.getenv('TAVILY_TIMEOUT_SECONDES', '8'))

# --- Redis (broker Celery + cache des réponses fréquentes) ---
REDIS_URL = os.getenv('REDIS_URL') or os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': REDIS_URL,
        'KEY_PREFIX': 'ndimbeul',
        'TIMEOUT': 24 * 60 * 60,
        # Délais courts : si Redis est arrêté, on l'apprend en 1 s au lieu de bloquer.
        'OPTIONS': {'socket_connect_timeout': 1, 'socket_timeout': 1},
    }
}

# --- RAG (voir ia/embeddings.py, ia/rag_pipeline.py) ---
EMBEDDING_MODEL_NAME = os.getenv('EMBEDDING_MODEL_NAME', 'paraphrase-multilingual-MiniLM-L12-v2')
RAG_TOP_K = int(os.getenv('RAG_TOP_K', '6'))
FAISS_INDEX_DIR = BASE_DIR / 'faiss_index'

# --- Cache des réponses (PARTIE 7 du cahier des charges) ---
CACHE_REPONSE_TTL_HEURES = int(os.getenv('CACHE_REPONSE_TTL_HEURES', '24'))
CACHE_ORIENTATION_TTL_JOURS = int(os.getenv('CACHE_ORIENTATION_TTL_JOURS', '7'))

# --- Orientation : budget de temps total (sous le timeout Laravel de 30 s) ---
ORIENTATION_TIMEOUT_SECONDES = int(os.getenv('ORIENTATION_TIMEOUT_SECONDES', '25'))

# --- Chatbot : budget de temps total (sous le timeout Laravel de 30 s) ---
CHAT_TIMEOUT_SECONDES = int(os.getenv('CHAT_TIMEOUT_SECONDES', '25'))
# Longueur maximale d'une réponse du chat. Le cahier des charges suggère ~300 tokens ;
# sur ce CPU (modèle 2-3B, ~7 tokens/s en écriture), 100 tokens tiennent dans le budget.
CHAT_NUM_PREDICT = int(os.getenv('CHAT_NUM_PREDICT', '100'))

# --- Veille internet (app veille) : recherche web (DuckDuckGo, voir veille/recherche_web.py)
# + classification LLM, alimente en tâche de fond les tables Laravel `actualites`,
# `offres_emploi` et `universites` (déjà lues par Flutter, aucun changement front requis). ---

# --- Celery (exécute la veille en arrière-plan, à intervalle régulier) ---
CELERY_BROKER_URL = REDIS_URL
CELERY_RESULT_BACKEND = REDIS_URL
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE

# Fréquence de la veille (§ 4) : toutes les VEILLE_INTERVAL_HOURS heures. En mode
# réduit (quota Tavily de la veille épuisé), les tâches ne travaillent qu'une fois
# toutes les VEILLE_INTERVAL_REDUIT_HOURS heures (voir services/credits.py).
# VEILLE_INTERVALLE_SECONDES : ancien réglage, encore lu s'il est seul présent.
VEILLE_INTERVAL_HOURS = float(
    os.getenv('VEILLE_INTERVAL_HOURS') or int(os.getenv('VEILLE_INTERVALLE_SECONDES', '7200')) / 3600
)
VEILLE_INTERVAL_REDUIT_HOURS = float(os.getenv('VEILLE_INTERVAL_REDUIT_HOURS', '6'))
# Fichiers « heure du dernier passage » partagés par Celery Beat et la tâche Windows.
VEILLE_ETAT_DIR = BASE_DIR / 'logs'
_INTERVALLE_VEILLE_SECONDES = int(VEILLE_INTERVAL_HOURS * 3600)
CELERY_BEAT_SCHEDULE = {
    'veille-actualites': {
        'task': 'veille.tasks.veille_actualites',
        'schedule': _INTERVALLE_VEILLE_SECONDES,
    },
    'veille-opportunites': {
        'task': 'veille.tasks.veille_opportunites',
        'schedule': _INTERVALLE_VEILLE_SECONDES,
    },
    # La veille quotidienne des universités a été retirée de la planification : elle se
    # déclenchait à chaque démarrage (dizaines de recherches web + LLM) et saturait le PC
    # au moment même où l'on lance l'application, pour une liste qui change rarement
    # (70 établissements déjà en base, gérés dans le back-office). Lancement manuel si besoin :
    #     python manage.py veiller --universites
}

# Journal du service (§ 6) : requêtes Tavily, crédits consommés, temps de réponse,
# erreurs. FileHandler simple (sans rotation) : sous Windows, Django, le worker et
# Beat écrivent dans le même fichier, et la rotation échouerait (fichier verrouillé).
LOGS_DIR = BASE_DIR / 'logs'
LOGS_DIR.mkdir(exist_ok=True)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'detaille': {'format': '%(asctime)s [%(levelname)s] %(name)s : %(message)s'},
    },
    'handlers': {
        'console': {'class': 'logging.StreamHandler', 'formatter': 'detaille'},
        'fichier': {
            'class': 'logging.FileHandler',
            'filename': LOGS_DIR / 'ia.log',
            'encoding': 'utf-8',
            'delay': True,
            'formatter': 'detaille',
        },
    },
    'root': {'handlers': ['console', 'fichier'], 'level': 'INFO'},
    # httpx et faiss sont trop bavards en INFO pour ia.log.
    'loggers': {'httpx': {'level': 'WARNING'}, 'faiss.loader': {'level': 'WARNING'}},
}
