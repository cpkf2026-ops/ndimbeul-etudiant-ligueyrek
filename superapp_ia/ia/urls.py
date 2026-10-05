from django.urls import path

from . import views

urlpatterns = [
    path('chat', views.chat, name='ia-chat'),
    path('documents/index', views.documents_index, name='ia-documents-index'),
    path('quality-metrics', views.quality_metrics, name='ia-quality-metrics'),
    path('health', views.health, name='ia-health'),
]
