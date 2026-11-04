"""Validation de l'entrée du module 4 (chatbot)."""
from rest_framework import serializers


class MessageHistoriqueSerializer(serializers.Serializer):
    role = serializers.ChoiceField(choices=['user', 'assistant'])
    # Assez long pour une liste complète d'établissements (jusqu'à ~100 lignes) renvoyée en historique.
    contenu = serializers.CharField(max_length=20000)
    # Sources de la réponse : permettent de comprendre « le site de CETTE université ».
    sources = serializers.ListField(child=serializers.DictField(), required=False)


class ChatEntreeSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=1000, trim_whitespace=True)
    # Utilisateur connecté : la conversation est enregistrée dans `conversations_ia`.
    utilisateur_id = serializers.CharField(max_length=36, required=False)
    conversation_id = serializers.CharField(max_length=36, required=False)
    profil = serializers.DictField(required=False)
    # Mode visiteur (pas de compte) : Laravel envoie lui-même les derniers échanges.
    historique = MessageHistoriqueSerializer(many=True, required=False)
