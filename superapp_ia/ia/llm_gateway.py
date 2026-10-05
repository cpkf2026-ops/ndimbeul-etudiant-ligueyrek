"""
Passerelle vers le LLM local servi par Ollama (PARTIE 5).

On utilise l'API native d'Ollama (/api/chat) plutôt que sa façade compatible
OpenAI (/v1) : c'est la seule à respecter le paramètre "think", indispensable pour
désactiver le mode raisonnement des modèles hybrides (ex: qwen3.5) — sans quoi ces
modèles consomment tout leur budget de tokens sur un raisonnement interne invisible
et ne produisent jamais la réponse visible (voir OLLAMA_MODEL dans .env). Aucun
appel à une API cloud payante.
"""
import json
import logging

import httpx
from django.conf import settings

logger = logging.getLogger(__name__)

_client = None


class LLMIndisponibleError(Exception):
    """Levée quand Ollama ne répond pas (non lancé, modèle absent, etc.)."""


def _url_native():
    racine = settings.OLLAMA_BASE_URL.rstrip('/')
    return racine[: -len('/v1')] if racine.endswith('/v1') else racine


def get_client():
    global _client
    if _client is None:
        # Pas de timeout HTTP côté client : l'inférence CPU locale peut prendre
        # plusieurs dizaines de secondes, c'est Django/Laravel/Flutter qui portent
        # les timeouts pertinents pour l'utilisateur, pas cette couche transport.
        _client = httpx.Client(base_url=_url_native(), timeout=None)
    return _client


def _message_erreur(exc):
    return (
        f"Le modèle local Ollama ({settings.OLLAMA_MODEL}) est injoignable sur "
        f"{settings.OLLAMA_BASE_URL}. Vérifiez qu'Ollama tourne (`ollama serve`) et que le "
        f"modèle est bien téléchargé (`ollama pull {settings.OLLAMA_MODEL}`). Détail : {exc}"
    )


def precharger_modele():
    """Envoie un message minimal à Ollama pour forcer le chargement du modèle en mémoire dès
    le démarrage de Django (voir ia/apps.py), plutôt que de faire payer ce coût (10-20s) à la
    première vraie question de l'utilisateur. keep_alive='30m' évite aussi qu'Ollama ne
    décharge le modèle entre deux messages d'une même session de chat."""
    try:
        get_client().post('/api/chat', json={
            'model': settings.OLLAMA_MODEL,
            'messages': [{'role': 'user', 'content': 'Bonjour'}],
            'stream': False,
            'think': False,
            'keep_alive': '30m',
            'options': {'num_predict': 1},
        })
    except (httpx.HTTPError, OSError) as exc:
        logger.warning('Préchargement Ollama impossible (le service répondra quand même, '
                        'juste plus lentement au premier message) : %s', exc)


def generer_reponse_sync(messages, temperature=0.3, max_tokens=None, num_ctx=4096):
    """Appel bloquant, réponse complète en une fois (utilisé pour les explications de recommandations).

    num_ctx augmente la fenêtre de contexte Ollama (par défaut souvent 2048, trop court pour
    un prompt groupé listant 10 formations + leur score détaillé) : sans ça, Ollama tronque
    silencieusement le contexte ou renvoie une erreur 500 sur les prompts un peu longs.
    """
    options = {'temperature': temperature, 'num_ctx': num_ctx}
    if max_tokens is not None:
        options['num_predict'] = max_tokens

    client = get_client()
    try:
        reponse = client.post('/api/chat', json={
            'model': settings.OLLAMA_MODEL,
            'messages': messages,
            'stream': False,
            'think': False,
            'keep_alive': '30m',
            'options': options,
        })
        reponse.raise_for_status()
    except (httpx.HTTPError, OSError) as exc:
        logger.error('Ollama indisponible: %s', exc)
        raise LLMIndisponibleError(_message_erreur(exc)) from exc

    return (reponse.json().get('message', {}).get('content') or '').strip()


def generer_reponse_stream(messages, temperature=0.3, num_ctx=4096, max_tokens=110):
    """Générateur : yield chaque token/morceau de texte au fur et à mesure (SSE côté vue).

    max_tokens (num_predict côté Ollama) plafonne la longueur de la réponse : sans plafond,
    le modèle (inférence CPU pure, sans GPU) peut partir sur une réponse de plusieurs
    milliers de tokens et mettre plusieurs minutes à répondre. À ~6-7 tokens/seconde sur ce
    CPU, 110 tokens (~75-80 mots) donne un pire cas d'une quinzaine de secondes — le
    SYSTEM_PROMPT demande explicitement des réponses courtes pour que le modèle conclue
    naturellement dans ce budget plutôt que d'être coupé en pleine phrase.
    """
    client = get_client()
    options = {'temperature': temperature, 'num_ctx': num_ctx, 'num_predict': max_tokens}
    try:
        with client.stream('POST', '/api/chat', json={
            'model': settings.OLLAMA_MODEL,
            'messages': messages,
            'stream': True,
            'think': False,
            'keep_alive': '30m',
            'options': options,
        }) as reponse:
            reponse.raise_for_status()
            for ligne in reponse.iter_lines():
                if not ligne:
                    continue
                morceau = json.loads(ligne)
                delta = (morceau.get('message') or {}).get('content')
                if delta:
                    yield delta
                if morceau.get('done'):
                    break
    except (httpx.HTTPError, OSError) as exc:
        logger.error('Ollama indisponible (stream): %s', exc)
        raise LLMIndisponibleError(_message_erreur(exc)) from exc
