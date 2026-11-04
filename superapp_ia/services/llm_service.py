"""
Client Ollama : le LLM local qui rédige, résume et classe (« Tavily cherche,
Mistral rédige »). Aucun appel à une API cloud payante.

Deux modèles, choisis dans le .env selon la contrainte de temps :
  - OLLAMA_MODEL (mistral:7b-instruct) : veille automatique (modules 2 et 3),
    exécutée par Celery, donc sans contrainte de temps de réponse ;
  - OLLAMA_MODEL_RAPIDE (modèle 2-3B) : chatbot et orientation, qui doivent
    répondre en moins de 30 s. Sur un CPU sans GPU, un 7B ne produit que ~3-4
    tokens/s, soit 80-100 s pour 300 tokens : incompatible avec cette contrainte.
Sur une machine avec GPU, il suffit de mettre le même modèle dans les deux variables.

On utilise l'API native d'Ollama (/api/chat), seule à respecter "think": false
(désactive le raisonnement caché des modèles hybrides type qwen3.5) et "format": "json".
"""
import json
import logging
import re
import time

import httpx
from django.conf import settings

logger = logging.getLogger(__name__)

_client = None


class LLMIndisponibleError(Exception):
    """Ollama ne répond pas (service arrêté, modèle absent, erreur serveur)."""


class LLMTimeoutError(LLMIndisponibleError):
    """La génération a dépassé le délai accordé : l'appelant renvoie une réponse de secours."""


class LLMReponseInvalideError(Exception):
    """Le modèle a répondu, mais pas avec le JSON demandé."""


def modele_veille():
    return settings.OLLAMA_MODEL


def modele_rapide():
    return settings.OLLAMA_MODEL_RAPIDE


def get_client():
    global _client
    if _client is None:
        # Pas de timeout global par défaut : chaque appel fixe le sien (voir `timeout`),
        # la veille Celery pouvant légitimement attendre plusieurs minutes.
        _client = httpx.Client(base_url=settings.OLLAMA_URL, timeout=None)
    return _client


def _timeout(secondes):
    # Connexion courte (Ollama est local : s'il ne répond pas en 5 s, il est arrêté).
    # Sans streaming, Ollama n'envoie rien avant la fin de la génération : le délai
    # de lecture borne donc bien la durée totale de la génération.
    return httpx.Timeout(secondes, connect=5.0)


def _corps(messages, modele, temperature, num_predict, num_ctx, format_json, stream,
           keep_alive=None, num_thread=None):
    options = {'temperature': temperature, 'num_ctx': num_ctx}
    if num_predict is not None:
        options['num_predict'] = num_predict
    if num_thread:
        options['num_thread'] = num_thread
    corps = {
        'model': modele,
        'messages': messages,
        'stream': stream,
        'think': False,
        # Durée pendant laquelle le modèle reste en RAM après usage (défaut : OLLAMA_KEEP_ALIVE,
        # 5 min). Il occupe ~2-3 Go : au-delà, il est déchargé et rechargé à la demande (~10 s).
        'keep_alive': keep_alive or settings.OLLAMA_KEEP_ALIVE,
        'options': options,
    }
    if format_json:
        corps['format'] = 'json'
    return corps


def _message_indisponible(modele, exc):
    return (
        f"Le modèle local Ollama ({modele}) est injoignable sur {settings.OLLAMA_URL}. "
        f"Vérifiez qu'Ollama tourne (`ollama serve`) et que le modèle est téléchargé "
        f"(`ollama pull {modele}`). Détail : {exc}"
    )


def generer(messages, *, modele, temperature=0.2, num_predict=300, num_ctx=4096,
            timeout=None, format_json=False, keep_alive=None, num_thread=None):
    """Appel bloquant : retourne le texte complet généré par le modèle.

    `timeout` (secondes) : None = attendre autant que nécessaire (veille) ;
    une valeur = budget restant de la requête utilisateur (chat, orientation).
    `keep_alive` / `num_thread` : la veille libère vite la RAM et laisse des cœurs
    CPU libres pour que le chat reste fluide pendant qu'elle tourne.
    """
    debut = time.monotonic()
    try:
        reponse = get_client().post(
            '/api/chat',
            json=_corps(messages, modele, temperature, num_predict, num_ctx, format_json, stream=False,
                        keep_alive=keep_alive, num_thread=num_thread),
            timeout=_timeout(timeout),
        )
        reponse.raise_for_status()
    except (httpx.ConnectError, httpx.ConnectTimeout) as exc:
        logger.error('Ollama injoignable (%s) : %s', modele, exc)
        raise LLMIndisponibleError(_message_indisponible(modele, exc)) from exc
    except httpx.TimeoutException as exc:
        logger.warning('Ollama (%s) : délai de %s s dépassé', modele, timeout)
        raise LLMTimeoutError(f'Le modèle {modele} a dépassé le délai de {timeout} s.') from exc
    except httpx.HTTPStatusError as exc:
        logger.error('Ollama (%s) a répondu HTTP %s : %s', modele, exc.response.status_code, exc.response.text[:300])
        raise LLMIndisponibleError(_message_indisponible(modele, exc.response.text[:300])) from exc
    except (httpx.HTTPError, OSError) as exc:
        logger.error('Ollama indisponible (%s) : %s', modele, exc)
        raise LLMIndisponibleError(_message_indisponible(modele, exc)) from exc

    donnees = reponse.json()
    texte = ((donnees.get('message') or {}).get('content') or '').strip()
    logger.info(
        'Ollama (%s) : %s token(s) générés en %d ms',
        modele, donnees.get('eval_count', '?'), int((time.monotonic() - debut) * 1000),
    )
    return texte


