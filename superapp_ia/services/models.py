"""
Tables du socle IA, créées par les migrations Laravel
(backend/database/migrations/2026_10_18_00000{1,2}_*) : managed=False, comme
tous les modèles de ce service (voir ia/models.py).
"""
from django.db import models

from ia.models import nouvel_uuid


class CreditTavily(models.Model):
    """Consommation de crédits Tavily pour une journée (voir services/credits.py)."""

    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    jour = models.DateField(unique=True)
    credits_veille = models.PositiveIntegerField(default=0)
    credits_interactif = models.PositiveIntegerField(default=0)
    nb_requetes = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'credits_tavily'

    def __str__(self):
        return f'{self.jour} : {self.credits_veille + self.credits_interactif} crédit(s)'


class SourceConfiance(models.Model):
    """Domaine de confiance transmis à Tavily (include_domains), voir services/sources.py."""

    CATEGORIE_CHOICES = [
        ('orientation', 'orientation'), ('emploi', 'emploi'), ('actualites', 'actualites'),
    ]

    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    domaine = models.CharField(max_length=120)
    nom = models.CharField(max_length=255, null=True, blank=True)
    categorie = models.CharField(max_length=20, choices=CATEGORIE_CHOICES)
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'sources_confiance'
        unique_together = [('domaine', 'categorie')]

    def __str__(self):
        return f'{self.domaine} ({self.categorie})'
