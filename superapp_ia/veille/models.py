"""
Modèles Django mappés sur les tables `actualites` et `offres_emploi`, déjà
créées par les migrations Laravel (managed=False, voir ia/models.py pour le
choix CharField(36) plutôt que UUIDField sur MySQL).

Ce sont les tables que Flutter lit déjà (features/news, features/jobs) : la
veille internet n'a donc RIEN à changer côté app mobile, elle se contente d'y
écrire de nouvelles lignes.
"""
from ia.models import nouvel_uuid

from django.db import models


class Universite(models.Model):
    TYPE_CHOICES = [('public', 'public'), ('prive', 'prive')]

    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    nom = models.CharField(max_length=255)
    code_unique = models.CharField(max_length=255, unique=True)
    region = models.CharField(max_length=255, null=True, blank=True)
    commune = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES, default='public')
    site_web_officiel = models.CharField(max_length=255, null=True, blank=True)
    source = models.CharField(max_length=255, null=True, blank=True)
    date_verification = models.DateField(null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    image_url = models.CharField(max_length=255, null=True, blank=True)
    email_contact = models.CharField(max_length=255, null=True, blank=True)
    telephone_contact = models.CharField(max_length=255, null=True, blank=True)
    statut_actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'universites'

    def __str__(self):
        return self.nom


class Actualite(models.Model):
    CATEGORIE_CHOICES = [
        ('bourse', 'bourse'), ('concours', 'concours'), ('evenement', 'evenement'),
        ('formation', 'formation'), ('general', 'general'),
    ]
    STATUT_CHOICES = [('brouillon', 'brouillon'), ('publie', 'publie'), ('archive', 'archive')]

    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    titre = models.CharField(max_length=255)
    contenu = models.TextField()
    auteur_id = models.CharField(max_length=36, null=True, blank=True)
    categorie = models.CharField(max_length=20, choices=CATEGORIE_CHOICES, default='general')
    source_url = models.CharField(max_length=255, null=True, blank=True)
    image_url = models.CharField(max_length=255, null=True, blank=True)
    # DateTimeField (élargi depuis DateField) : stocke le jour ET l'heure réels de
    # publication quand extraits de l'article source (voir recherche_web.extraire_metadonnees_article).
    date_publication = models.DateTimeField(null=True, blank=True)
    # Média ou site officiel d'origine ('Seneweb', 'APS', 'mesri.gouv.sn') et niveau de
    # fiabilité de la source ('officiel' | 'presse'), voir veille/fiabilite.py.
    source_nom = models.CharField(max_length=120, null=True, blank=True)
    fiabilite = models.CharField(max_length=20, null=True, blank=True)
    cible_roles = models.JSONField(null=True, blank=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='brouillon')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'actualites'

    def __str__(self):
        return self.titre


class OffreEmploi(models.Model):
    TYPE_CHOICES = [
        ('emploi', 'emploi'), ('stage', 'stage'), ('alternance', 'alternance'),
        ('formation', 'formation'), ('bourse', 'bourse'), ('concours', 'concours'),
    ]
    STATUT_CHOICES = [('active', 'active'), ('expiree', 'expiree')]

    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    intitule = models.CharField(max_length=255)
    entreprise = models.CharField(max_length=255)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    domaine = models.CharField(max_length=255, null=True, blank=True)
    niveau_requis = models.CharField(max_length=255, null=True, blank=True)
    region = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    source_url = models.CharField(max_length=500)
    # Nom réel du média / de l'organisme d'origine, et niveau de fiabilité de la
    # source ('officiel' | 'presse' | 'plateforme'), voir veille/fiabilite.py.
    source = models.CharField(max_length=255, null=True, blank=True)
    fiabilite = models.CharField(max_length=20, null=True, blank=True)
    date_publication = models.DateField(null=True, blank=True)
    date_limite = models.DateField(null=True, blank=True)
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='active')
    date_indexation = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'offres_emploi'
        unique_together = [('source_url', 'intitule')]

    def __str__(self):
        return self.intitule
