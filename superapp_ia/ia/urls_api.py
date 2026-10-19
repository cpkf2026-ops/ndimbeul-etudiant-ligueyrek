from django.urls import path

from . import views

urlpatterns = [
    path('chat/', views.ChatView.as_view(), name='ia-chat-json'),
    # Version en streaming (SSE) déjà utilisée par l'application : le texte s'affiche
    # au fur et à mesure de sa génération.
    path('chat/stream/', views.chat, name='ia-chat-stream'),
]
