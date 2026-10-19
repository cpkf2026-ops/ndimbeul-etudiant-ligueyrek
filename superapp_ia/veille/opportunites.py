"""
Module 2 — Veille Emploi / Stages / Formations / Bourses / Concours.

« Tavily cherche, Mistral rédige » : toutes les VEILLE_INTERVAL_HOURS heures (tâche
Celery `veille_opportunites`) :
  1. UNE seule requête Tavily (1 crédit), restreinte aux sources de confiance
     « emploi » et à la dernière semaine. La requête tourne entre 3 formulations
     combinées : chaque crédit dépensé ramène ainsi des offres différentes, au lieu
     de reposer 12 fois par jour la même question ;
  2. les résultats déjà connus (empreinte URL + titre, ou même URL) sont écartés
     AVANT d'appeler le LLM : on ne paie jamais deux fois le traitement d'une offre ;
  3. Mistral extrait une fiche structurée par résultat (titre, organisme, catégorie,
     lieu, date limite, résumé de 2 lignes) ;
  4. contrôles anti-invention déterministes : une date limite, un organisme ou un
     lieu absents du texte source sont effacés ;
  5. enregistrement dans `offres_emploi` (déjà lue par Laravel et Flutter), puis
     passage en « expiree » des offres dont la date limite est dépassée.

Si Tavily est indisponible ou que la part « veille » du quota est épuisée, la veille
se rabat sur les sources gratuites existantes (flux d'actualités, voir pipeline.py) :
elle ne s'arrête jamais.
"""
import logging
import re
from datetime import date, timedelta

from django.conf import settings
from django.db import IntegrityError
from django.utils import timezone

from services import cache, llm_service, sources, tavily_service, texte

from . import commun, fiabilite, pipeline
from .models import OffreEmploi
from .prompts import construire_messages_opportunite

logger = logging.getLogger(__name__)

NOM = 'opportunites'
CATEGORIES = tuple(valeur for valeur, _ in OffreEmploi.TYPE_CHOICES)

# Requêtes combinées, utilisées à tour de rôle (une par passage, voir commun.rotation).
# Requêtes COURTES, testées sur Tavily le 18/10/2026 avec les sources « emploi » : une
# longue liste de mots-clés renvoie souvent 0 résultat quand include_domains est rempli.
REQUETES = [
    "offre d'emploi Sénégal",                     # 10 résultats (senjob.com)
    "offre de stage Sénégal",                     # 10 résultats (senjob.com)
    "concours bourse Sénégal",                    # 9 résultats (mesrisenegal.sn, campusfrance.org…)
    "appel à candidatures formation Sénégal",     # 10 résultats (mesrisenegal.sn), surtout des pages
                                                  # institutionnelles : MOTS_CANDIDATURE les écarte
]
# La veille tourne en tâche de fond : elle peut attendre Tavily plus longtemps que le chat
# (8 s). Avec une vingtaine de domaines en include_domains, Tavily répond en 3 à 10 s.
TAVILY_TIMEOUT_VEILLE_SECONDES = 30

# Signes qu'une page permet de POSTULER (« * » = toutes les terminaisons : recrute,
# recrutement, recrutons…). Sans aucun de ces mots, ce n'est pas une opportunité ouverte.
MOTS_CANDIDATURE = (
    'recrut*', 'candidat*', 'postul*', 'inscri*', 'poste', 'postes', 'stagiaire*', 'offre',
    'offres', 'emploi', 'stage', 'appel', 'avis', 'cv', 'dossier*', 'limite', 'deposer', 'depot',
    'selection', 'admission', 'concours', 'embauche', 'cdd', 'cdi', 'profil', 'eligib*',
)

MAX_RESULTATS = 10
# Mistral 7B sur CPU : ~3-4 tokens/s. 300 tokens suffisent largement pour la fiche,
# et 5 min par offre laissent de la marge même quand le chat utilise aussi le CPU.
LLM_NUM_PREDICT = 300
LLM_TIMEOUT_SECONDES = 300

NON_PRECISE = 'Non précisé'
NON_PRECISEE = 'Non précisée'


# --- Contrôles anti-invention ---------------------------------------------------

