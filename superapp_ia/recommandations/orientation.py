"""
Module 1 — Orientation : recommandations personnalisées après le bac.

Entrée : série du bac, moyenne, passions, ville (facultative).
Sortie : 3 à 5 métiers, 3 à 5 formations, 3 à 5 universités/écoles, chacun avec une
justification courte, un score de compatibilité 0-100 et un lien source.

Qui fait quoi (« Tavily cherche, Mistral rédige », sans jamais inventer) :
  - FORMATIONS : notre base, filtrée par série ET moyenne (règles éliminatoires),
    classée par le moteur de score existant (scoring.py) ; justification construite
    à partir du détail du score, donc toujours exacte ;
  - UNIVERSITÉS : regroupement des formations retenues, avec au moins un établissement
    public et un privé quand la base le permet ;
  - MÉTIERS : débouchés des formations en base, complétés si besoin par UNE recherche
    Tavily (mise en cache 30 jours par passions). Le modèle rapide choisit parmi les
    métiers CITÉS dans ces sources ; tout métier absent de sa source est écarté.

Budget de temps : ORIENTATION_TIMEOUT_SECONDES (25 s), sous le timeout Laravel. Le
résultat complet est mis en cache 7 jours par profil (série, moyenne arrondie,
passions, ville) : les profils fréquents (S2, 12/20, informatique…) répondent
instantanément.
"""
import logging
import math
import re
import time

from django.conf import settings
from django.utils import timezone

from ia.embeddings import encoder_texte, similarite_cosinus
from services import cache, llm_service, tavily_service, texte
from veille import fiabilite

from . import scoring
from .models import Recommandation, Universite
from .prompts import construire_messages_metiers, lire_metiers

logger = logging.getLogger(__name__)

NOM = 'orientation'
NB_MAX = 5
NB_MIN_METIERS = 3
LIEN_CAMPUSEN = 'https://campusen.sn'
TTL_TAVILY_SECONDES = 30 * 24 * 3600
# Une ligne « nom | numéro » par métier (~8 tokens) : 5 métiers tiennent dans 60 tokens.
LLM_NUM_PREDICT = 60
# En dessous de ce temps restant, on n'appelle pas le LLM (réponse de secours).
TEMPS_MIN_LLM_SECONDES = 5


def _profil_scoring(donnees):
    """Profil au format attendu par scoring.generer_recommandations."""
    ville = (donnees.get('ville') or '').strip()
    return {
        'serie_bac': donnees['serie_bac'],
        'moyenne_generale': donnees['moyenne'],
        'passions': donnees['passions'],
        'matieres_fortes': donnees.get('matieres_fortes') or [],
        'metiers_envisages': donnees.get('metiers_envisages') or [],
        'region_cible': ville or None,
        # Sans ville indiquée, la localisation n'est pas un critère.
        'mobilite': donnees.get('mobilite', not ville),
    }


def _cle_cache(donnees):
    return cache.cle(
        NOM, donnees['serie_bac'], math.floor(float(donnees['moyenne'])),
        ','.join(sorted(cache.normaliser_texte(p) for p in donnees['passions'])),
        donnees.get('ville') or '', ','.join(sorted(donnees.get('matieres_fortes') or [])),
    )


def _liens_universites(universite_ids):
    """Site officiel de chaque établissement (lien source), Campusen à défaut."""
    sites = dict(
        Universite.objects.filter(id__in=universite_ids)
        .exclude(site_web_officiel__isnull=True).exclude(site_web_officiel='')
        .values_list('id', 'site_web_officiel')
    )
    return {uid: sites.get(uid) or LIEN_CAMPUSEN for uid in universite_ids}


# --- Formations -----------------------------------------------------------------

