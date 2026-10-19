"""
Module 3 — Actualités Éducation au Sénégal.

Toutes les VEILLE_INTERVAL_HOURS heures (tâche Celery `veille_actualites`) :
  1. UNE seule requête Tavily `topic="news"`, `time_range="day"` (1 crédit), limitée à
     la presse reconnue et aux sites officiels (universités, ministères, Campusen).
     Trois formulations combinées tournent d'un passage à l'autre (examens et
     orientation / universités et bourses / annonces officielles) ;
  2. les articles déjà connus (empreinte URL + titre, même URL, titre quasi identique)
     sont écartés avant tout traitement coûteux ;
  3. la page de l'article est lue : lien vivant, date réelle, image réelle (og:image),
     jamais de date ni d'image inventée ;
  4. Mistral juge la pertinence et rédige titre, résumé de 3 lignes et catégorie ;
  5. enregistrement dans `actualites` (statut « publie »), table déjà lue par Flutter.

Repli identique au module 2 : sources gratuites si Tavily est indisponible ou si la
part « veille » du quota est épuisée.
"""
import logging
from datetime import timedelta

from django.conf import settings
from django.db import IntegrityError
from django.utils import timezone

from services import llm_service, sources, tavily_service, texte

from . import commun, fiabilite, pipeline, recherche_web
from .models import Actualite
from .prompts import construire_messages_actualite

logger = logging.getLogger(__name__)

NOM = 'actualites'
CATEGORIES = tuple(valeur for valeur, _ in Actualite.CATEGORIE_CHOICES)

# Requêtes COURTES, testées sur Tavily le 18/10/2026 (topic="news", time_range="day",
# presse + sites officiels) : chacune a ramené 10 articles datés du jour. Les requêtes
# longues (« bac, BFEM, examens, résultats… ») et « université Sénégal étudiants »
# renvoyaient 0 résultat : l'index d'actualités de Tavily répond mieux aux sujets larges.
REQUETES = [
    "éducation Sénégal",       # senego, lesoleil, aps, pressafrik
    "baccalauréat Sénégal",    # senego, lesoleil
    "étudiants Sénégal",       # lesoleil, aps, dakaractu, mesrisenegal, campusfrance
    "bourses Sénégal",         # senego, lesoleil, aps, seneplus
]
TAVILY_TIMEOUT_VEILLE_SECONDES = 30

# Vocabulaire de l'éducation : le titre d'une actualité publiée doit en contenir au moins
# un mot (« * » = toutes les terminaisons). Liste volontairement large : elle sert à
# écarter les sujets étrangers à l'éducation (diplomatie, sport…), pas à trier finement.
MOTS_EDUCATION = (
    'bac', 'baccalaureat', 'bfem', 'cfee', 'examen*', 'concours', 'bourse*', 'etudiant*', 'eleve*',
    'ecole*', 'scolaire*', 'universit*', 'enseign*', 'education', 'educatif*', 'lycee*', 'college*',
    'formation*', 'orientation', 'campusen', 'rentree', 'diplome*', 'isep', 'ucad', 'ugb', 'uadb',
    'uasz', 'unchk', 'mesri', 'apprenant*', 'professeur*', 'syndicat*', 'greve*', 'cours',
    'campus', 'coud', 'codification', 'recteur*', 'faculte*', 'master', 'licence', 'doctorat',
)

MAX_RESULTATS = 10
LLM_NUM_PREDICT = 250
LLM_TIMEOUT_SECONDES = 300
# La colonne actualites.source_url fait 255 caractères : une URL plus longue serait
# tronquée, donc cassée. On préfère ne pas publier l'article.
LONGUEUR_MAX_URL = 255


def _tokens(titre):
    return pipeline._tokens_significatifs(titre)


def _quasi_identique(tokens, tokens_connus):
    """Même règle que la veille existante : 70 % de mots significatifs en commun."""
    return bool(tokens) and any(
        connus and len(tokens & connus) / max(1, min(len(tokens), len(connus))) >= 0.7
        for connus in tokens_connus
    )


