"""
Endpoints /internal/* exposés uniquement à Laravel (protégés par
ia.middleware.InternalKeyMiddleware) : chat (PARTIE 7), indexation de documents
(PARTIE 4), métriques qualité et health check (PARTIE 9).
"""
import hashlib
import io
import json
import re

import httpx
from django.conf import settings
from django.db import connection
from django.http import JsonResponse, StreamingHttpResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

from . import llm_gateway, prompts, rag_local, rag_pipeline
from .models import CacheReponse, ConversationIA, DocumentRAG, SourceDonnee


# --------------------------------------------------------------------------
# POST /internal/chat  (PARTIE 7)
# --------------------------------------------------------------------------

def _normaliser(message):
    return re.sub(r'\s+', ' ', message.strip().lower())


def _hash_question(message):
    return hashlib.sha256(_normaliser(message).encode('utf-8')).hexdigest()


def _sse(data):
    return f'data: {json.dumps(data, ensure_ascii=False)}\n\n'


def _obtenir_ou_creer_conversation(conversation_id, utilisateur_id):
    if conversation_id:
        conversation, _ = ConversationIA.objects.get_or_create(
            id=conversation_id, defaults={'utilisateur_id': utilisateur_id, 'messages': []}
        )
        return conversation
    return ConversationIA.objects.create(utilisateur_id=utilisateur_id, messages=[])


def _sources_uniques(documents):
    """{titre, url} par source citée — url est le vrai site officiel de l'établissement
    ou l'annonce source de l'offre (voir rag_local.py), null pour les documents
    manuellement importés (pas de page web associée). Flutter n'affiche le lien comme
    cliquable QUE si une url réelle est présente (jamais de lien inventé)."""
    vues = set()
    sources = []
    for doc in documents:
        libelle = doc.get('titre') or 'Document'
        if libelle not in vues:
            vues.add(libelle)
            sources.append({'titre': libelle, 'url': doc.get('url')})
    return sources


def _mettre_en_cache(question_hash, reponse, sources):
    expiration = timezone.now() + timezone.timedelta(hours=settings.CACHE_REPONSE_TTL_HEURES)
    CacheReponse.objects.update_or_create(
        question_hash=question_hash,
        defaults={
            'reponse_json': {'reponse': reponse},
            'sources_utilisees': sources,
            'date_expiration': expiration,
        },
    )


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


def _stream_depuis_cache(cache, conversation, message):
    def generer():
        reponse = (cache.reponse_json or {}).get('reponse', '')
        sources = cache.sources_utilisees or []

        yield _sse({'token': reponse})

        conversation.ajouter_message('user', message)
        conversation.ajouter_message('assistant', reponse, sources)

        cache.nb_utilisations += 1
        cache.save(update_fields=['nb_utilisations', 'updated_at'])

        yield _sse({
            'done': True,
            'conversation_id': str(conversation.id),
            'sources': sources,
            'depuis_cache': True,
        })

    return _stream_headers(StreamingHttpResponse(generer(), content_type='text/event-stream'))


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

    utilisateur_id = payload.get('utilisateur_id')
    profil = payload.get('profil') or {}
    conversation_id = payload.get('conversation_id')

    conversation = _obtenir_ou_creer_conversation(conversation_id, utilisateur_id)

    # 1) Cache : hash SHA-256 du message normalisé, réponse réutilisée si < 24h.
    question_hash = _hash_question(message)
    cache = CacheReponse.objects.filter(question_hash=question_hash).first()
    if cache and cache.date_expiration > timezone.now():
        return _stream_depuis_cache(cache, conversation, message)

    # 2 & 3) Embedding de la question + recherche des top-k documents FAISS (PDF/texte
    # indexés manuellement), complétée par une recherche mots-clés dans NOS données réelles
    # (établissements, offres) — le chat doit s'appuyer sur l'application, pas juste sur le
    # savoir général du modèle.
    documents = rag_pipeline.rechercher(message) + rag_local.rechercher(message)

    def generer():
        # 4) Construction du prompt complet (système + contexte + profil + question).
        historique = conversation.messages or []
        messages_llm = prompts.construire_messages(message, documents, profil, historique)

        # 5 & 6) Appel Ollama en streaming, relayé token par token en SSE.
        reponse_complete = ''
        try:
            for morceau in llm_gateway.generer_reponse_stream(messages_llm):
                reponse_complete += morceau
                yield _sse({'token': morceau})
        except llm_gateway.LLMIndisponibleError as exc:
            yield _sse({'error': str(exc)})
            return

        sources = _sources_uniques(documents)

        # 7) Sauvegarde de la conversation (tour user + assistant) et mise en cache.
        conversation.ajouter_message('user', message)
        conversation.ajouter_message('assistant', reponse_complete, sources)
        _mettre_en_cache(question_hash, reponse_complete, sources)

        yield _sse({'done': True, 'conversation_id': str(conversation.id), 'sources': sources})

    return _stream_headers(StreamingHttpResponse(generer(), content_type='text/event-stream'))


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
