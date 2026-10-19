"""
Endpoints /internal/* et /api/ia/chat/ exposés uniquement à Laravel (protégés par
services.securite.ServiceTokenMiddleware) : chat (PARTIE 7), indexation de documents
(PARTIE 4), métriques qualité et health check (PARTIE 9).
"""
import io
import json
import logging

import httpx
from django.conf import settings
from django.db import connection
from django.http import JsonResponse, StreamingHttpResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from rest_framework.response import Response
from rest_framework.views import APIView

from . import chatbot, rag_pipeline
from .models import CacheReponse, ConversationIA, DocumentRAG, SourceDonnee
from .serializers import ChatEntreeSerializer

logger = logging.getLogger(__name__)


# --------------------------------------------------------------------------
# POST /internal/chat  (PARTIE 7) : chat de l'application, relayé par Laravel à Flutter
# --------------------------------------------------------------------------
# Même cerveau que POST /api/ia/chat/ (ia/chatbot.py) : salutations et hors-sujet
# instantanés, recherche dans la base puis Tavily, contrôles anti-invention, cache Redis,
# réponse en moins de 30 s. Seul le FORMAT change : des événements SSE, que Flutter lit
# déjà ({"token": ...} puis {"done": true, "conversation_id", "sources"}).

def _sse(data):
    return f'data: {json.dumps(data, ensure_ascii=False)}\n\n'


def _stream_headers(response):
    # Pas de header "Connection" ici : c'est un header hop-by-hop que le serveur WSGI
    # gère lui-même (l'ajouter manuellement fait planter le serveur de dev de Django
    # avec une AssertionError - "Hop-by-hop header ... not allowed").
    response['Cache-Control'] = 'no-cache'
    response['X-Accel-Buffering'] = 'no'
    return response


def _erreur_sse(message, status=400):
    # AiProxyController::chat() relaie le corps de la réponse Django à Flutter tel
    # quel, quel que soit le status HTTP (il renvoie toujours 200 côté Laravel) : les
    # erreurs doivent donc déjà être au format SSE pour que le parseur Flutter les
    # affiche, plutôt qu'un JSON brut qu'il ignorerait silencieusement.
    reponse = StreamingHttpResponse(iter([_sse({'error': message})]), content_type='text/event-stream')
    reponse.status_code = status
    return _stream_headers(reponse)


@csrf_exempt
@require_http_methods(['POST'])
def chat(request):
    try:
        payload = json.loads(request.body or '{}')
    except (json.JSONDecodeError, UnicodeDecodeError):
        return _erreur_sse('Corps JSON invalide (encodage ou syntaxe).')

    message = (payload.get('message') or '').strip()
    if not message:
        return _erreur_sse('Le champ "message" est requis.')

    def generer():
        # Ligne de commentaire SSE envoyée tout de suite (ignorée par Flutter, qui ne lit
        # que les lignes « data: ») : la connexion est ouverte pendant que l'IA travaille.
        yield ': reponse en preparation\n\n'
        try:
            resultat = chatbot.repondre(
                message=message,
                conversation_id=payload.get('conversation_id'),
                utilisateur_id=payload.get('utilisateur_id'),
                profil=payload.get('profil') or {},
            )
        except Exception:  # erreur imprévue : tracée, message lisible pour l'élève
            logger.exception('Chat (SSE) : erreur interne')
            yield _sse({'error': "L'assistant a rencontré un problème. Réessaie dans un instant."})
            return
        yield _sse({'token': resultat['reponse']})
        yield _sse({
            'done': True,
            'conversation_id': resultat['conversation_id'] or payload.get('conversation_id'),
            'sources': resultat['sources'],
            'depuis_cache': resultat['depuis_cache'],
            'temps_ms': resultat['temps_ms'],
        })

    return _stream_headers(StreamingHttpResponse(generer(), content_type='text/event-stream'))


# --------------------------------------------------------------------------
# POST /api/ia/chat/  (module 4 : réponse JSON en moins de 30 s)
# --------------------------------------------------------------------------

class ChatView(APIView):
    """{"message": "...", "utilisateur_id"?, "conversation_id"?, "profil"?, "historique"?}
    -> {"reponse", "sources", "temps_ms", "intention", "conversation_id", ...}"""

    def post(self, request):
        entree = ChatEntreeSerializer(data=request.data)
        entree.is_valid(raise_exception=True)
        return Response(chatbot.repondre(**entree.validated_data))


# --------------------------------------------------------------------------
# POST /internal/documents/index  (PARTIE 4)
# --------------------------------------------------------------------------

def _extraire_texte_pdf(contenu_bytes):
    from pypdf import PdfReader

    lecteur = PdfReader(io.BytesIO(contenu_bytes))
    pages = [page.extract_text() or '' for page in lecteur.pages]
    return '\n'.join(pages).strip()