def _ecarter_deja_connus(resultats, stats):
    for r in resultats:
        r['hash'] = commun.hash_dedoublonnage(r['url'], r['titre'])

    hashes_connus = set(
        Actualite.objects.filter(hash_dedoublonnage__in=[r['hash'] for r in resultats])
        .values_list('hash_dedoublonnage', flat=True)
    )
    urls_connues = set(
        Actualite.objects.filter(source_url__in=[r['url'] for r in resultats])
        .values_list('source_url', flat=True)
    )
    titres_recents = [
        _tokens(t) for t in Actualite.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=fiabilite.RETENTION_JOURS),
        ).values_list('titre', flat=True)
    ]

    nouveaux = []
    for r in resultats:
        if r['hash'] in hashes_connus or r['url'] in urls_connues or _quasi_identique(_tokens(r['titre']), titres_recents):
            stats['doublon'] += 1
            continue
        if commun.deja_rejete(NOM, r['hash']):
            stats['deja_rejete'] += 1
            continue
        if len(r['url']) > LONGUEUR_MAX_URL:
            stats['url_trop_longue'] += 1
            continue
        r['fiabilite'] = fiabilite.niveau_fiabilite(r['url'])
        if r['fiabilite'] is None:
            stats['source'] += 1
            continue
        if not pipeline._titre_semble_generique(r['titre']):  # True = titre acceptable
            stats['titre_generique'] += 1
            continue
        titres_recents.append(_tokens(r['titre']))
        nouveaux.append(r)
    return nouveaux


def _verifier_page(article, stats):
    """Lit la page de l'article : lien vivant, date réelle récente, image.
    Retourne False si l'article doit être écarté."""
    meta = recherche_web.extraire_metadonnees_article(article['url'])
    if not meta['accessible']:
        # Coupure réseau ≠ lien mort : un article injoignable sera retenté au prochain passage.
        stats['reseau' if meta.get('erreur_reseau') else 'lien_mort'] += 1
        return False
    date_reelle = commun.parser_date_tavily(article.get('date_publication')) or meta['date_publication']
    if not fiabilite.est_recente(date_reelle):
        stats['date'] += 1
        return False
    article['date_reelle'] = date_reelle
    article['image_page'] = meta['image']
    article['media'] = fiabilite.nom_source_lisible(article['url'])
    return True


def valider_fiche(article, fiche):
    """Retourne (champs | None, motif | None, avertissements)."""
    avertissements = []
    if not isinstance(fiche, dict) or fiche.get('pertinent') is not True:
        return None, 'non_pertinent', avertissements

    titre = str(fiche.get('titre') or '').strip() or article['titre']
    if not pipeline._titre_semble_generique(titre):
        return None, 'titre_generique', avertissements
    # Règle vérifiable en plus du jugement du modèle (trop indulgent en pratique : il a
    # accepté « Négociations AES-CEDEAO ») : le TITRE de l'article doit parler d'éducation.
    if not texte.contient_un_mot(f"{article['titre']} {titre}", MOTS_EDUCATION):
        return None, 'hors_education', avertissements

    categorie = str(fiche.get('categorie') or '').strip().lower()
    if categorie not in CATEGORIES:
        avertissements.append('categorie_corrigee')
        categorie = 'general'

    texte_source = f"{article['titre']} {article['contenu']}"
    if texte.chiffres_inventes(titre, texte_source):
        avertissements.append('titre_remplace')
        titre = article['titre']
    resume = str(fiche.get('resume') or '').strip()
    resume_sourcee = texte.phrases_sourcees(resume, texte_source)
    if not resume_sourcee or texte.chiffres_inventes(resume_sourcee, texte_source):
        if resume:
            avertissements.append('resume_remplace')
        resume_sourcee = article['contenu']
    elif resume_sourcee != resume:
        avertissements.append('phrase_non_sourcee_retiree')
    resume = resume_sourcee
    if not resume:
        return None, 'sans_contenu', avertissements

    return {
        'titre': titre[:255],
        'contenu': texte.resume_court(resume, max_phrases=3),
        'categorie': categorie,
    }, None, avertissements


