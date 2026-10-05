"""
Modèles Django mappés sur les tables MySQL déjà créées par les migrations Laravel
(voir backend/database/migrations/2026_01_01_00001{3,4}_*, 2026_01_01_000019_*,
2026_01_01_000005_*). managed=False partout : Django ne crée/modifie jamais ces
tables, il ne fait que lire et écrire des lignes dans la base partagée.

Les colonnes uuid Laravel sont des CHAR(36) au format standard avec tirets
("0b602647-5882-4373-901e-c3fcc562a14a"). On utilise volontairement CharField
plutôt que UUIDField : sur MySQL, UUIDField sérialise en hex 32 caractères SANS
tirets (Django suppose qu'il possède le schéma), ce qui casse silencieusement
toute contrainte de clé étrangère avec les tables Laravel.
"""
import uuid

from django.db import models


def nouvel_uuid():
    return str(uuid.uuid4())


class SourceDonnee(models.Model):
    TYPE_CHOICES = [('url', 'url'), ('pdf', 'pdf'), ('api', 'api')]
    STATUT_CHOICES = [('actif', 'actif'), ('erreur', 'erreur'), ('obsolete', 'obsolete')]

    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    universite_id = models.CharField(max_length=36, null=True, blank=True)
    admin_id = models.CharField(max_length=36, null=True, blank=True)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES, default='pdf')
    url_ou_chemin = models.CharField(max_length=500)
    categorie = models.CharField(max_length=255, null=True, blank=True)
    date_dernier_crawl = models.DateTimeField(null=True, blank=True)
    statut = models.CharField(max_length=10, choices=STATUT_CHOICES, default='actif')
    derniere_erreur = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'sources_donnees'

    def __str__(self):
        return f'{self.categorie or self.type} ({self.id})'


class DocumentRAG(models.Model):
    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    source = models.ForeignKey(
        SourceDonnee, db_column='source_id', on_delete=models.DO_NOTHING, related_name='documents'
    )
    titre = models.CharField(max_length=255, null=True, blank=True)
    contenu_texte = models.TextField()
    nb_chunks = models.PositiveIntegerField(default=0)
    date_indexation = models.DateTimeField(null=True, blank=True)
    version_embedding = models.CharField(max_length=255, null=True, blank=True)
    # Stocke la liste JSON des ids FAISS des chunks de ce document (ex: "[12,13,14]") :
    # la colonne Laravel est un simple string, un document pouvant produire plusieurs chunks/vecteurs.
    vecteur_faiss_id = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'documents_rag'

    def __str__(self):
        return self.titre or str(self.id)


class ConversationIA(models.Model):
    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    utilisateur_id = models.CharField(max_length=36)
    messages = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    date_derniere_activite = models.DateTimeField(null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'conversations_ia'

    def ajouter_message(self, role, contenu, sources=None):
        from django.utils import timezone

        messages = self.messages or []
        messages.append({
            'role': role,
            'contenu': contenu,
            'sources': sources or [],
            'date': timezone.now().isoformat(),
        })
        self.messages = messages
        self.date_derniere_activite = timezone.now()
        self.save(update_fields=['messages', 'date_derniere_activite', 'updated_at'])


class CacheReponse(models.Model):
    id = models.CharField(max_length=36, primary_key=True, default=nouvel_uuid, editable=False)
    question_hash = models.CharField(max_length=64, unique=True)
    reponse_json = models.JSONField()
    sources_utilisees = models.JSONField(null=True, blank=True)
    date_expiration = models.DateTimeField()
    nb_utilisations = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'cache_reponses'
