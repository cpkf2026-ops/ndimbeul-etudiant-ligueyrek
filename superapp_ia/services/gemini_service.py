"""
Client Google Gemini (API REST, offre gratuite) pour le chatbot à outils (ia/agent.py).

Pourquoi : le modèle local qwen3.5:2b est trop petit pour comprendre les questions telles que
les élèves les écrivent (fautes, phrases longues, suite de conversation). Gemini tourne sur
les serveurs de Google : aucune charge mémoire ni processeur sur le PC.

Appel direct en HTTP (httpx, déjà installé) : pas de nouvelle dépendance. Clé dans `.env`
(GEMINI_API_KEY), jamais dans le code.

Robustesse : quota gratuit atteint (429), clé invalide, délai dépassé ou panne -> on lève
GeminiIndisponibleError et le chatbot actuel (règles + qwen) répond à la place. Après un 429,
Gemini est mis en pause GEMINI_PAUSE_MINUTES pour ne pas insister inutilement.
"""
import logging
import time

import httpx
from django.conf import settings

from services import cache

logger = logging.getLogger(__name__)

URL = 'https://generativelanguage.googleapis.com/v1beta/models/{modele}:generateContent'
_CLE_PAUSE = 'ia:gemini:pause'


class GeminiIndisponibleError(Exception):
    """Gemini ne peut pas répondre (pas de clé, quota, panne, délai) : utiliser le repli."""


def disponible():
    """Vrai si une clé est configurée et que Gemini n'est pas en pause (quota atteint)."""
    return bool(settings.GEMINI_API_KEY) and cache.lire(_CLE_PAUSE) is None


def _mettre_en_pause(raison):
    minutes = settings.GEMINI_PAUSE_MINUTES
    logger.warning('Gemini mis en pause %d min : %s', minutes, raison)
    cache.ecrire(_CLE_PAUSE, raison, minutes * 60)


def generer(contenus, *, instruction_systeme, outils=None, timeout=15):
    """Un appel `generateContent`. `contenus` : historique au format Gemini
    ([{role: 'user'|'model', parts: [...]}]). Retourne le `content` du premier candidat
    (dict avec `parts` : texte et/ou appels d'outils)."""
    if not disponible():
        raise GeminiIndisponibleError('Gemini non configuré ou en pause')
    corps = {
        'systemInstruction': {'parts': [{'text': instruction_systeme}]},
        'contents': contenus,
        # Réflexion « légère » : 4 s au lieu de 15 à 20 s pour une réponse de même qualité ici
        # (mesuré le 29/10/2026), le travail de recherche étant fait par les outils.
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1200,
                             'thinkingConfig': {'thinkingLevel': 'low'}},
    }
    if outils:
        corps['tools'] = [{'functionDeclarations': outils}]
    debut = time.monotonic()
    # Modèle principal, puis modèle de secours si Google est surchargé (503 « high demand »,
    # observé le 29/10/2026), trop lent, ou si le quota du principal est atteint (quotas
    # distincts par modèle).
    modeles = list(dict.fromkeys(m for m in (settings.GEMINI_MODEL, settings.GEMINI_MODEL_SECOURS) if m))
    for numero, modele in enumerate(modeles):
        dernier = numero == len(modeles) - 1
        reste = timeout - (time.monotonic() - debut)
        if reste < 2:
            raise GeminiIndisponibleError('délai dépassé')
        try:
            reponse = httpx.post(
                URL.format(modele=modele), json=corps,
                timeout=reste if dernier else min(reste * 0.6, 10),
                headers={'x-goog-api-key': settings.GEMINI_API_KEY},
            )
        except httpx.HTTPError as exc:
            if dernier:
                raise GeminiIndisponibleError(f'réseau : {exc}') from exc
            logger.warning('Gemini %s : %s, essai avec %s', modele, exc.__class__.__name__, modeles[numero + 1])
            continue
        if reponse.status_code in (429, 500, 503) and not dernier:
            logger.warning('Gemini %s : HTTP %d, essai avec %s', modele, reponse.status_code, modeles[numero + 1])
            continue
        break

    if reponse.status_code == 429:
        _mettre_en_pause('quota gratuit atteint (429)')
        raise GeminiIndisponibleError('quota atteint')
    if reponse.status_code in (400, 401, 403) and ('API key' in reponse.text or 'free tier' in reponse.text):
        _mettre_en_pause('clé API invalide ou offre gratuite non disponible')
        raise GeminiIndisponibleError('clé API refusée')
    if reponse.status_code >= 400:
        raise GeminiIndisponibleError(f'HTTP {reponse.status_code} : {reponse.text[:300]}')

    donnees = reponse.json()
    candidats = donnees.get('candidates') or []
    if not candidats or not (candidats[0].get('content') or {}).get('parts'):
        raison = (candidats[0].get('finishReason') if candidats else None) or donnees.get('promptFeedback')
        raise GeminiIndisponibleError(f'réponse vide ({raison})')
    usage = donnees.get('usageMetadata') or {}
    logger.info('Gemini (%s) : %d ms, %s jetons entrée, %s sortie', donnees.get('modelVersion') or modele,
                int((time.monotonic() - debut) * 1000), usage.get('promptTokenCount'),
                usage.get('candidatesTokenCount'))
    return candidats[0]['content']
