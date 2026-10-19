"""
Modèles Django mappés sur les tables MySQL Laravel déjà existantes (managed=False).

Formation / Universite / Bourse / FraisScolarite sont en LECTURE SEULE : ces tables
sont administrées côté back-office Laravel. Seule Recommandation est écrite par Django
(résultat du moteur de scoring), lue ensuite par Laravel pour l'API /ai/recommendations.

CharField(36) plutôt que UUIDField : sur MySQL, UUIDField sérialise en hex 32
caractères SANS tirets, incompatible avec les colonnes CHAR(36) à tirets créées
par les migrations Laravel (voir ia/models.py pour le détail du problème).
"""
from ia.models import nouvel_uuid

from django.db import models


class Universite(models.Model):
    id = models.CharField(max_length=36, primary_key=True)
    nom = models.CharField(max_length=255)
    code_unique = models.CharField(max_length=50)
    region = models.CharField(max_length=255, null=True, blank=True)
    commune = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(max_length=10)  # public | prive
    site_web_officiel = models.CharField(max_length=255, null=True, blank=True)
    statut_actif = models.BooleanField(default=True)

    class Meta:
        managed = False
        db_table = 'universites'

    def __str__(self):
        return self.nom


class Formation(models.Model):
    NIVEAU_CHOICES = [('bts', 'bts'), ('licence', 'licence'), ('master', 'master'), ('doctorat', 'doctorat')]

    id = models.CharField(max_length=36, primary_key=True)
    universite = models.ForeignKey(
        Universite, db_column='universite_id', on_delete=models.DO_NOTHING, related_name='formations'
    )
    intitule = models.CharField(max_length=255)
    domaine = models.CharField(max_length=255, null=True, blank=True)
    niveau = models.CharField(max_length=20, choices=NIVEAU_CHOICES)
    duree_annees = models.PositiveSmallIntegerField(null=True, blank=True)
    series_acceptees = models.JSONField(null=True, blank=True)
    moyenne_minimale = models.DecimalField(max_digits=4, decimal_places=2, null=True, blank=True)
    capacite = models.PositiveIntegerField(null=True, blank=True)
    prerequis = models.TextField(null=True, blank=True)
    debouches = models.TextField(null=True, blank=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'formations'

    def __str__(self):
        return self.intitule


class Bourse(models.Model):
    id = models.CharField(max_length=36, primary_key=True)
    universite_id = models.CharField(max_length=36, null=True, blank=True)  # null = bourse nationale
    nom = models.CharField(max_length=255)
    montant = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    date_limite = models.DateField(null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'bourses'


class FraisScolarite(models.Model):
    id = models.CharField(max_length=36, primary_key=True)
    universite_id = models.CharField(max_length=36)
    formation_id = models.CharField(max_length=36, null=True, blank=True)
    montant = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        managed = False
        db_table = 'frais_scolarite'


class Recommandation(models.Model):
    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    utilisateur_id = models.CharField(max_length=36)
    formation_id = models.CharField(max_length=36)
    score_correspondance = models.DecimalField(max_digits=5, decimal_places=2)
    explication_llm = models.TextField(null=True, blank=True)
    sources_infos = models.JSONField(null=True, blank=True)
    date_generation = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'recommandations'
