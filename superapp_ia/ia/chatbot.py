"""
Module 4 — Chatbot (assistant conversationnel), réponse JSON en moins de 30 s.

Ordre de traitement d'un message :
  1. Intention par règles (ia/intentions.py) : salutation, remerciement, au revoir ou
     hors sujet -> réponse immédiate, sans recherche ni LLM.
  2. Cache Redis (24 h) des questions fréquentes : réponse instantanée.
  3. Notre base : établissements, formations, offres et
     actualités déjà collectées (ia/rag_local.py).
  4. Si la base ne suffit pas : UNE recherche Tavily (8 s max, priorité aux sites
     officiels via include_domains), seulement s'il reste du temps et des crédits.
  5. Le modèle rapide rédige une réponse courte en citant ses sources [n]. Il reçoit
     le temps restant : à l'échéance, on garde les phrases déjà complètes, ou on
     renvoie une réponse de secours avec les liens trouvés.
  6. Rien trouvé : on ne laisse pas le LLM improviser, on le dit honnêtement et on
     donne les liens officiels où chercher.

Contrôles après génération : liens absents des sources supprimés, citations [n]
invalides supprimées, réponse contenant un chiffre absent des sources remplacée par
la réponse de secours. Le temps de chaque requête est mesuré et écrit dans logs/ia.log.
"""
import logging
import re
import time

from django.conf import settings
from django.db import DatabaseError

from services import cache, llm_service, sources as sources_confiance, tavily_service, texte
from veille.models import Universite

from . import intentions, prompts, rag_local, reponses_base
from .models import ConversationIA

logger = logging.getLogger(__name__)

NB_MESSAGES_HISTORIQUE = 5
# En dessous de ce temps restant, le LLM n'aurait pas le temps d'écrire une phrase.
TEMPS_MIN_LLM_SECONDES = 6
# Une source locale (mots-clés) est gardée si elle contient au moins 2 mots importants
# de la question, ou la moitié d'entre eux (questions très courtes).
NB_MOTS_MIN_PERTINENCE = 2
SEUIL_PERTINENCE_LOCALE = 0.5
# La base suffit si une fiche couvre au moins 60 % des mots importants de la question.
# Observé le 18/10/2026 : « rentrée universitaire à l'UGB » trouvait la fiche de l'UGB
# (« UGB », « universitaire ») mais rien sur la rentrée ; compter les fiches ne suffit pas.
COUVERTURE_SUFFISANTE = 0.6
# Sources réellement envoyées au modèle : chacune ajoute ~70 tokens à lire (~3 s).
NB_SOURCES_PROMPT = 3
# Marge entre la fin de la génération et l'échéance : arrêt du flux, contrôles, réponse.
MARGE_FIN_SECONDES = 1.5
NB_SOURCES_MAX = 5

LIENS_PAR_DEFAUT = ['https://campusen.sn', 'https://mesrisenegal.sn']
LIENS_THEMATIQUES = {
    'bac': 'https://officedubac.sn', 'examen': 'https://officedubac.sn',
    'bfem': 'https://education.sn', 'orientation': 'https://campusen.sn',
    'bourse': 'https://mesrisenegal.sn', 'concours': 'https://fonctionpublique.gouv.sn',
    'emploi': 'https://senjob.com', 'stage': 'https://senjob.com', 'recrutement': 'https://senjob.com',
}
_MOTS_EMPLOI = {'emploi', 'stage', 'recrutement', 'offre', 'offres', 'concours', 'travail', 'alternance'}

_PHRASE_INTROUVABLE = (
    "Je n'ai rien trouvé de fiable sur « {sujet} » dans nos données ni sur les sites officiels "
    "consultés, et je préfère ne pas te donner une réponse approximative. Essaie avec d'autres "
    "mots-clés (établissement, filière, ville), ou vérifie directement ici : {liens}."
)
# « Le lien / le site / l'adresse de l'UCAD » : réponse directe depuis la base.
_MOTS_DEMANDE_DE_LIEN = {'lien', 'liens', 'site', 'sites', 'adresse', 'url', 'web', 'internet'}
_PHRASE_SECOURS = "Voici ce que j'ai trouvé pour ta question :\n{lignes}"
# Réponse de secours : au plus 2 sources, chacune réduite à ses phrases utiles.
NB_SOURCES_SECOURS = 2
LONGUEUR_EXTRAIT_SECOURS = 220