def justifier_formation(resultat, donnees, profil):
    """Justification construite à partir du détail du score : toujours exacte et
    instantanée (aucun appel au modèle). Utilisée aussi par /internal/recommendations."""
    formation, details = resultat['formation'], resultat['details']
    morceaux = []
    # 1. Le lien avec le PROJET de l'élève, d'abord (c'est la raison de la proposition).
    termes, communs = resultat.get('termes_profil') or [], resultat.get('domaines_communs') or []
    voisins = resultat.get('voisins') or []
    if termes and communs:
        morceaux.append(f"en lien avec ton projet ({', '.join(termes[:2])}) : {communs[0].lower()}")
    elif voisins:
        v = voisins[0]
        morceaux.append(f"domaine voisin de ton projet ({', '.join(v['termes'][:2])} : {v['projet'].lower()})"
                        + (" — nous n'avons pas encore de formation dans ce domaine exact" if v.get('aucune_exacte')
                           else " — peu de formations existent dans ce domaine exact"))
    elif resultat.get('passion_forte', details['domaine_passions'] >= scoring.POIDS_DOMAINE_PASSIONS / 2) \
            and donnees['passions']:
        morceaux.append(f"proche de tes centres d'intérêt ({', '.join(donnees['passions'][:2])})")
    # 2. Les conditions d'admission CONNUES (rien d'affirmé quand la fiche ne dit rien).
    if getattr(formation, 'est_domaine', False):
        morceaux.append("domaine proposé par l'établissement d'après sa fiche (conditions d'admission à vérifier)")
    elif formation.series_acceptees:
        morceaux.append(f"ouverte aux bacheliers de la série {donnees['serie_bac']}")
    else:
        morceaux.append('aucune série exigée sur sa fiche')
    if formation.moyenne_minimale is not None and donnees.get('moyenne') is not None:
        morceaux.append(
            f"ta moyenne ({float(donnees['moyenne']):g}/20) atteint le minimum demandé "
            f"({float(formation.moyenne_minimale):g}/20)"
        )
    # 3. Les préférences respectées.
    if details['region'] and not profil['mobilite'] and donnees.get('ville'):
        morceaux.append(f"située à {donnees['ville']}")
    if details.get('statut') == scoring.POIDS_STATUT:
        morceaux.append(f"établissement {'public' if formation.universite.type == 'public' else 'privé'} "
                        "comme tu le préfères")
    if details['bourse']:
        morceaux.append('une bourse est disponible')
    phrase = ', '.join(morceaux)
    return phrase[0].upper() + phrase[1:] + '.'


def _choisir_formations(resultats, donnees, profil, liens):
    formations, deja_vues = [], set()
    for resultat in resultats:
        formation = resultat['formation']
        cle = (cache.normaliser_texte(formation.intitule), formation.universite_id)
        if cle in deja_vues:
            continue
        deja_vues.add(cle)
        formations.append({
            'id': str(formation.id),
            'nom': formation.intitule,
            'niveau': formation.niveau,
            'domaine': formation.domaine,
            'universite': {
                'id': str(formation.universite_id),
                'nom': formation.universite.nom,
                'type': formation.universite.type,
            },
            'conditions': {
                'series_acceptees': formation.series_acceptees or [],
                'moyenne_minimale': float(formation.moyenne_minimale) if formation.moyenne_minimale else None,
            },
            'justification': justifier_formation(resultat, donnees, profil),
            'score': round(resultat['score']),
            'source': liens[formation.universite_id],
        })
        if len(formations) == NB_MAX:
            break
    return formations


# --- Universités ----------------------------------------------------------------

def _choisir_universites(resultats, liens):
    """Une ligne par établissement (meilleur score de ses formations), en garantissant
    la présence du public ET du privé quand les deux existent parmi les candidats."""
    par_universite = {}
    for resultat in resultats:  # déjà triés par score décroissant
        universite = resultat['formation'].universite
        entree = par_universite.setdefault(universite.id, {
            'universite': universite, 'score': resultat['score'], 'formations': [],
        })
        entree['formations'].append(resultat['formation'].intitule)

    candidates = list(par_universite.values())
    retenues = candidates[:NB_MAX]
    types_retenus = {e['universite'].type for e in retenues}
    autre_type = next((e for e in candidates[NB_MAX:] if e['universite'].type not in types_retenus), None)
    if len(types_retenus) == 1 and autre_type and len(retenues) == NB_MAX:
        retenues[-1] = autre_type

    universites = []
    for entree in retenues:
        universite = entree['universite']
        nature = 'public' if universite.type == 'public' else 'privé'
        nb = len(entree['formations'])
        universites.append({
            'id': str(universite.id),
            'nom': universite.nom,
            'type': universite.type,
            'region': universite.region,
            'justification': (
                f"Établissement {nature} qui propose {nb} formation{'s' if nb > 1 else ''} "
                f"adaptée{'s' if nb > 1 else ''} à ton profil, dont « {entree['formations'][0]} »."
            ),
            'score': round(entree['score']),
            'source': liens[universite.id],
        })
    return universites


# --- Métiers --------------------------------------------------------------------

def _debouches(texte_debouches):
    return [m.strip(' .') for m in re.split(r'[,;\n•]', texte_debouches or '') if len(m.strip(' .')) >= 3]


