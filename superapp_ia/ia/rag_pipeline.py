"""
Pipeline RAG (PARTIE 4) : chunking, index FAISS local, recherche par similarité
cosinus. L'index est persisté dans settings.FAISS_INDEX_DIR (index.faiss +
meta.json), pour survivre aux redémarrages du serveur Django.
"""
import json
import threading

import faiss
import numpy as np
from django.conf import settings

from .embeddings import encoder_texte, encoder_textes

_lock = threading.Lock()
_index = None
_meta = None

# En dessous de ce score de similarité cosinus, un chunk est considéré non pertinent
# (mieux vaut répondre "je ne sais pas" que citer un document hors-sujet).
SEUIL_PERTINENCE = 0.30


def chunker(texte, taille_mots=550, chevauchement=60):
    """Découpe un texte en chunks d'environ 500-800 tokens.

    On chunk par mots plutôt que par tokens exacts pour rester indépendant d'un
    tokenizer particulier : en français, 1 token ≈ 0.75 mot, donc 550 mots
    correspondent à ~730 tokens, dans la fourchette demandée par le CDC.
    """
    mots = texte.split()
    if not mots:
        return []

    chunks = []
    debut = 0
    while debut < len(mots):
        fin = min(debut + taille_mots, len(mots))
        chunks.append(' '.join(mots[debut:fin]))
        if fin == len(mots):
            break
        debut = max(fin - chevauchement, debut + 1)
    return chunks


def _chemin_index():
    return settings.FAISS_INDEX_DIR / 'index.faiss'


def _chemin_meta():
    return settings.FAISS_INDEX_DIR / 'meta.json'


def _index_vide():
    from .embeddings import get_model

    dimension = get_model().get_sentence_embedding_dimension()
    return faiss.IndexIDMap(faiss.IndexFlatIP(dimension))


def _charger():
    global _index, _meta
    if _index is not None:
        return _index, _meta

    settings.FAISS_INDEX_DIR.mkdir(parents=True, exist_ok=True)
    if _chemin_index().exists() and _chemin_meta().exists():
        _index = faiss.read_index(str(_chemin_index()))
        with open(_chemin_meta(), encoding='utf-8') as f:
            _meta = json.load(f)
    else:
        _index = _index_vide()
        _meta = {'next_id': 0, 'chunks': {}}
    return _index, _meta


def _sauvegarder():
    settings.FAISS_INDEX_DIR.mkdir(parents=True, exist_ok=True)
    faiss.write_index(_index, str(_chemin_index()))
    with open(_chemin_meta(), 'w', encoding='utf-8') as f:
        json.dump(_meta, f, ensure_ascii=False, indent=2)


def indexer_document(document_rag, texte, categorie=None):
    """Chunke + encode + ajoute au FAISS. Retourne la liste des ids FAISS créés."""
    with _lock:
        index, meta = _charger()

        chunks = chunker(texte)
        if not chunks:
            return []

        vecteurs = encoder_textes(chunks)
        ids = np.arange(meta['next_id'], meta['next_id'] + len(chunks), dtype='int64')
        index.add_with_ids(vecteurs, ids)

        for position, (chunk_id, texte_chunk) in enumerate(zip(ids.tolist(), chunks)):
            meta['chunks'][str(chunk_id)] = {
                'document_id': str(document_rag.id),
                'source_id': str(document_rag.source_id),
                'titre': document_rag.titre,
                'categorie': categorie,
                'chunk_index': position,
                'texte': texte_chunk,
            }
        meta['next_id'] += len(chunks)

        _sauvegarder()
        return ids.tolist()


def rechercher(question, top_k=None):
    """Top-k documents pertinents (score cosinus >= seuil), triés par score décroissant."""
    top_k = top_k or settings.RAG_TOP_K
    with _lock:
        index, meta = _charger()

    if index.ntotal == 0:
        return []

    vecteur = encoder_texte(question).reshape(1, -1)
    scores, ids = index.search(vecteur, min(top_k, index.ntotal))

    resultats = []
    for score, chunk_id in zip(scores[0].tolist(), ids[0].tolist()):
        if chunk_id == -1 or score < SEUIL_PERTINENCE:
            continue
        chunk = meta['chunks'].get(str(int(chunk_id)))
        if not chunk:
            continue
        resultats.append({
            'texte': chunk['texte'],
            'titre': chunk['titre'],
            'categorie': chunk.get('categorie'),
            'document_id': chunk['document_id'],
            'score': float(score),
        })
    return resultats


def nb_documents_indexes():
    with _lock:
        _, meta = _charger()
        return len({c['document_id'] for c in meta['chunks'].values()})


def nb_chunks_indexes():
    with _lock:
        _, meta = _charger()
        return len(meta['chunks'])