# --- Conversation ---------------------------------------------------------------

def _charger_conversation(conversation_id, utilisateur_id):
    """Conversation persistée pour un utilisateur connecté (la table exige un utilisateur
    existant). Retourne None en mode visiteur ou si la base refuse l'enregistrement."""
    if not utilisateur_id:
        return None
    try:
        if conversation_id:
            conversation = ConversationIA.objects.filter(id=conversation_id, utilisateur_id=utilisateur_id).first()
            if conversation:
                return conversation
        return ConversationIA.objects.create(utilisateur_id=utilisateur_id, messages=[])
    except DatabaseError as exc:
        logger.warning('Conversation non enregistrée (utilisateur %s) : %s', utilisateur_id, exc)
        return None


def _sauvegarder(conversation, message, reponse, sources):
    if conversation is None:
        return
    try:
        conversation.ajouter_message('user', message)
        conversation.ajouter_message('assistant', reponse, sources)
    except DatabaseError as exc:
        logger.warning('Historique de conversation non sauvegardé : %s', exc)


# --- Recherche ------------------------------------------------------------------

def _mots_importants(question):
    return [cache.normaliser_texte(m) for m in rag_local._mots_cles(question, max_mots=8)]


def _racine(mot):
    """Début du mot, pour qu'une forme proche compte aussi : « stage » retrouve
    « stagiaire », « offres » retrouve « offre », « comptabilité » retrouve « comptable »."""
    return mot[:5] if len(mot) >= 7 else mot[:4]


def _nb_mots_trouves(document, mots):
    contenu = cache.normaliser_texte(f"{document.get('titre', '')} {document['texte']}").split()
    return sum(any(t.startswith(_racine(m)) for t in contenu) for m in mots)


def _garder_pertinents(documents, mots):
    """Documents contenant assez de mots de la question, les plus pertinents d'abord."""
    candidats = [(_nb_mots_trouves(d, mots), d) for d in documents]
    return [
        d for nb, d in sorted(candidats, key=lambda c: c[0], reverse=True)
        if mots and (nb >= NB_MOTS_MIN_PERTINENCE or nb / len(mots) >= SEUIL_PERTINENCE_LOCALE)
    ]


# Mots présents dans presque toutes les fiches (« universitaire » retrouve « Université »
# dans chaque établissement) : ils aident à retrouver les fiches, mais ne disent rien du
# SUJET de la question, donc ne comptent pas pour juger si la base y répond.
_RACINES_GENERIQUES = ('unive', 'ecole', 'insti', 'etabl', 'etudi', 'seneg')


def _base_suffisante(documents, mots):
    """Vrai si au moins une fiche de la base couvre l'essentiel du sujet de la question."""
    sujet = [m for m in mots if not m.startswith(_RACINES_GENERIQUES)] or mots
    if not sujet:
        return bool(documents)
    return any(_nb_mots_trouves(d, sujet) / len(sujet) >= COUVERTURE_SUFFISANTE for d in documents)


def chercher_dans_la_base(question):
    """Fiches de notre base (établissements, formations, offres, actualités), classées par
    nombre de mots de la question qu'elles contiennent.

    La recherche sémantique FAISS n'est pas utilisée ici : elle charge torch (~1 Go de RAM,
    ~45 s au premier appel) pour quelques documents d'exemple, ce qui bloquait un PC de
    10 Go et dépassait le budget de 25 s. La base + Tavily couvrent les questions."""
    return _garder_pertinents(rag_local.rechercher_tout(question), _mots_importants(question))[:NB_SOURCES_MAX]