def _sources_metiers(resultats, donnees, liens, echeance, avertissements):
    """Sources numérotées pour le choix des métiers : débouchés en base d'abord,
    puis Tavily si la base en cite moins de NB_MIN_METIERS."""
    sources = []
    for resultat in resultats[:15]:
        formation = resultat['formation']
        if formation.debouches:
            sources.append({
                'titre': f"Débouchés de « {formation.intitule} » ({formation.universite.nom})",
                'texte': formation.debouches,
                'url': liens[formation.universite_id],
                'score': resultat['score'],
                'formation': formation.intitule,
            })

    nb_debouches = len({cache.normaliser_texte(m) for s in sources for m in _debouches(s['texte'])})
    if nb_debouches >= NB_MIN_METIERS:
        return sources

    for resultat_web in _rechercher_metiers_web(donnees['passions'], echeance, avertissements):
        sources.append({
            'titre': resultat_web['titre'], 'texte': resultat_web['contenu'],
            'url': resultat_web['url'], 'score': None,
        })
    return sources[:4]


def _rechercher_metiers_web(passions, echeance, avertissements):
    cle = cache.cle('orientation_web', *sorted(passions))
    en_cache = cache.lire(cle)
    if en_cache is not None:
        return en_cache

    restant = echeance - time.monotonic()
    if restant < TEMPS_MIN_LLM_SECONDES + 2:
        avertissements.append('recherche_web_ignoree_temps')
        return []
    try:
        resultats = tavily_service.rechercher(
            f"métiers et débouchés au Sénégal pour un bachelier passionné de {', '.join(passions)}",
            module=NOM, max_results=5, exclude_domains=fiabilite.domaines_bloques(),
            timeout=min(settings.TAVILY_TIMEOUT_SECONDES, int(restant - TEMPS_MIN_LLM_SECONDES)),
        )
    except tavily_service.TavilyIndisponibleError as exc:
        logger.warning('Orientation : recherche web des métiers impossible (%s)', exc)
        avertissements.append('recherche_web_indisponible')
        return []
    cache.ecrire(cle, resultats, TTL_TAVILY_SECONDES)
    return resultats


def _score_semantique(nom_metier, passions):
    """Métier trouvé sur le web (pas de formation associée) : 50 points parce qu'il
    vient d'une recherche sur les passions de l'élève, + jusqu'à 50 selon sa proximité
    de sens avec ces passions (embeddings multilingues déjà utilisés par le scoring)."""
    similarite = similarite_cosinus(encoder_texte(nom_metier), encoder_texte(' '.join(passions)))
    return 50 + 50 * max(0.0, min(1.0, similarite))


def _passion_la_plus_proche(nom_metier, passions):
    if len(passions) == 1:
        return passions[0]
    vecteur_metier = encoder_texte(nom_metier)
    return max(passions, key=lambda p: similarite_cosinus(vecteur_metier, encoder_texte(p)))


def _justifier_metier(nom, source, passions):
    """Justification construite à partir de faits vérifiés (la source qui cite le
    métier, la passion de l'élève la plus proche) : aucun texte libre du modèle."""
    origine = (
        f"débouché de la formation « {source['formation']} »" if source.get('formation')
        else f"cité dans « {source['titre']} »"
    )
    return f"En lien avec ta passion pour {_passion_la_plus_proche(nom, passions)} : {origine}."


def _metiers_depuis_la_base(sources, deja, passions):
    """Repli sans LLM : débouchés écrits en base, avec le score de leur formation."""
    metiers = []
    for source in sources:
        if source['score'] is None:
            continue
        for nom in _debouches(source['texte']):
            cle = cache.normaliser_texte(nom)
            if cle in deja:
                continue
            deja.add(cle)
            metiers.append({
                'nom': nom[:1].upper() + nom[1:],
                'justification': _justifier_metier(nom, source, passions),
                'score': round(source['score']),
                'source': source['url'],
            })
    return metiers


def _valider_metiers(fiche, sources, donnees):
    metiers, deja = [], set()
    for proposition in (fiche.get('metiers') if isinstance(fiche, dict) else None) or []:
        if not isinstance(proposition, dict):
            continue
        nom = str(proposition.get('nom') or '').strip()
        numero = proposition.get('source')
        if not nom or not isinstance(numero, int) or not 1 <= numero <= len(sources):
            continue
        source = sources[numero - 1]
        # Anti-invention : le métier doit être ÉCRIT dans la source qu'il cite.
        if not texte.present_dans(nom, f"{source['titre']} {source['texte']}"):
            logger.info('Orientation : métier « %s » écarté (absent de sa source).', nom)
            continue
        cle = cache.normaliser_texte(nom)
        if cle in deja:
            continue
        deja.add(cle)

        score = source['score'] if source['score'] is not None else _score_semantique(nom, donnees['passions'])
        metiers.append({
            'nom': nom[:1].upper() + nom[1:120],
            'justification': _justifier_metier(nom, source, donnees['passions']),
            'score': round(score),
            'source': source['url'],
        })
    return metiers, deja