def _obtenir_ou_creer_source(source_id, universite_id, categorie, fichier):
    if source_id:
        source = SourceDonnee.objects.filter(id=source_id).first()
        if source:
            return source
    return SourceDonnee.objects.create(
        universite_id=universite_id or None,
        type='pdf' if fichier else 'api',
        url_ou_chemin=(fichier.name if fichier else 'texte-transmis-manuellement'),
        categorie=categorie,
        statut='actif',
        date_dernier_crawl=timezone.now(),
    )


@csrf_exempt
@require_http_methods(['POST'])
def documents_index(request):
    fichier = request.FILES.get('document')

    # Laravel envoie du multipart/form-data (request.POST), mais on accepte aussi
    # du JSON brut pour les tests manuels au curl (PARTIE 11).
    champs = request.POST
    if not champs and not fichier and request.content_type == 'application/json':
        try:
            champs = json.loads(request.body or '{}')
        except (json.JSONDecodeError, UnicodeDecodeError):
            champs = {}

    texte = (champs.get('texte') or champs.get('contenu') or '').strip()
    titre = champs.get('titre') or (fichier.name if fichier else None)
    source_id = champs.get('source_id') or None
    universite_id = champs.get('universite_id') or None
    categorie = champs.get('categorie') or None

    if fichier:
        contenu_brut = fichier.read()
        est_pdf = fichier.name.lower().endswith('.pdf') or fichier.content_type == 'application/pdf'
        texte = _extraire_texte_pdf(contenu_brut) if est_pdf else contenu_brut.decode('utf-8', errors='ignore')

    if not texte:
        return JsonResponse(
            {'error': "Aucun contenu à indexer : fournissez un fichier 'document' (PDF) ou un champ 'texte'."},
            status=400,
        )

    source = _obtenir_ou_creer_source(source_id, universite_id, categorie, fichier)

    document = DocumentRAG.objects.create(
        source=source, titre=titre, contenu_texte=texte, date_indexation=timezone.now()
    )

    ids_faiss = rag_pipeline.indexer_document(document, texte, categorie=categorie)
    document.nb_chunks = len(ids_faiss)
    document.vecteur_faiss_id = json.dumps(ids_faiss)
    document.version_embedding = settings.EMBEDDING_MODEL_NAME
    document.save(update_fields=['nb_chunks', 'vecteur_faiss_id', 'version_embedding', 'updated_at'])

    source.date_dernier_crawl = timezone.now()
    source.statut = 'actif'
    source.save(update_fields=['date_dernier_crawl', 'statut', 'updated_at'])

    return JsonResponse(
        {
            'message': 'Document indexé avec succès.',
            'document_id': str(document.id),
            'source_id': str(source.id),
            'nb_chunks': document.nb_chunks,
        },
        status=201,
    )


# --------------------------------------------------------------------------
# GET /internal/quality-metrics  (PARTIE 9)
# --------------------------------------------------------------------------

@require_http_methods(['GET'])
def quality_metrics(request):
    conversations = list(ConversationIA.objects.values_list('messages', flat=True))
    requetes_traitees = sum(
        1 for messages in conversations for m in (messages or []) if m.get('role') == 'user'
    )
    cache_entrees = CacheReponse.objects.count()
    cache_hits = sum(CacheReponse.objects.values_list('nb_utilisations', flat=True))
    taux_cache_hit = round(cache_hits / requetes_traitees, 4) if requetes_traitees else 0.0

    return JsonResponse({
        'documents_indexes': DocumentRAG.objects.count(),
        'chunks_indexes': rag_pipeline.nb_chunks_indexes(),
        'sources_actives': SourceDonnee.objects.filter(statut='actif').count(),
        'conversations_total': ConversationIA.objects.count(),
        'requetes_traitees': requetes_traitees,
        'cache_entrees': cache_entrees,
        'cache_hits': cache_hits,
        'taux_cache_hit': taux_cache_hit,
        'modele_llm': settings.OLLAMA_MODEL,
        'modele_embeddings': settings.EMBEDDING_MODEL_NAME,
    })


# --------------------------------------------------------------------------
# GET /internal/health  (PARTIE 9)
# --------------------------------------------------------------------------

@require_http_methods(['GET'])
def health(request):
    base_donnees_ok = True
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT 1')
    except Exception:
        base_donnees_ok = False

    ollama_ok = False
    ollama_detail = None
    try:
        racine = settings.OLLAMA_BASE_URL.rstrip('/')
        racine = racine[: -len('/v1')] if racine.endswith('/v1') else racine
        reponse = httpx.get(f'{racine}/api/version', timeout=3)
        ollama_ok = reponse.status_code == 200
        ollama_detail = reponse.json() if ollama_ok else reponse.text
    except Exception as exc:
        ollama_detail = str(exc)

    statut_global = 'ok' if (base_donnees_ok and ollama_ok) else 'degrade'

    return JsonResponse({
        'statut': statut_global,
        'django': 'ok',
        'base_donnees': 'ok' if base_donnees_ok else 'erreur',
        'ollama': {
            'disponible': ollama_ok,
            'detail': ollama_detail,
            'modele_configure': settings.OLLAMA_MODEL,
        },
    }, status=200 if statut_global == 'ok' else 503)
