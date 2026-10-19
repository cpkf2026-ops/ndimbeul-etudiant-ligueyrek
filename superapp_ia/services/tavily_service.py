"""
Client Tavily : la recherche web en temps réel du service IA.

Règle de répartition du projet : « Tavily cherche, Mistral rédige ». Ce module
ne fait que rapporter des résultats du web (titre, URL, extrait, date) ; il ne
génère aucun texte.

Garde-fous appliqués à CHAQUE appel, quel que soit le module appelant :
  - search_depth="basic" imposé (1 crédit), jamais "advanced" (2 crédits) ;
  - quota mensuel vérifié AVANT l'appel (services/credits.py) ;
  - timeout court (TAVILY_TIMEOUT_SECONDES, 8 s par défaut) ;
  - crédit consommé enregistré en base et tracé dans logs/ia.log.
La clé TAVILY_API_KEY ne quitte jamais ce service (ni Laravel ni Flutter ne la voient).
"""
import logging
import time

from django.conf import settings
from tavily import TavilyClient
from tavily.errors import InvalidAPIKeyError, MissingAPIKeyError, UsageLimitExceededError

from . import credits

logger = logging.getLogger(__name__)

PROFONDEUR = 'basic'

# Modules automatiques : leurs appels sont comptés sur la part « veille » du quota.
MODULES_VEILLE = {'opportunites', 'actualites', 'fiches'}

_client = None


class TavilyIndisponibleError(Exception):
    """Tavily n'a pas pu répondre (clé absente/invalide, réseau, délai dépassé)."""


class QuotaTavilyAtteintError(TavilyIndisponibleError):
    """Le plafond mensuel de crédits est atteint pour cet usage : aucun appel n'est fait."""


def _get_client():
    global _client
    if _client is None:
        _client = TavilyClient(api_key=settings.TAVILY_API_KEY)
    return _client


def usage_du_module(module):
    return credits.VEILLE if module in MODULES_VEILLE else credits.INTERACTIF


def _normaliser(resultat):
    return {
        'titre': (resultat.get('title') or '').strip(),
        'url': (resultat.get('url') or '').strip(),
        'contenu': (resultat.get('content') or '').strip(),
        'score': resultat.get('score'),
        # Fournie uniquement avec topic="news" (chaîne au format RFC 2822).
        'date_publication': resultat.get('published_date'),
    }


def rechercher(requete, *, module, topic='general', time_range=None, include_domains=None,
               exclude_domains=None, max_results=5, timeout=None, images=None):
    """Lance UNE recherche Tavily et retourne une liste de résultats normalisés :
    [{titre, url, contenu, score, date_publication}, ...].

    `module` : 'opportunites' | 'actualites' | 'chat' | 'orientation' — sert au
    décompte des crédits (veille ou interactif) et aux logs.

    Lève QuotaTavilyAtteintError si le plafond est atteint (sans appeler Tavily),
    ou TavilyIndisponibleError en cas d'échec : l'appelant décide alors du repli
    (base de données, sources gratuites, liens officiels).

    `images` : liste à remplir avec les adresses des images liées à la recherche
    (option Tavily include_images, sans crédit supplémentaire), ou None pour ne pas en demander.
    """
    if not settings.TAVILY_API_KEY:
        raise TavilyIndisponibleError("TAVILY_API_KEY n'est pas configurée dans le .env du service IA.")

    usage = usage_du_module(module)
    if credits.quota_atteint(usage):
        logger.warning('Tavily [%s] refusé : plafond mensuel atteint pour l\'usage "%s".', module, usage)
        raise QuotaTavilyAtteintError(
            'Le quota mensuel de recherches web est atteint : réponse construite sans recherche internet.'
        )

    parametres = {
        'query': requete,
        'search_depth': PROFONDEUR,
        'topic': topic,
        'max_results': max_results,
        'timeout': timeout or settings.TAVILY_TIMEOUT_SECONDES,
    }
    if time_range:
        parametres['time_range'] = time_range
    if include_domains:
        parametres['include_domains'] = list(include_domains)
    if exclude_domains:
        parametres['exclude_domains'] = list(exclude_domains)
    if topic == 'general':
        # Favorise les pages sénégalaises (option réservée au topic "general").
        parametres['country'] = 'senegal'
    if images is not None:
        parametres['include_images'] = True

    debut = time.monotonic()
    try:
        reponse = _get_client().search(**parametres)
    except UsageLimitExceededError as exc:
        logger.error('Tavily [%s] : quota épuisé côté Tavily : %s', module, exc)
        raise QuotaTavilyAtteintError('Le quota Tavily est épuisé pour ce mois.') from exc
    except (InvalidAPIKeyError, MissingAPIKeyError) as exc:
        logger.error('Tavily [%s] : clé API refusée : %s', module, exc)
        raise TavilyIndisponibleError('La clé TAVILY_API_KEY est invalide.') from exc
    except Exception as exc:  # réseau, délai dépassé, réponse inattendue…
        duree_ms = int((time.monotonic() - debut) * 1000)
        logger.error('Tavily [%s] indisponible après %d ms pour "%s" : %s', module, duree_ms, requete, exc)
        raise TavilyIndisponibleError(f'Recherche web indisponible : {exc}') from exc

    duree_ms = int((time.monotonic() - debut) * 1000)
    cout = credits.COUT_PAR_PROFONDEUR[PROFONDEUR]
    credits.enregistrer(cout, usage)

    resultats = [_normaliser(r) for r in reponse.get('results') or []]
    resultats = [r for r in resultats if r['url']]
    if images is not None:
        images.extend(
            i if isinstance(i, str) else (i or {}).get('url') for i in reponse.get('images') or []
        )
    logger.info(
        'Tavily [%s] "%s" (topic=%s, time_range=%s) : %d résultat(s), %d crédit(s), %d ms',
        module, requete, topic, time_range, len(resultats), cout, duree_ms,
    )
    return resultats