def _chercher_sur_le_web(question, historique, echeance, avertissements):
    restant = echeance - time.monotonic() - TEMPS_MIN_LLM_SECONDES
    if restant < 2:
        avertissements.append('recherche_web_ignoree_temps')
        return []
    # Question courte de suivi (« et à l'UGB ? ») : on lui redonne le contexte du dernier message.
    requete = question
    derniers_messages = [t for t in historique if t.get('role') == 'user']
    if derniers_messages and len(question.split()) < 6:
        requete = f"{derniers_messages[-1].get('contenu') or derniers_messages[-1].get('content', '')} {question}"

    mots = set(cache.normaliser_texte(question).split())
    categories = (
        (sources_confiance.EMPLOI, sources_confiance.ORIENTATION) if mots & _MOTS_EMPLOI
        else (sources_confiance.ORIENTATION, sources_confiance.ACTUALITES)
    )
    try:
        resultats = tavily_service.rechercher(
            requete, module='chat', include_domains=sources_confiance.domaines(*categories),
            max_results=5, timeout=min(settings.TAVILY_TIMEOUT_SECONDES, int(restant)),
        )
    except tavily_service.QuotaTavilyAtteintError:
        avertissements.append('quota_tavily_atteint')
        return []
    except tavily_service.TavilyIndisponibleError:
        avertissements.append('recherche_web_indisponible')
        return []
    documents = [
        {'titre': r['titre'] or r['url'], 'texte': r['contenu'], 'url': r['url'], 'categorie': 'web'}
        for r in resultats if r['contenu']
    ]
    # Même règle de pertinence que pour la base : Tavily renvoie parfois un article du bon
    # site mais hors sujet (ex. des inondations pour une question sur l'ENA).
    return _garder_pertinents(documents, _mots_importants(question))


def _sigles(nom, code):
    """Sigles reconnus pour un établissement : son code s'il fait au moins 3 lettres, et
    ceux écrits entre parenthèses dans son nom (« Université Gaston Berger (UGB) » -> ugb),
    car certains codes en base ont été générés automatiquement (ex. « GBSLU »)."""
    candidats = [code or ''] + re.findall(r'\(([^)]{2,15})\)', nom or '')
    return {s for s in (cache.normaliser_texte(c).replace(' ', '') for c in candidats) if len(s) >= 3}


def _etablissement_cite(nom, code, mots, texte_question):
    return bool(_sigles(nom, code) & mots) or f' {cache.normaliser_texte(nom)} ' in texte_question


def liens_officiels(question):
    """Sites officiels où l'élève peut vérifier l'information : établissement cité dans
    la question, puis site lié au thème (bac, bourses, emploi…), puis Campusen/MESRI."""
    texte_question = f" {cache.normaliser_texte(question)} "
    mots = set(texte_question.split())
    liens = []
    try:
        for nom, code, site in Universite.objects.filter(statut_actif=True).exclude(
            site_web_officiel__isnull=True,
        ).exclude(site_web_officiel='').values_list('nom', 'code_unique', 'site_web_officiel'):
            if _etablissement_cite(nom, code, mots, texte_question):
                liens.append(site)
    except DatabaseError:
        pass
    liens += [lien for mot, lien in LIENS_THEMATIQUES.items() if mot in mots]
    liens += LIENS_PAR_DEFAUT
    return list(dict.fromkeys(liens))[:4]


# --- Rédaction ------------------------------------------------------------------

def _couper_a_la_derniere_phrase(texte_partiel):
    fin = max(texte_partiel.rfind('.'), texte_partiel.rfind('!'), texte_partiel.rfind('?'))
    return texte_partiel[:fin + 1].strip() if fin > 20 else ''


def _rediger(messages, echeance):
    """Génère en streaming jusqu'à l'échéance. Retourne (texte | None, avertissement | None)."""
    morceaux, tronquee = [], False
    flux = llm_service.generer_stream(
        messages, modele=llm_service.modele_rapide(), temperature=0.2,
        num_predict=settings.CHAT_NUM_PREDICT, timeout=max(echeance - time.monotonic(), 1),
    )
    try:
        for morceau in flux:
            morceaux.append(morceau)
            if time.monotonic() >= echeance:
                tronquee = True
                break
    except llm_service.LLMTimeoutError:
        tronquee = True
    except llm_service.LLMIndisponibleError as exc:
        logger.error('Chat : Ollama indisponible : %s', exc)
        return None, 'llm_indisponible'
    finally:
        flux.close()  # libère la connexion à Ollama (génération interrompue)

    reponse = ''.join(morceaux).strip()
    if tronquee:
        reponse = _couper_a_la_derniere_phrase(reponse)
        return (reponse or None), 'reponse_tronquee' if reponse else 'llm_timeout'
    return (reponse or None), None