def extraire_json(texte):
    """Convertit la réponse du modèle en objet Python. Tolère les écarts fréquents
    des petits modèles : bloc ```json … ```, phrase avant/après l'objet."""
    nettoye = re.sub(r'^```(?:json)?\s*|\s*```$', '', (texte or '').strip())
    try:
        return json.loads(nettoye)
    except json.JSONDecodeError:
        pass
    # Dernier recours : le plus grand bloc {...} ou [...] trouvé dans le texte, en
    # commençant par celui qui s'ouvre en premier (une liste d'objets reste une liste).
    blocs = sorted((('{', '}'), ('[', ']')), key=lambda b: nettoye.find(b[0]) % (len(nettoye) + 1))
    for ouvrant, fermant in blocs:
        debut, fin = nettoye.find(ouvrant), nettoye.rfind(fermant)
        if debut != -1 and fin > debut:
            try:
                return json.loads(nettoye[debut:fin + 1])
            except json.JSONDecodeError:
                continue
    raise LLMReponseInvalideError(f'Réponse du modèle non exploitable en JSON : {texte[:200]!r}')


def generer_json(messages, **kwargs):
    """Comme `generer`, mais impose une sortie JSON et la retourne décodée."""
    return extraire_json(generer(messages, format_json=True, **kwargs))


def generer_stream(messages, *, modele, temperature=0.3, num_predict=150, num_ctx=4096, timeout=None):
    """Générateur : produit le texte morceau par morceau (chat en streaming SSE).
    Le premier mot s'affiche en quelques secondes, même si la réponse complète est plus longue.
    `timeout` borne l'attente de CHAQUE morceau (dont le premier, le plus long à venir)."""
    corps = _corps(messages, modele, temperature, num_predict, num_ctx, format_json=False, stream=True)
    try:
        with get_client().stream('POST', '/api/chat', json=corps, timeout=_timeout(timeout)) as reponse:
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
    except httpx.TimeoutException as exc:
        if isinstance(exc, httpx.ConnectTimeout):
            raise LLMIndisponibleError(_message_indisponible(modele, exc)) from exc
        raise LLMTimeoutError(f'Le modèle {modele} a dépassé le délai de {timeout} s.') from exc
    except (httpx.HTTPError, OSError) as exc:
        logger.error('Ollama indisponible (stream, %s) : %s', modele, exc)
        raise LLMIndisponibleError(_message_indisponible(modele, exc)) from exc


def precharger(modele, keep_alive=None, timeout=120):
    """Charge le modèle en mémoire avant la première vraie demande, pour qu'elle ne paie
    pas le temps de chargement (10-20 s pour un 2B, bien plus pour Mistral 7B quand la
    RAM est occupée par d'autres programmes)."""
    try:
        generer([{'role': 'user', 'content': 'Bonjour'}], modele=modele, num_predict=1,
                timeout=timeout, keep_alive=keep_alive)
    except LLMIndisponibleError as exc:
        logger.warning('Préchargement Ollama impossible (%s) : %s', modele, exc)


def etat():
    """Disponibilité d'Ollama et présence des deux modèles configurés (endpoint de santé)."""
    try:
        reponse = get_client().get('/api/tags', timeout=_timeout(3))
        reponse.raise_for_status()
    except (httpx.HTTPError, OSError) as exc:
        return {'disponible': False, 'detail': str(exc)}

    installes = {m.get('name') for m in reponse.json().get('models') or []}
    return {
        'disponible': True,
        'modele_veille': {'nom': modele_veille(), 'installe': modele_veille() in installes},
        'modele_rapide': {'nom': modele_rapide(), 'installe': modele_rapide() in installes},
    }
