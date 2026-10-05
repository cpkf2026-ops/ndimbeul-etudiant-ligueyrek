"""
Indexe les fiches universités de démonstration (PARTIE 4 du cahier des charges) dans
FAISS, pour pouvoir tester /internal/chat sans attendre un vrai import PDF via Laravel.

Usage :
    python manage.py seed_rag_demo            # indexe (ou ré-indexe) les 8 fiches
    python manage.py seed_rag_demo --reset     # supprime d'abord les anciennes versions
"""
import json
import pathlib

from django.conf import settings
from django.core.management.base import BaseCommand
from django.utils import timezone

from ia.models import DocumentRAG, SourceDonnee
from ia.rag_pipeline import indexer_document
from recommandations.models import Universite

SAMPLE_DOCS_DIR = pathlib.Path(__file__).resolve().parent.parent.parent / 'sample_docs'

# code_unique=None pour les universités qui n'ont pas (encore) de ligne dans la table
# `universites` gérée par Laravel : la fiche RAG reste indexable indépendamment
# (source_donnee.universite_id restera NULL pour celles-là).
FICHES = [
    {'fichier': 'ucad.txt', 'titre': 'Université Cheikh Anta Diop (UCAD)', 'code_unique': 'UCAD'},
    {'fichier': 'ugb.txt', 'titre': 'Université Gaston Berger (UGB)', 'code_unique': 'UGB'},
    {'fichier': 'isep_thies.txt', 'titre': "Institut Supérieur d'Enseignement Professionnel (ISEP)", 'code_unique': 'ISEP'},
    {'fichier': 'ism_dakar.txt', 'titre': 'Institut Supérieur de Management (ISM)', 'code_unique': 'ISM'},
    {'fichier': 'unchk_diourbel.txt', 'titre': 'Université Numérique Cheikh Hamidou Kane (UN-CHK)', 'code_unique': 'UNCHK'},
    {'fichier': 'uasz_ziguinchor.txt', 'titre': 'Université Assane Seck de Ziguinchor (UASZ)', 'code_unique': None},
    {'fichier': 'uadb_bambey.txt', 'titre': 'Université Alioune Diop de Bambey (UADB)', 'code_unique': None},
    {'fichier': 'ussein_kaolack.txt', 'titre': 'Université du Sine Saloum (USSEIN)', 'code_unique': None},
]
CATEGORIE = 'formations'


class Command(BaseCommand):
    help = 'Indexe les fiches universités de démonstration dans FAISS (PARTIE 4).'

    def add_arguments(self, parser):
        parser.add_argument(
            '--reset', action='store_true', help='Supprime les documents déjà indexés avant de réindexer.'
        )

    def handle(self, *args, **options):
        if options['reset']:
            titres = [f['titre'] for f in FICHES]
            supprimes, _ = DocumentRAG.objects.filter(titre__in=titres).delete()
            self.stdout.write(f'{supprimes} ancien(s) document(s) supprimé(s).')

        for fiche in FICHES:
            chemin = SAMPLE_DOCS_DIR / fiche['fichier']
            if not chemin.exists():
                self.stderr.write(self.style.ERROR(f'Fichier introuvable : {chemin}'))
                continue

            texte = chemin.read_text(encoding='utf-8')

            universite_id = None
            if fiche['code_unique']:
                universite = Universite.objects.filter(code_unique=fiche['code_unique']).first()
                universite_id = universite.id if universite else None

            source = SourceDonnee.objects.create(
                universite_id=universite_id,
                type='pdf',
                url_ou_chemin=fiche['fichier'],
                categorie=CATEGORIE,
                statut='actif',
                date_dernier_crawl=timezone.now(),
            )
            document = DocumentRAG.objects.create(
                source=source, titre=fiche['titre'], contenu_texte=texte, date_indexation=timezone.now()
            )

            ids_faiss = indexer_document(document, texte, categorie=CATEGORIE)
            document.nb_chunks = len(ids_faiss)
            document.vecteur_faiss_id = json.dumps(ids_faiss)
            document.version_embedding = settings.EMBEDDING_MODEL_NAME
            document.save(update_fields=['nb_chunks', 'vecteur_faiss_id', 'version_embedding', 'updated_at'])

            self.stdout.write(self.style.SUCCESS(f"  OK {fiche['titre']} -> {len(ids_faiss)} chunk(s)"))

        self.stdout.write(self.style.SUCCESS(f'Terminé : {len(FICHES)} fiches traitées.'))