_MOIS = {
    'janvier': 1, 'fevrier': 2, 'mars': 3, 'avril': 4, 'mai': 5, 'juin': 6, 'juillet': 7,
    'aout': 8, 'septembre': 9, 'octobre': 10, 'novembre': 11, 'decembre': 12,
}
_INTRO_DATE_LIMITE = r"(?:avant le|au plus tard le|jusqu au|d ici le|date limite[a-z ]{0,30}?|delai[a-z ]{0,30}?|cloture[a-z ]{0,20}?)"
_DATE_EN_LETTRES = re.compile(
    _INTRO_DATE_LIMITE + r"\s+(?:le\s+)?(?:[a-z]+\s+)?(1er|\d{1,2})\s+(" + '|'.join(_MOIS) + r")(?:\s+(\d{4}))?"
)
_DATE_EN_CHIFFRES = re.compile(_INTRO_DATE_LIMITE + r"\s+(?:le\s+)?(\d{1,2}) (\d{1,2}) (\d{4})")


def date_limite_dans_texte(texte, aujourd_hui):
    """Repli déterministe quand le modèle n'a pas rendu de date limite : cherche une
    date juste après « avant le », « date limite », « jusqu'au »… Sans année écrite,
    on retient la prochaine occurrence de ce jour (« avant le 15 novembre »)."""
    t = cache.normaliser_texte(texte)  # minuscules, sans accents ni ponctuation
    correspondance = _DATE_EN_LETTRES.search(t)
    if correspondance:
        jour_txt, mois_txt, annee_txt = correspondance.groups()
        jour, mois = (1 if jour_txt == '1er' else int(jour_txt)), _MOIS[mois_txt]
    else:
        correspondance = _DATE_EN_CHIFFRES.search(t)
        if not correspondance:
            return None
        jour, mois, annee_txt = int(correspondance[1]), int(correspondance[2]), correspondance[3]
    try:
        if annee_txt:
            return date(int(annee_txt), mois, jour)
        candidate = date(aujourd_hui.year, mois, jour)
        return candidate if candidate >= aujourd_hui else date(aujourd_hui.year + 1, mois, jour)
    except ValueError:  # 31 février, etc.
        return None


_PREFIXES_TITRE = re.compile(
    r"^\s*(?:avis de recrutement|offre d'emploi|offre de stage|appel à candidatures?|recrutement)\s*[:\-–]\s*",
    re.IGNORECASE,
)


def nettoyer_titre(titre):
    """'Avis de recrutement : Stagiaire comptable' -> 'Stagiaire comptable'."""
    nettoye = _PREFIXES_TITRE.sub('', titre).strip()
    return nettoye[:1].upper() + nettoye[1:] if nettoye else titre.strip()


# Pages de LISTE d'un site d'emploi (« Recrutement et offres d'emploi ») : le titre
# rédigé par le modèle reprend alors un pluriel générique, jamais présent dans une annonce.
_MOTS_PAGE_LISTE = {'offres', 'jobs', 'emplois', 'annonces'}


def _est_page_de_liste(titre):
    return bool(_MOTS_PAGE_LISTE & set(cache.normaliser_texte(titre).split()))


def _meme_annonce_deja_publiee(champs):
    """Une même annonce est souvent publiée à deux adresses (rubrique + page de l'offre) :
    l'empreinte URL + titre diffère alors. Même intitulé ET même début de résumé = doublon."""
    debut = cache.normaliser_texte(champs['resume'])[:60]
    resumes = OffreEmploi.objects.filter(
        statut='active', intitule__iexact=champs['intitule'],
    ).values_list('resume', flat=True)
    return any(cache.normaliser_texte(r or '')[:60] == debut for r in resumes)


def _titre_acceptable(titre):
    # pipeline._titre_semble_generique renvoie True quand le titre est ACCEPTABLE
    # (nom historique trompeur) : rejette les pages d'accueil et rubriques de sites.
    return pipeline._titre_semble_generique(titre)


