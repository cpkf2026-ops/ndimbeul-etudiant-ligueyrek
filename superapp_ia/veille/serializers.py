"""Représentation JSON des données de veille renvoyées à Laravel."""
from rest_framework import serializers

from .models import Actualite, OffreEmploi


class OpportuniteSerializer(serializers.ModelSerializer):
    """Les noms de champs suivent le cahier des charges (titre, organisme, catégorie,
    lieu…), même si les colonnes de la table Laravel portent des noms historiques."""

    titre = serializers.CharField(source='intitule')
    organisme = serializers.CharField(source='entreprise')
    categorie = serializers.CharField(source='type')
    lieu = serializers.CharField(source='region')
    resume = serializers.SerializerMethodField()
    url_source = serializers.CharField(source='source_url')

    class Meta:
        model = OffreEmploi
        fields = [
            'id', 'titre', 'organisme', 'categorie', 'lieu', 'domaine', 'niveau_requis',
            'date_limite', 'resume', 'url_source', 'source', 'fiabilite',
            'date_publication', 'date_collecte',
        ]

    def get_resume(self, offre):
        # Offres collectées avant le module Tavily : pas de résumé, on reprend la description.
        return offre.resume or offre.description


class ActualiteSerializer(serializers.ModelSerializer):
    resume = serializers.CharField(source='contenu')
    url_source = serializers.CharField(source='source_url')
    source = serializers.CharField(source='source_nom')

    class Meta:
        model = Actualite
        fields = [
            'id', 'titre', 'resume', 'categorie', 'url_source', 'image_url', 'source',
            'fiabilite', 'date_publication',
        ]
