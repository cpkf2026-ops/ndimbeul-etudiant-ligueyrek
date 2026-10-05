"""
Configuration Celery : exécute la veille internet en arrière-plan, à intervalle
régulier (voir CELERY_BEAT_SCHEDULE dans settings.py), sans bloquer les
requêtes /internal/* normales.

Lancement (2 process séparés, voir README.md) :
    celery -A superapp_ia worker -l info --pool=solo   # Windows : pas de fork, --pool=solo requis
    celery -A superapp_ia beat -l info
"""
import os

from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'superapp_ia.settings')

app = Celery('superapp_ia')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