def valider_fiche(resultat, fiche, aujourd_hui):
    """Transforme la fiche du LLM en champs prêts à enregistrer, ou explique le rejet.
    Retourne (champs | None, motif_de_rejet | None, avertissements)."""
    avertissements = []
    if not isinstance(fiche, dict) or fiche.get('pertinent') is not True:
        return None, 'non_pertinent', avertissements

    categorie = str(fiche.get('categorie') or '').strip().lower()
    if categorie not in CATEGORIES:
        return None, 'categorie_invalide', avertissements

    texte_source = f"{resultat['titre']} {resultat['contenu']}"
    # Règle vérifiable en plus du jugement du modèle (trop indulgent en pratique : il a
    # accepté une page « Direction des Bourses » et un séminaire déjà passé) : la page doit
    # montrer qu'on peut POSTULER (recrutement, candidature, inscription, date limite…).
    if not texte.contient_un_mot(texte_source, MOTS_CANDIDATURE):
        return None, 'pas_de_candidature', avertissements

    date_limite = pipeline._parser_date_limite(fiche.get('date_limite'))
    if date_limite and not pipeline._date_ecrite_dans(date_limite, texte_source):
        # Le modèle a proposé une date absente du texte (souvent la date de publication) :
        # on l'efface, sans rejeter l'offre.
        avertissements.append('date_limite_ignoree')
        date_limite = None
    if date_limite is None:
        # Les petits modèles oublient souvent la date limite : repli par règles.
        date_limite = date_limite_dans_texte(texte_source, aujourd_hui)
        if date_limite:
            avertissements.append('date_limite_par_regles')
    if date_limite and date_limite < aujourd_hui:
        return None, 'expiree', avertissements

    def _verifie(cle, defaut):
        valeur = str(fiche.get(cle) or '').strip()
        if valeur and texte.present_dans(valeur, texte_source):
            return valeur[:255]
        if valeur:
            avertissements.append(f'{cle}_ignore')
        return defaut

    titre = nettoyer_titre(str(fiche.get('titre') or '').strip() or resultat['titre'])[:255]
    if _est_page_de_liste(titre):
        return None, 'page_de_liste', avertissements
    resume = str(fiche.get('resume') or '').strip()
    resume_sourcee = texte.phrases_sourcees(resume, texte_source)
    if not resume_sourcee or texte.chiffres_inventes(resume_sourcee, texte_source):
        # Résumé vide, inventé ou contenant un chiffre absent de la page : on reprend la source.
        if resume:
            avertissements.append('resume_remplace')
        resume_sourcee = resultat['contenu']
    resume = texte.resume_court(resume_sourcee, max_phrases=2)

    return {
        'intitule': titre,
        'entreprise': _verifie('organisme', NON_PRECISE),
        'type': categorie,
        'region': _verifie('lieu', NON_PRECISEE),
        'niveau_requis': _verifie('niveau_requis', None),
        # Le domaine est une CLASSIFICATION (informatique, santé…), pas un fait cité :
        # il n'a pas à figurer mot pour mot dans le texte.
        'domaine': (str(fiche.get('domaine') or '').strip() or NON_PRECISE)[:255],
        'date_limite': date_limite,
        'resume': resume,
    }, None, avertissements


# --- Étapes de la veille ----------------------------------------------------------

def _ecarter_deja_connus(resultats, stats):
    """Ne garde que les résultats jamais enregistrés (empreinte ou URL), sans doublon
    interne, et dont le titre ne ressemble pas à une page d'accueil de site."""
    for r in resultats:
        r['hash'] = commun.hash_dedoublonnage(r['url'], r['titre'])

    hashes_connus = set(
        OffreEmploi.objects.filter(hash_dedoublonnage__in=[r['hash'] for r in resultats])
        .values_list('hash_dedoublonnage', flat=True)
    )
    urls_connues = set(
        OffreEmploi.objects.filter(source_url__in=[r['url'][:500] for r in resultats])
        .values_list('source_url', flat=True)
    )

    nouveaux, vus = [], set()
    for r in resultats:
        if r['hash'] in hashes_connus or r['url'][:500] in urls_connues or r['hash'] in vus:
            stats['doublon'] += 1
            continue
        if commun.deja_rejete(NOM, r['hash']):
            stats['deja_rejete'] += 1
            continue
        if not _titre_acceptable(r['titre']):
            stats['titre_generique'] += 1
            continue
        vus.add(r['hash'])
        nouveaux.append(r)
    return nouveaux


def _extraire_fiche(resultat):
    return llm_service.generer_json(
        construire_messages_opportunite(resultat),
        modele=llm_service.modele_veille(),
        temperature=0.1,
        num_predict=LLM_NUM_PREDICT,
        timeout=LLM_TIMEOUT_SECONDES,
        keep_alive=settings.OLLAMA_VEILLE_KEEP_ALIVE,
        num_thread=settings.OLLAMA_VEILLE_NUM_THREAD or None,
    )


def _enregistrer(resultat, champs):
    maintenant = timezone.now()
    date_publication = commun.parser_date_tavily(resultat.get('date_publication'))
    OffreEmploi.objects.create(
        hash_dedoublonnage=resultat['hash'],
        description=champs['resume'],
        source_url=resultat['url'][:500],
        source=fiabilite.nom_source_lisible(resultat['url']),
        # La page vient d'un domaine de confiance (include_domains) : au minimum « plateforme ».
        fiabilite=fiabilite.niveau_fiabilite_offre(resultat['url']) or fiabilite.PLATEFORME,
        date_publication=timezone.localtime(date_publication).date() if date_publication else None,
        statut='active',
        date_indexation=maintenant,
        date_collecte=maintenant,
        **champs,
    )