def _resumer(article):
    return llm_service.generer_json(
        construire_messages_actualite(article),
        modele=llm_service.modele_veille(),
        temperature=0.2,
        num_predict=LLM_NUM_PREDICT,
        timeout=LLM_TIMEOUT_SECONDES,
        keep_alive=settings.OLLAMA_VEILLE_KEEP_ALIVE,
        num_thread=settings.OLLAMA_VEILLE_NUM_THREAD or None,
    )


def _enregistrer(article, champs):
    Actualite.objects.create(
        hash_dedoublonnage=article['hash'],
        source_url=article['url'],
        # Image réelle de l'article, stockée localement (voir recherche_web) ; None sinon.
        image_url=recherche_web.telecharger_image_locale(article.get('image_page')),
        date_publication=article['date_reelle'],
        source_nom=article['media'],
        fiabilite=article['fiabilite'],
        statut='publie',
        **champs,
    )


def _nouvelles_stats(requete):
    return {
        'mode': 'tavily', 'requete': requete, 'candidats': 0, 'doublon': 0, 'deja_rejete': 0, 'source': 0,
        'url_trop_longue': 0, 'titre_generique': 0, 'lien_mort': 0, 'reseau': 0, 'date': 0,
        'non_pertinent': 0, 'hors_education': 0, 'sans_contenu': 0, 'llm_invalide': 0, 'llm_timeout': 0,
        'llm_indisponible': 0, 'creees': 0, 'avertissements': {},
    }


def veille_actualites(force=False):
    """Un passage complet de la veille des actualités. Retourne ses statistiques."""
    if not commun.reserver_passage(NOM, force=force):
        return {'mode': 'ignore', 'raison': 'mode réduit : dernier passage trop récent'}

    requete = commun.rotation(REQUETES)
    try:
        resultats = tavily_service.rechercher(
            requete, module=NOM, topic='news', time_range='day',
            include_domains=sources.domaines(sources.ACTUALITES, sources.ORIENTATION),
            max_results=MAX_RESULTATS, timeout=TAVILY_TIMEOUT_VEILLE_SECONDES,
        )
    except tavily_service.TavilyIndisponibleError as exc:
        logger.warning('Veille actualités : repli sur les sources gratuites (%s)', exc)
        stats = pipeline.veiller_actualites()
        pipeline.backfiller_metadonnees_actualites()
        stats.update(mode='repli_sources_gratuites', raison=str(exc))
        return stats

    stats = _nouvelles_stats(requete)
    stats['candidats'] = len(resultats)

    a_traiter = [a for a in _ecarter_deja_connus(resultats, stats) if _verifier_page(a, stats)]
    if a_traiter:
        commun.precharger_modele_veille()
    for article in a_traiter:
        try:
            fiche = _resumer(article)
        except llm_service.LLMTimeoutError:
            stats['llm_timeout'] += 1
            continue
        except llm_service.LLMIndisponibleError as exc:
            logger.error('Veille actualités interrompue, Ollama indisponible : %s', exc)
            stats['llm_indisponible'] += 1
            break
        except llm_service.LLMReponseInvalideError:
            stats['llm_invalide'] += 1
            continue

        champs, motif, avertissements = valider_fiche(article, fiche)
        for avertissement in avertissements:
            stats['avertissements'][avertissement] = stats['avertissements'].get(avertissement, 0) + 1
        if champs is None:
            stats[motif] += 1
            commun.marquer_rejete(NOM, article['hash'])
            continue

        try:
            _enregistrer(article, champs)
        except IntegrityError:
            stats['doublon'] += 1
            continue
        stats['creees'] += 1

    logger.info('Veille actualités : %s', stats)
    return stats