def _nettoyer(reponse, documents, liens):
    """Supprime les liens inventés et les citations [n] qui ne renvoient à aucune source."""
    liens_autorises = {d['url'] for d in documents if d.get('url')} | set(liens)

    def _lien(correspondance):
        url = correspondance.group(0).rstrip('.,;:)')
        return correspondance.group(0) if url in liens_autorises else ''

    reponse = re.sub(r'https?://\S+', _lien, reponse)
    reponse = re.sub(
        r'\[(\d+)\]', lambda c: c.group(0) if 1 <= int(c.group(1)) <= len(documents) else '', reponse,
    )
    # Faux renvois écrits par le modèle à la place d'un numéro (« [lien] », « [source] »).
    reponse = re.sub(r'\s*\[(?:lien|link|source|url|site)[^\]]{0,20}\]', '', reponse, flags=re.IGNORECASE)
    return re.sub(r' {2,}', ' ', reponse).strip()


def _sources_affichees(documents):
    vues, sources = set(), []
    for document in documents:
        titre = document.get('titre') or 'Source'
        if titre not in vues:
            vues.add(titre)
            sources.append({'titre': titre, 'url': document.get('url')})
    return sources


def _introuvable(question, liens):
    sujet = ' '.join(_mots_importants(question)[:5]) or question.strip()[:60]
    return _PHRASE_INTROUVABLE.format(sujet=sujet, liens=', '.join(liens))


def _site_demande(question):
    """Si l'élève demande le site d'un établissement (« le lien du site de l'UCAD »),
    retourne (nom, site) trouvé en base ; sinon None. Aucun appel web ni LLM."""
    mots = set(cache.normaliser_texte(question).split())
    if not mots & _MOTS_DEMANDE_DE_LIEN:
        return None
    texte_question = f" {cache.normaliser_texte(question)} "
    try:
        etablissements = Universite.objects.filter(statut_actif=True).exclude(
            site_web_officiel__isnull=True,
        ).exclude(site_web_officiel='').values_list('nom', 'code_unique', 'site_web_officiel')
        for nom, code, site in etablissements:
            if _etablissement_cite(nom, code, mots, texte_question):
                return nom, site
    except DatabaseError:
        pass
    return None


def _reponse_secours(documents, liens, question):
    """Quand le modèle n'a pas pu rédiger à temps (PC chargé, Ollama arrêté) ou a inventé :
    on cite directement les phrases utiles des meilleures sources, numérotées comme dans
    `sources`. Réponse factuelle et immédiate, au lieu d'un simple lien."""
    if not documents:
        return _introuvable(question, liens)
    mots = _mots_importants(question)
    lignes = [
        f"• {d['titre']} : {texte.extrait_pertinent(d['texte'], mots, LONGUEUR_EXTRAIT_SECOURS)} [{i}]"
        for i, d in enumerate(documents[:NB_SOURCES_SECOURS], start=1)
    ]
    return _PHRASE_SECOURS.format(lignes='\n'.join(lignes))


# --- Point d'entrée -------------------------------------------------------------