def _nouvelles_stats(requete):
    return {
        'mode': 'tavily', 'requete': requete, 'candidats': 0, 'doublon': 0, 'deja_rejete': 0,
        'titre_generique': 0, 'non_pertinent': 0, 'categorie_invalide': 0, 'pas_de_candidature': 0, 'page_de_liste': 0, 'expiree': 0,
        'llm_invalide': 0, 'llm_timeout': 0, 'llm_indisponible': 0, 'creees': 0,
        'avertissements': {},
    }


def veille_opportunites(force=False):
    """Un passage complet de la veille des opportunités. Retourne ses statistiques.
    `force=True` ignore le rythme du mode réduit (commande manuelle `veiller`)."""
    if not commun.reserver_passage(NOM, force=force):
        return {'mode': 'ignore', 'raison': commun.raison_ignore()}

    requete = commun.rotation(REQUETES)
    try:
        resultats = tavily_service.rechercher(
            requete, module=NOM, topic='general', time_range='week',
            include_domains=sources.domaines(sources.EMPLOI), max_results=MAX_RESULTATS,
            timeout=TAVILY_TIMEOUT_VEILLE_SECONDES,
        )
    except tavily_service.TavilyIndisponibleError as exc:
        # Quota de la veille épuisé ou Tavily en panne : sources gratuites.
        logger.warning('Veille opportunités : repli sur les sources gratuites (%s)', exc)
        stats = pipeline.veiller_offres()
        stats.update(mode='repli_sources_gratuites', raison=str(exc))
        stats['expirees'] = expirer_opportunites()
        commun.enregistrer_resultat(NOM, stats)
        return stats

    stats = _nouvelles_stats(requete)
    stats['candidats'] = len(resultats)
    aujourd_hui = timezone.localdate()

    nouveaux = _ecarter_deja_connus(resultats, stats)
    if nouveaux:
        commun.precharger_modele_veille()
    for resultat in nouveaux:
        try:
            fiche = _extraire_fiche(resultat)
        except llm_service.LLMTimeoutError:
            stats['llm_timeout'] += 1
            continue
        except llm_service.LLMIndisponibleError as exc:
            # Ollama arrêté : inutile d'insister sur les résultats suivants. Rien n'est
            # enregistré, ils seront retraités au prochain passage.
            logger.error('Veille opportunités interrompue, Ollama indisponible : %s', exc)
            stats['llm_indisponible'] += 1
            break
        except llm_service.LLMReponseInvalideError:
            stats['llm_invalide'] += 1
            continue

        champs, motif, avertissements = valider_fiche(resultat, fiche, aujourd_hui)
        for avertissement in avertissements:
            stats['avertissements'][avertissement] = stats['avertissements'].get(avertissement, 0) + 1
        if champs is None:
            stats[motif] += 1
            commun.marquer_rejete(NOM, resultat['hash'])
            continue

        if _meme_annonce_deja_publiee(champs):
            stats['doublon'] += 1
            commun.marquer_rejete(NOM, resultat['hash'])
            continue
        try:
            _enregistrer(resultat, champs)
        except IntegrityError:
            # Même offre enregistrée entre-temps (autre passage, contrainte URL + intitulé).
            stats['doublon'] += 1
            continue
        stats['creees'] += 1

    stats['expirees'] = expirer_opportunites()
    logger.info('Veille opportunités : %s', stats)
    commun.enregistrer_resultat(NOM, stats)
    return stats


def expirer_opportunites():
    """Passe en « expiree » (jamais de suppression) les offres dont la date limite est
    dépassée ou trop anciennes (règles existantes de pipeline.archiver_offres_obsoletes),
    plus celles sans date de publication collectées il y a plus de
    OFFRES_AGE_MAX_JOURS jours (les pages d'emploi n'ont pas toujours de date)."""
    total = pipeline.archiver_offres_obsoletes()
    limite = timezone.now() - timedelta(days=fiabilite.OFFRES_AGE_MAX_JOURS)
    total += OffreEmploi.objects.filter(
        statut='active', date_publication__isnull=True, date_collecte__lt=limite,
    ).update(statut='expiree')
    return total