def _choisir_metiers(donnees, sources, echeance, avertissements):
    if not sources:
        avertissements.append('aucune_source_metiers')
        return []

    metiers, deja = [], set()
    restant = echeance - time.monotonic() - 1
    if restant < TEMPS_MIN_LLM_SECONDES:
        avertissements.append('llm_ignore_temps')
    else:
        try:
            reponse = llm_service.generer(
                construire_messages_metiers(donnees, sources),
                modele=llm_service.modele_rapide(), temperature=0.2,
                num_predict=LLM_NUM_PREDICT, timeout=restant,
            )
            metiers, deja = _valider_metiers({'metiers': lire_metiers(reponse)}, sources, donnees)
        except llm_service.LLMTimeoutError:
            avertissements.append('llm_timeout')
        except llm_service.LLMIndisponibleError as exc:
            logger.warning('Orientation : choix des métiers par le LLM impossible (%s)', exc)
            avertissements.append('llm_indisponible')

    if len(metiers) < NB_MIN_METIERS:
        metiers += _metiers_depuis_la_base(sources, deja, donnees['passions'])
    metiers.sort(key=lambda m: m['score'], reverse=True)
    return metiers[:NB_MAX]


# --- Point d'entrée -------------------------------------------------------------

def _enregistrer_historique(utilisateur_id, resultats, formations):
    """Trace les formations recommandées dans la table Laravel `recommandations`."""
    par_id = {str(r['formation'].id): r for r in resultats}
    maintenant = timezone.now()
    Recommandation.objects.bulk_create([
        Recommandation(
            utilisateur_id=utilisateur_id, formation_id=f['id'], score_correspondance=f['score'],
            explication_llm=f['justification'],
            sources_infos={'details_score': par_id[f['id']]['details'], 'source': f['source']},
            date_generation=maintenant,
        )
        for f in formations
    ])


def recommander(donnees):
    """`donnees` : entrée validée par OrientationEntreeSerializer. Retourne le JSON de réponse."""
    debut = time.monotonic()
    echeance = debut + settings.ORIENTATION_TIMEOUT_SECONDES
    cle = _cle_cache(donnees)

    reponse = cache.lire(cle)
    depuis_cache = reponse is not None
    if not depuis_cache:
        avertissements = []
        profil = _profil_scoring(donnees)
        resultats = scoring.generer_recommandations(profil, limite=30)
        if not resultats:
            avertissements.append('aucune_formation_compatible')
        liens = _liens_universites({r['formation'].universite_id for r in resultats})
        sources = _sources_metiers(resultats, donnees, liens, echeance, avertissements)

        reponse = {
            'profil': {
                'serie_bac': donnees['serie_bac'], 'moyenne': float(donnees['moyenne']),
                'passions': donnees['passions'], 'ville': donnees.get('ville') or None,
            },
            'metiers': _choisir_metiers(donnees, sources, echeance, avertissements),
            'formations': _choisir_formations(resultats, donnees, profil, liens),
            'universites': _choisir_universites(resultats, liens),
            'avertissements': avertissements,
            'lien_officiel': LIEN_CAMPUSEN,
        }
        # On ne met en cache qu'une réponse complète : une réponse dégradée (Ollama ou
        # Tavily indisponible) doit pouvoir s'améliorer à la requête suivante.
        if not set(avertissements) & {'llm_timeout', 'llm_indisponible', 'llm_ignore_temps',
                                       'recherche_web_indisponible', 'recherche_web_ignoree_temps'}:
            cache.ecrire(cle, reponse, settings.CACHE_ORIENTATION_TTL_JOURS * 24 * 3600)

        if donnees.get('utilisateur_id') and reponse['formations']:
            _enregistrer_historique(donnees['utilisateur_id'], resultats, reponse['formations'])

    temps_ms = int((time.monotonic() - debut) * 1000)
    logger.info(
        'Orientation %s/%s (%s) : %d métier(s), %d formation(s), %d université(s) en %d ms%s',
        donnees['serie_bac'], donnees['moyenne'], ', '.join(donnees['passions']),
        len(reponse['metiers']), len(reponse['formations']), len(reponse['universites']),
        temps_ms, ' (cache)' if depuis_cache else '',
    )
    return {**reponse, 'depuis_cache': depuis_cache, 'temps_ms': temps_ms}
