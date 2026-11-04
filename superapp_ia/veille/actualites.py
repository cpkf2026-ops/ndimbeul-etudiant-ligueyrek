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
import html
import logging
import re
from datetime import timedelta
from xml.etree import ElementTree

import httpx
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

# Flux RSS OFFICIELS (gratuits, aucun crédit Tavily), lus à chaque passage en plus de la
# requête Tavily : une seule requête toutes les 2 h ramène souvent 10 articles déjà connus
# ou hors sujet (observé le 18/10/2026 : 0 ajout de 17 h 54 à 1 h). Ces flux sont dédiés à
# l'enseignement (MESRI) ou ont une rubrique Éducation (APS) ; leurs articles suivent
# exactement la même chaîne de contrôles que ceux de Tavily.
FLUX_OFFICIELS = [
    'https://espaceuniversitaire.mesrisenegal.sn/public/rss.xml',
    'https://mesrisenegal.sn/feed',
    'https://aps.sn/category/education/feed/',
]
# Chaque article passe par le modèle local (~1 min) : on borne le nombre d'articles de
# flux traités par passage ; les suivants le seront au passage d'après (ils restent récents).
MAX_FLUX_PAR_PASSAGE = 6
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


def lire_flux_officiels():
    """Articles récents des flux RSS officiels, au format des résultats Tavily."""
    articles = []
    for url_flux in FLUX_OFFICIELS:
        try:
            reponse = httpx.get(url_flux, headers=recherche_web.EN_TETES, timeout=15, follow_redirects=True)
            reponse.raise_for_status()
            racine = ElementTree.fromstring(reponse.content)
        except (httpx.HTTPError, ElementTree.ParseError) as exc:
            logger.warning('Flux %s illisible : %s', url_flux, exc)
            continue
        for item in racine.iter('item'):
            titre = html.unescape((item.findtext('title') or '').strip())
            lien = (item.findtext('link') or '').strip()
            date = commun.parser_date_tavily(item.findtext('pubDate'))
            if not titre or not lien or not fiabilite.est_recente(date):
                continue
            description = re.sub(r'<[^>]+>', ' ', html.unescape(item.findtext('description') or ''))
            articles.append({
                'url': lien, 'titre': titre, 'contenu': re.sub(r'\s+', ' ', description).strip()[:1500],
                'date_publication': item.findtext('pubDate'), 'origine': 'flux',
            })
    # Certains flux (MESRI) mettent la MÊME description générique du site dans chaque article :
    # ce n'est pas le contenu de l'article, on l'efface (la page sera lue à la place).
    repetitions = {}
    for a in articles:
        repetitions[a['contenu']] = repetitions.get(a['contenu'], 0) + 1
    for a in articles:
        if a['contenu'] and repetitions[a['contenu']] >= 3:
            a['contenu'] = ''
    # Les plus récents d'abord : ce sont eux qu'on traite si la limite par passage est atteinte.
    articles.sort(key=lambda a: commun.parser_date_tavily(a['date_publication']), reverse=True)
    return articles


def texte_article(url, titre):
    """Texte réel d'un article (paragraphes de la page liés à son titre) quand le flux ne
    fournit pas de résumé utilisable. '' si la page ne contient rien d'exploitable."""
    try:
        reponse = httpx.get(url, headers=recherche_web.EN_TETES, timeout=15, follow_redirects=True)
        reponse.raise_for_status()
    except httpx.HTTPError:
        return ''
    from bs4 import BeautifulSoup

    soup = BeautifulSoup(reponse.text, 'html.parser')
    paragraphes = [' '.join(p.get_text(' ').split()) for p in (soup.select('article p') or soup.select('main p')
                                                                  or soup.find_all('p'))]
    mots = pipeline._tokens_significatifs(titre)
    utiles = [p for p in paragraphes if len(p) >= 80 and 'cookie' not in p.lower()]
    # Le premier paragraphe qui reprend le sujet du titre ouvre l'article ; on garde la suite.
    # Au moins la moitié des mots du titre (2 mots communs ne suffisent pas : « bourses
    # d'études » se retrouve dans les autres articles de la colonne).
    seuil = max(2, -(-len(mots) // 2))
    for i, p in enumerate(utiles):
        if len(pipeline._tokens_significatifs(p) & mots) >= min(seuil, len(mots)):
            return ' '.join(utiles[i:i + 4])[:1500]
    return ''


def _nouvelles_stats(requete):
    return {
        'mode': 'tavily', 'requete': requete, 'candidats': 0, 'flux_officiels': 0, 'doublon': 0,
        'deja_rejete': 0, 'source': 0,
        'url_trop_longue': 0, 'titre_generique': 0, 'lien_mort': 0, 'reseau': 0, 'date': 0,
        'non_pertinent': 0, 'hors_education': 0, 'sans_contenu': 0, 'llm_invalide': 0, 'llm_timeout': 0,
        'llm_indisponible': 0, 'creees': 0, 'avertissements': {},
    }


def veille_actualites(force=False):
    """Un passage complet de la veille des actualités. Retourne ses statistiques."""
    fenetre = commun.fenetre_recherche(NOM, 'day')
    if not commun.reserver_passage(NOM, force=force):
        return {'mode': 'ignore', 'raison': commun.raison_ignore()}
    hors_ligne = commun.passage_hors_ligne(NOM)
    if hors_ligne:
        return hors_ligne

    requete = commun.rotation(REQUETES)
    try:
        resultats = tavily_service.rechercher(
            requete, module=NOM, topic='news', time_range=fenetre,
            include_domains=sources.domaines(sources.ACTUALITES, sources.ORIENTATION),
            max_results=MAX_RESULTATS, timeout=TAVILY_TIMEOUT_VEILLE_SECONDES,
        )
    except tavily_service.TavilyIndisponibleError as exc:
        logger.warning('Veille actualités : repli sur les sources gratuites (%s)', exc)
        stats = pipeline.veiller_actualites()
        pipeline.backfiller_metadonnees_actualites()
        stats.update(mode='repli_sources_gratuites', raison=str(exc))
        commun.enregistrer_resultat(NOM, stats)
        return stats

    stats = _nouvelles_stats(requete)
    stats['candidats'] = len(resultats)
    urls_tavily = {commun.normaliser_url(r['url']) for r in resultats}
    flux = [a for a in lire_flux_officiels() if commun.normaliser_url(a['url']) not in urls_tavily]
    stats['flux_officiels'] = len(flux)

    nouveaux = _ecarter_deja_connus(resultats + flux, stats)
    nouveaux = ([a for a in nouveaux if a.get('origine') != 'flux']
                + [a for a in nouveaux if a.get('origine') == 'flux'][:MAX_FLUX_PAR_PASSAGE])
    a_traiter = [a for a in nouveaux if _verifier_page(a, stats)]
    for article in a_traiter:
        # Article de flux sans résumé utilisable : on lit la page (texte réel de l'article).
        if article.get('origine') == 'flux' and len(article.get('contenu') or '') < 80:
            article['contenu'] = texte_article(article['url'], article['titre']) or article.get('contenu') or ''
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
    commun.enregistrer_resultat(NOM, stats)
    return stats
