"""
Encodage vectoriel des textes (français + autres langues) pour le RAG et pour le
matching sémantique passions/domaines du moteur de recommandations.

Modèle léger et multilingue : paraphrase-multilingual-MiniLM-L12-v2
(384 dimensions, tourne correctement sur CPU, supporte le français).
"""
import threading

from django.conf import settings

# numpy (~170 Mo) est importé dans les fonctions : ce module est importé au démarrage de
# Django et de Celery (via le scoring), alors que l'encodage ne sert qu'à l'Orientation.

_model = None
_lock = threading.Lock()


def get_model():
    """Charge le modèle sentence-transformers une seule fois (singleton thread-safe)."""
    global _model
    if _model is None:
        with _lock:
            if _model is None:
                from sentence_transformers import SentenceTransformer

                _model = SentenceTransformer(settings.EMBEDDING_MODEL_NAME)
    return _model


def encoder_textes(textes):
    """Encode une liste de textes -> np.ndarray (n, dim) normalisé (norme L2 = 1)."""
    import numpy as np

    if not textes:
        return np.zeros((0, get_model().get_sentence_embedding_dimension()), dtype='float32')
    vecteurs = get_model().encode(
        list(textes), convert_to_numpy=True, normalize_embeddings=True, show_progress_bar=False
    )
    return vecteurs.astype('float32')


def encoder_texte(texte):
    """Encode un seul texte -> np.ndarray (dim,) normalisé."""
    return encoder_textes([texte])[0]


def similarite_cosinus(vecteur_a, vecteur_b):
    """Les deux vecteurs sont déjà normalisés (norme L2 = 1) -> similarité = produit scalaire."""
    import numpy as np

    return float(np.dot(vecteur_a, vecteur_b))