def repondre(message, conversation_id=None, utilisateur_id=None, profil=None, historique=None):
    debut = time.monotonic()
    echeance = debut + settings.CHAT_TIMEOUT_SECONDES
    profil = profil or {}
    conversation = _charger_conversation(conversation_id, utilisateur_id)
    if conversation is not None:
        historique = conversation.messages or []
    # Laravel enregistre aussi dans la conversation le flux SSE brut (« data: {...} ») :
    # ce texte technique n'a rien à faire dans l'historique envoyé au modèle.
    historique = [
        tour for tour in (historique or [])
        if not str(tour.get('contenu') or tour.get('content') or '').lstrip().startswith(('data:', ':'))
    ][-NB_MESSAGES_HISTORIQUE:]

    resultat = {'avertissements': [], 'depuis_cache': False, 'recherche_web': False}
    intention = intentions.detecter(message)

    if intention != intentions.QUESTION:
        resultat.update(reponse=intentions.reponse_rapide(intention, message), sources=[])
    else:
        # Le cache n'est utilisé que pour une question posée en début de conversation :
        # une question de suivi (« et pour l'UGB ? ») dépend de l'historique.
        cle = cache.cle('chat', message) if not historique else None
        en_cache = cache.lire(cle) if cle else None
        if en_cache:
            resultat.update(en_cache, depuis_cache=True)
        else:
            resultat.update(_repondre_question(message, profil, historique, echeance))
            if cle and not resultat['avertissements']:
                cache.ecrire(cle, {k: resultat[k] for k in ('reponse', 'sources', 'recherche_web')},
                             settings.CACHE_REPONSE_TTL_HEURES * 3600)

    _sauvegarder(conversation, message, resultat['reponse'], resultat['sources'])
    resultat.update(
        intention=intention,
        conversation_id=str(conversation.id) if conversation else None,
        temps_ms=int((time.monotonic() - debut) * 1000),
    )
    logger.info(
        'Chat [%s] %d ms — %d source(s), web=%s, cache=%s, avertissements=%s',
        intention, resultat['temps_ms'], len(resultat['sources']), resultat['recherche_web'],
        resultat['depuis_cache'], resultat['avertissements'] or 'aucun',
    )
    return resultat


def _repondre_question(message, profil, historique, echeance):
    site = _site_demande(message)
    if site:
        nom, url = site
        return {
            'reponse': f"Le site officiel de « {nom} » est : {url} [1]",
            'sources': [{'titre': nom, 'url': url}],
            'recherche_web': False,
            'avertissements': [],
        }
    # Questions de tous les jours (actualités, offres, établissements d'une ville) : réponse
    # exacte et immédiate depuis la base, sans attendre le modèle (voir ia/reponses_base.py).
    instantanee = reponses_base.repondre(message)
    if instantanee:
        return {**instantanee, 'recherche_web': False, 'avertissements': []}
    avertissements = []
    liens = liens_officiels(message)
    documents = chercher_dans_la_base(message)
    recherche_web = False
    if not _base_suffisante(documents, _mots_importants(message)):
        documents_web = _chercher_sur_le_web(message, historique, echeance, avertissements)
        recherche_web = bool(documents_web)
        # La base ne couvrait pas la question : les résultats web, plus pertinents, d'abord.
        documents = (documents_web + documents)[:NB_SOURCES_MAX]

    if not documents:
        # Rien trouvé : réponse honnête, sans laisser le modèle improviser.
        return {
            'reponse': _introuvable(message, liens),
            'sources': [{'titre': lien.split('//')[-1], 'url': lien} for lien in liens],
            'recherche_web': recherche_web,
            'avertissements': avertissements + ['information_introuvable'],
        }

    reponse, avertissement = None, None
    if echeance - time.monotonic() < TEMPS_MIN_LLM_SECONDES:
        avertissement = 'llm_ignore_temps'
    else:
        documents = documents[:NB_SOURCES_PROMPT]
        messages = prompts.construire_messages_chat(
            message, documents, liens, profil, historique, mots_cles=_mots_importants(message),
        )
        reponse, avertissement = _rediger(messages, echeance - MARGE_FIN_SECONDES)
    if avertissement:
        avertissements.append(avertissement)

    if reponse:
        reponse = _nettoyer(reponse, documents, liens)
        texte_autorise = ' '.join(
            [message, str(profil)] + [d['texte'] for d in documents]
            + [str(t.get('contenu') or t.get('content') or '') for t in historique]
        )
        if texte.chiffres_inventes(reponse, texte_autorise):
            logger.warning('Chat : réponse écartée (chiffre absent des sources) : %s', reponse[:200])
            avertissements.append('chiffre_non_source')
            reponse = None

    return {
        'reponse': reponse or _reponse_secours(documents, liens, message),
        'sources': _sources_affichees(documents),
        'recherche_web': recherche_web,
        'avertissements': avertissements,
    }
