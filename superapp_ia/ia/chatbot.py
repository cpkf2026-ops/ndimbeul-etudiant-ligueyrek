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

from . import agent, etablissements_chat, intentions, prompts, rag_local, reponses_base
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


def liens_officiels(question):
    """Sites officiels où l'élève peut vérifier l'information : établissement cité dans
    la question, puis site lié au thème (bac, bourses, emploi…), puis Campusen/MESRI."""
    texte_question = f" {cache.normaliser_texte(question)} "
    mots = set(texte_question.split())
    liens = []
    # Même repérage que pour les demandes de site (sigles qui ne sont pas des mots courants,
    # mots distinctifs du nom) : avant, « il a dit » ajoutait le site du DIT.
    etablissement = etablissements_chat.trouver(question)
    if etablissement and etablissement['site_web_officiel']:
        liens.append(etablissement['site_web_officiel'])
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


def _site_demande(question, historique=None):
    """Si l'élève demande le site d'un établissement (« le lien du site de l'UCAD », « le site
    de CETTE université »), retourne la réponse construite depuis la base ; sinon None.
    Aucun appel web ni LLM : avant, une demande mal reconnue partait sur le web et ramenait
    Campus France, ou un autre établissement (« dit » pris pour le sigle DIT)."""
    mots = set(cache.normaliser_texte(question).split())
    if not mots & _MOTS_DEMANDE_DE_LIEN:
        return None
    # « le site de cette université » juste après une LISTE d'établissements : on ne devine pas
    # lequel, on donne le site de chacun.
    if (etablissements_chat.trouver(question) is None
            and etablissements_chat.renvoie_a_un_etablissement(question)):
        cites = etablissements_chat.cites_dans_la_derniere_reponse(historique)
        if len(cites) > 1:
            lignes = [f"• {u['nom']} : {u['site_web_officiel'] or 'pas de site officiel vérifié'}"
                      for u in cites[:5]]
            return {
                'reponse': "Ma réponse précédente citait plusieurs établissements, voici leurs sites :\n"
                           + '\n'.join(lignes),
                'sources': [{'titre': u['nom'], 'url': u['site_web_officiel']} for u in cites[:5]],
            }
    u = etablissements_chat.etablissement_de_la_question(question, historique)
    if u is None:
        return None
    fiche = f"/universities/{u['id']}"
    if u['site_web_officiel']:
        return {
            'reponse': f"Le site officiel de « {u['nom']} » est : {u['site_web_officiel']} [1]",
            'sources': [{'titre': u['nom'], 'url': u['site_web_officiel']}],
        }
    return {
        'reponse': (f"Je n'ai pas de site officiel vérifié pour « {u['nom']} ». Sa fiche dans "
                    "l'application (rubrique Universités) donne ses coordonnées et sa présentation."),
        'sources': [{'titre': u['nom'], 'url': None, 'lien_fiche': fiche}],
    }


# --- Questions factuelles sur un établissement : réponse VÉRIFIÉE ou contacts ------------
# Frais, inscription, concours, dates… : une erreur a des conséquences pour l'élève. Le
# chatbot ne répond qu'avec une information sourcée (fiche de l'établissement ou son site
# officiel) ; sinon il le dit et donne les contacts de l'établissement (constaté le
# 21/10/2026 : « Frais d'inscription à l'UGB ? » renvoyait un article sur le privé et les
# frais de l'UASZ, tirés de fiches de démonstration).
SUJETS_SENSIBLES = {
    'frais': ('frais', 'tarif', 'tarifs', 'prix', 'cout', 'couts', 'payer', 'paiement', 'mensualite', 'scolarite'),
    'inscription': ('inscription', 'inscriptions', 'inscrire', 'preinscription', 'candidature', 'candidater', 'postuler'),
    'admission': ('admission', 'admissions', 'conditions', 'condition', 'acces', 'selection', 'niveau', 'requis'),
    'concours': ('concours', 'examen', 'test', 'entretien'),
    'dates': ('date', 'dates', 'calendrier', 'delai', 'limite', 'rentree', 'quand'),
    'pieces': ('pieces', 'dossier', 'documents', 'papiers'),
    'contact': ('contact', 'contacter', 'telephone', 'numero', 'email', 'mail', 'adresse', 'joindre', 'situe'),
}
LIBELLES_SUJETS = {
    'frais': "frais d'inscription et de scolarité", 'inscription': 'inscriptions', 'admission': "conditions d'admission",
    'concours': 'concours et sélections', 'dates': 'dates et calendrier', 'pieces': 'pièces du dossier',
    'contact': 'coordonnées',
}


def _sujet_sensible(question):
    mots = set(cache.normaliser_texte(question).split())
    for sujet, cles in SUJETS_SENSIBLES.items():
        if mots & set(cles):
            return sujet
    return None


def _coordonnees(u):
    """Contacts connus de l'établissement (seulement ceux renseignés dans sa fiche)."""
    from veille.models import Universite as Etab

    fiche = Etab.objects.filter(id=u['id']).values(
        'telephone_contact', 'email_contact', 'adresse', 'commune', 'region').first() or {}
    lignes = []
    if u.get('site_web_officiel'):
        lignes.append(f"🌐 Site officiel : {u['site_web_officiel']}")
    if fiche.get('telephone_contact'):
        lignes.append(f"📞 Téléphone : {fiche['telephone_contact']}")
    if fiche.get('email_contact'):
        lignes.append(f"✉️ E-mail : {fiche['email_contact']}")
    lieu = fiche.get('adresse') or ', '.join(dict.fromkeys(filter(None, [fiche.get('commune'), fiche.get('region')])))
    if lieu:
        lignes.append(f'📍 Adresse : {lieu}')
    return lignes


def _renvoi_vers_l_etablissement(u, sujet):
    """Pas d'information vérifiée : on le dit et on donne les moyens d'obtenir la réponse."""
    lignes = _coordonnees(u)
    texte_contacts = ('\n' + '\n'.join(lignes)) if lignes else (
        "\nSes coordonnées ne sont pas encore dans nos fiches : consulte Campusen (https://campusen.sn) "
        'ou le site du ministère (https://mesrisenegal.sn).')
    return {
        'reponse': (f"Je n'ai pas d'information vérifiée sur les {LIBELLES_SUJETS[sujet]} de « {u['nom']} ». "
                    f"Pour une réponse fiable, renseigne-toi directement auprès de l'établissement :{texte_contacts}\n"
                    "Tu trouveras aussi sa fiche dans l'application (rubrique Universités)."),
        'sources': [{'titre': u['nom'], 'url': u.get('site_web_officiel')}],
    }


def _renvoi_general(u):
    """Question sur un établissement sans réponse vérifiée (hors sujets listés ci-dessus)."""
    lignes = _coordonnees(u)
    return {
        'reponse': (f"Je n'ai pas trouvé d'information vérifiée pour répondre à ta question sur « {u['nom']} ». "
                    + ("Pour une réponse fiable, contacte directement l'établissement :\n" + '\n'.join(lignes)
                       if lignes else "Consulte sa fiche dans l'application (rubrique Universités) ou Campusen "
                                      '(https://campusen.sn).')),
        'sources': [{'titre': u['nom'], 'url': u.get('site_web_officiel')}],
    }


def _question_factuelle(question, historique, echeance, avertissements):
    """Réponse vérifiée (fiche ou site officiel) ou renvoi vers l'établissement. None si la
    question ne porte pas sur un sujet sensible d'un établissement identifié."""
    sujet = _sujet_sensible(question)
    if not sujet:
        return None
    u = etablissements_chat.etablissement_de_la_question(question, historique)
    if u is None:
        return None
    from recommandations.models import Formation
    from veille.models import Universite as Etab

    # Une formation de cet établissement, citée dans la question, a ses conditions en base
    # (saisies par un administrateur) : la recherche normale répond avec elles.
    if sujet in ('admission', 'concours', 'pieces', 'inscription'):
        mots_question = {m for m in cache.normaliser_texte(question).split() if len(m) >= 5}
        for f in Formation.objects.filter(universite_id=u['id'], deleted_at__isnull=True):
            documentee = f.series_acceptees or f.moyenne_minimale is not None or f.prerequis
            if documentee and mots_question & {m for m in cache.normaliser_texte(f.intitule).split() if len(m) >= 5}:
                return None

    fiche = Etab.objects.filter(id=u['id']).values(
        'admission', 'niveau_requis', 'pieces_a_fournir', 'source_infos').first() or {}
    source_fiche = [{'titre': u['nom'], 'url': fiche.get('source_infos') or u.get('site_web_officiel')}]
    if sujet == 'contact':
        lignes = _coordonnees(u)
        if lignes:
            return {'reponse': f"Coordonnées de « {u['nom']} » :\n" + '\n'.join(lignes), 'sources': source_fiche}
        return _renvoi_vers_l_etablissement(u, sujet)
    # Informations d'admission relevées sur un annuaire sourcé (lien affiché).
    if sujet in ('admission', 'inscription', 'pieces') and (fiche.get('admission') or fiche.get('niveau_requis')
                                                             or fiche.get('pieces_a_fournir')):
        parties = []
        if fiche.get('admission') and sujet != 'pieces':
            parties.append(fiche['admission'])
        if fiche.get('niveau_requis') and sujet != 'pieces':
            parties.append('Niveau requis : ' + ' ; '.join(fiche['niveau_requis']))
        if fiche.get('pieces_a_fournir') and sujet in ('pieces', 'inscription'):
            parties.append('Pièces à fournir : ' + ', '.join(fiche['pieces_a_fournir']))
        if parties:
            contacts = _coordonnees(u)
            return {'reponse': f"Pour « {u['nom']} », d'après sa fiche :\n" + '\n'.join(parties)
                    + ('\n\nÀ confirmer auprès de l\'établissement :\n' + '\n'.join(contacts) if contacts else ''),
                    'sources': source_fiche}
    # Sinon : seulement le SITE OFFICIEL de l'établissement, jamais une page qui parle d'un autre.
    site = u.get('site_web_officiel')
    if site and echeance - time.monotonic() > TEMPS_MIN_LLM_SECONDES:
        domaine = re.sub(r'^https?://(www\.)?', '', site).split('/')[0]
        try:
            resultats = tavily_service.rechercher(
                f"{u['nom']} {LIBELLES_SUJETS[sujet]}", module='chat', include_domains=[domaine], max_results=4,
                timeout=min(settings.TAVILY_TIMEOUT_SECONDES, int(echeance - time.monotonic() - 2)))
        except tavily_service.TavilyIndisponibleError:
            avertissements.append('recherche_web_indisponible')
            resultats = []
        mots_sujet = set(SUJETS_SENSIBLES[sujet])
        extraits = []
        for r in resultats:
            phrases = [p for p in re.split(r'(?<=[.!?])\s+', r['contenu'] or '')
                       if set(cache.normaliser_texte(p).split()) & mots_sujet and 30 <= len(p) <= 400]
            if phrases:
                extraits.append((r, ' '.join(phrases[:2])))
        if extraits:
            # Chaque extrait est rattaché à SA page : observé le 29/10/2026, les frais de la page
            # « Certificat de Capacité en Droit » de l'UGB étaient présentés comme LES frais de l'UGB.
            lignes, formations = [], []
            for i, (r, e) in enumerate(extraits[:2], start=1):
                page = re.split(r'\s+[|–-]\s+', r.get('titre') or '')[0].strip()
                page_generale = (not page or etablissements_chat.trouver(page) is not None
                                 and len(page) <= len(u['nom']) + 10)
                if not page_generale:
                    formations.append(page)
                lignes.append(f"• {'Page « ' + page + ' » : ' if not page_generale else ''}{e} [{i}]")
            precision = (
                f"\n\nAttention : ces chiffres concernent {'la formation' if len(formations) == 1 else 'les formations'} "
                + ', '.join(f'« {f} »' for f in formations)
                + ". Ils changent selon la formation : pour celle qui t'intéresse, vérifie sa page "
                  "sur le site officiel ou contacte le service de scolarité."
                if formations and sujet == 'frais' else ''
            )
            return {'reponse': f"D'après le site officiel de « {u['nom']} » :\n" + '\n'.join(lignes)
                    + (precision or "\n\nVérifie ces informations sur le site avant toute démarche."),
                    'sources': [{'titre': r['titre'] or u['nom'], 'url': r['url']} for r, _ in extraits[:2]]}
    return _renvoi_vers_l_etablissement(u, sujet)


# --- « Où étudier l'informatique ? », « Quelles écoles de journalisme ? » ----------------
# Avant : recherche par mots, qui ramenait les premières lignes trouvées (souvent les mêmes
# grandes universités, une offre de stage, une page Campus France…). Maintenant : le domaine
# demandé (thésaurus recommandations/domaines.py) est cherché dans TOUT le catalogue
# (formations détaillées + domaines affichés sur les fiches de 160 établissements), avec la
# ville et le statut public / privé s'ils sont précisés, un établissement par ligne.
_MOTS_INTENTION_ETUDES = {
    'etudier', 'etudes', 'ecole', 'ecoles', 'institut', 'instituts', 'universite', 'universites', 'formation',
    'formations', 'faire', 'apprendre', 'devenir', 'suivre', 'filiere', 'filieres', 'metier', 'licence', 'bts',
    'master', 'centre', 'centres', 'etablissement', 'etablissements', 'specialiser', 'option', 'cursus'}
# Au-delà, une seule formation par ligne pour que la liste complète reste lisible.
NB_ETABLISSEMENTS_DETAILLES = 25


def _etablissements_pour_un_domaine(question):
    """Établissements qui enseignent le domaine demandé. None si la question n'est pas de ce type."""
    from recommandations import domaines as thesaurus
    from recommandations import scoring
    from recommandations.models import Formation

    from veille import lieux

    mots = set(cache.normaliser_texte(question).split())
    demandes = thesaurus.domaines_du_texte(question)
    if not demandes or not mots & _MOTS_INTENTION_ETUDES or etablissements_chat.trouver(question):
        return None
    statut = 'prive' if mots & {'prive', 'privee', 'prives', 'privees'} else (
        'public' if mots & {'public', 'publique', 'publics', 'publiques', 'etat'} else None)
    # Ville / région citée (« à Saint-Louis », « à Thiès ») ; sans ville citée : tout le pays.
    ville, nom_ville = None, None
    t = f" {cache.normaliser_texte(question)} "
    for cle, (commune, region) in lieux.VILLES.items():
        if f' {cle} ' in t:
            ville, nom_ville = {commune.lower(), region.lower()}, commune
            break
    if ville is None and ' dakar ' in t:
        ville, nom_ville = {'dakar'}, 'Dakar'

    try:
        formations = list(Formation.objects.select_related('universite').filter(
            deleted_at__isnull=True, universite__statut_actif=True))
        candidats = formations + scoring._candidats_domaines(formations)
    except DatabaseError:
        return None
    racines = {m[:6] for m in mots if len(m) >= 5}
    par_etab = {}
    for c in candidats:
        texte_c = scoring._texte_formation(c)
        communs = thesaurus.domaines_du_texte(texte_c) & demandes
        if not communs:
            continue
        u = c.universite
        if statut and getattr(u, 'type', None) != statut:
            continue
        if ville and not ({(u.region or '').lower(), (u.commune or '').lower()} & ville):
            continue
        mots_c = cache.normaliser_texte(texte_c).split()
        score = 2 * len(communs) + (1 if any(m.startswith(r) for r in racines for m in mots_c) else 0) \
            + (0.5 if not getattr(c, 'est_domaine', False) else 0)
        entree = par_etab.setdefault(u.id, {'u': u, 'score': 0, 'intitules': []})
        entree['score'] = max(entree['score'], score)
        if c.intitule not in entree['intitules']:
            entree['intitules'].append(c.intitule)
    if not par_etab:
        return None
    # TOUS les établissements du domaine (pas seulement les premiers), regroupés par ville :
    # Dakar d'abord (le plus grand nombre), puis les autres villes par ordre alphabétique.
    tous = sorted(par_etab.values(), key=lambda e: (-e['score'], e['u'].nom))
    groupes = {}
    for e in tous:
        groupes.setdefault(e['u'].region or 'Autres', []).append(e)
    ordre = sorted(groupes, key=lambda r: (r != 'Dakar', r == 'Autres', r))
    nb_programmes = 1 if len(tous) > NB_ETABLISSEMENTS_DETAILLES else 2

    libelle = ', '.join(sorted(thesaurus.libelle(d).lower() for d in demandes))
    precisions = ' '.join(filter(None, [{'prive': 'privés', 'public': 'publics'}.get(statut),
                                        f'à {nom_ville}' if nom_ville else None]))
    blocs = []
    for region in ordre:
        lignes = []
        for e in groupes[region]:
            u = e['u']
            quartier = u.commune if u.commune and u.commune != region else None
            lignes.append(f"• {u.nom}" + (f" ({quartier})" if quartier else '') + ' : '
                          + ', '.join(e['intitules'][:nb_programmes]))
        blocs.append(f"📍 {region} ({len(groupes[region])}) :\n" + '\n'.join(lignes))
    return {
        'reponse': (f"Pour étudier en {libelle}, voici les {len(tous)} établissements "
                    f"{precisions + ' ' if precisions else ''}qui proposent ce domaine d'après nos fiches :\n\n"
                    + '\n\n'.join(blocs)
                    + "\n\nOuvre leur fiche (onglet Universités) pour les conditions d'admission et les contacts."),
        'sources': [{'titre': e['u'].nom, 'url': getattr(e['u'], 'site_web_officiel', None) or None}
                    for e in tous[:NB_SOURCES_MAX]],
    }


# --- « Quelles formations à l'UCAD ? » / « … dans cette université ? » -----------------
# Question de LISTE (« quelles formations… », « que propose… »), pas de détail sur une formation.
_MOTS_FORMATIONS_ETAB = {'formations', 'filieres', 'licences', 'masters', 'programmes', 'propose',
                         'proposent', 'proposees', 'enseigne', 'enseignent', 'diplomes'}
# « Quelles sont les CONDITIONS pour la licence informatique à l'UCAD ? » : un détail, pas la liste.
_MOTS_DETAIL = {'conditions', 'condition', 'moyenne', 'frais', 'prix', 'cout', 'admission', 'inscription',
                'inscriptions', 'date', 'dates', 'duree', 'debouches', 'bourse', 'bourses', 'concours', 'dossier'}
NB_FORMATIONS_ETAB = 8


def _formations_d_un_etablissement(question, historique):
    """Liste les formations d'UN établissement depuis la base (cité dans la question ou,
    pour « cette université », dans la conversation). None si ce n'est pas la question."""
    mots = set(cache.normaliser_texte(question).split())
    if (not mots & _MOTS_FORMATIONS_ETAB or mots & _MOTS_DETAIL
            or _SERIE_SEULE.search(question) or _MOYENNE.search(question)):
        return None
    u = etablissements_chat.etablissement_de_la_question(question, historique)
    if u is None:
        return None
    from recommandations.models import Formation
    from veille.models import Universite as Etab

    try:
        formations = list(Formation.objects.filter(universite_id=u['id'], deleted_at__isnull=True)
                          .order_by('niveau', 'intitule')[:NB_FORMATIONS_ETAB + 1])
        fiche = Etab.objects.filter(id=u['id']).values('domaines', 'diplomes').first() or {}
    except DatabaseError:
        return None
    source = [{'titre': u['nom'], 'url': u['site_web_officiel'] or None}]
    if formations:
        lignes = [f"• {f.intitule}" + (f" ({f.niveau})" if f.niveau and f.niveau.lower() not in f.intitule.lower()
                                      else '') for f in formations[:NB_FORMATIONS_ETAB]]
        suite = ("\n… et d'autres : la liste complète est sur sa fiche (rubrique Universités)."
                 if len(formations) > NB_FORMATIONS_ETAB else '')
        return {'reponse': f"Formations de « {u['nom']} » d'après nos fiches :\n" + '\n'.join(lignes) + suite,
                'sources': source}
    if fiche.get('domaines') or fiche.get('diplomes'):
        parties = []
        if fiche.get('domaines'):
            parties.append('Domaines : ' + ', '.join(fiche['domaines']))
        if fiche.get('diplomes'):
            parties.append('Diplômes préparés : ' + ', '.join(fiche['diplomes']))
        return {'reponse': f"Pour « {u['nom']} », nos fiches indiquent :\n" + '\n'.join(parties)
                + ("\nDétail des programmes : " + u['site_web_officiel'] if u['site_web_officiel'] else ''),
                'sources': source}
    return None  # rien en base : la recherche complète (web) prend le relais


# --- « Quelles filières avec un bac S2 et 13 de moyenne ? » ----------------------------
_SERIE = re.compile(r"\b(?:bac|serie|terminale|en)\s*(S[1-5]|L1|L2|L'?|G|T[1-2]?|STEG|STIDD|ES|STI2D|STG)\b",
                    re.IGNORECASE)
_SERIE_SEULE = re.compile(r"\b(S[1-5]|L1|L2)\b")
_MOYENNE = re.compile(r"(\d{1,2}(?:[.,]\d{1,2})?)\s*(?:/\s*20|sur\s*20|de\s+moy(?:enne)?)|"
                      r"moyenne\s+(?:de\s+|générale\s+de\s+)?(\d{1,2}(?:[.,]\d{1,2})?)", re.IGNORECASE)
_MOTS_FILIERES = {'filiere', 'filieres', 'formation', 'formations', 'etudier', 'etudes', 'orientation',
                  'choisir', 'faire', 'quoi', 'metier', 'metiers', 'licence', 'universite', 'universites'}
NB_FORMATIONS_BAC = 6


def _formations_pour_bac(question, profil):
    """Formations accessibles avec la série / la moyenne données dans la question (complétées
    par le profil de l'élève pour le classement). None si la question n'est pas de ce type."""
    mots = set(cache.normaliser_texte(question).split())
    m_serie = _SERIE.search(question) or _SERIE_SEULE.search(question)
    m_moy = _MOYENNE.search(question)
    if not (mots & _MOTS_FILIERES) or not (m_serie or m_moy):
        return None
    serie = m_serie.group(1).upper().rstrip("'") if m_serie else (profil or {}).get('serie_bac')
    moyenne = None
    if m_moy:
        valeur = float((m_moy.group(1) or m_moy.group(2)).replace(',', '.'))
        moyenne = valeur if 0 <= valeur <= 20 else None

    from recommandations import scoring
    from recommandations.models import Formation
    from .embeddings import _model as modele_charge

    profil = profil or {}
    profil_question = {
        'serie_bac': serie, 'moyenne_generale': moyenne if moyenne is not None else profil.get('moyenne_generale'),
        'passions': profil.get('passions') or [], 'metiers_envisages': profil.get('metiers_envisages') or [],
        'matieres_fortes': profil.get('matieres_fortes') or [], 'region_cible': profil.get('region_cible'),
        'mobilite': True,
    }
    try:
        formations = [
            f for f in Formation.objects.select_related('universite').filter(
                deleted_at__isnull=True, universite__statut_actif=True)
            if scoring._est_compatible_serie(f, serie) and scoring._est_compatible_moyenne(f, profil_question['moyenne_generale'])
            # Un bachelier entre en BTS ou en licence : un master ou un doctorat exige déjà un diplôme.
            and (f.niveau or '').lower() in ('bts', 'licence')
        ]
    except DatabaseError:
        return None
    if not formations:
        return None
    # Conditions CONFIRMÉES par la fiche (série acceptée et/ou moyenne minimale atteinte) d'abord.
    confirmees = [f for f in formations if (serie and f.series_acceptees and serie in f.series_acceptees)
                  or f.moyenne_minimale is not None]
    autres = [f for f in formations if f not in confirmees]
    # Le reste est classé selon le profil (passions, métiers) si le modèle est déjà en mémoire :
    # le charger maintenant (~45 s) dépasserait le délai du chat.
    if modele_charge is not None and (profil_question['passions'] or profil_question['metiers_envisages']):
        classees = [r['formation'] for r in scoring.generer_recommandations(profil_question, limite=50)]
        autres = [f for f in classees if f in autres] + [f for f in autres if f not in classees]
    choix, vus = [], set()
    for f in confirmees + autres:
        if f.universite_id in vus and len(choix) < NB_FORMATIONS_BAC - 2:
            continue  # variété : une formation par établissement d'abord
        vus.add(f.universite_id)
        choix.append(f)
        if len(choix) == NB_FORMATIONS_BAC:
            break

    conditions = ' et '.join(filter(None, [f'un bac {serie}' if serie else None,
                                           f'{moyenne:g}/20 de moyenne' if moyenne is not None else None]))
    lignes = []
    for f in choix:
        lieu = f.universite.commune or f.universite.region
        detail = []
        if serie and f.series_acceptees and serie in f.series_acceptees:
            detail.append(f'série {serie} acceptée')
        if f.moyenne_minimale is not None:
            detail.append(f'moyenne demandée : {float(f.moyenne_minimale):g}/20')
        lignes.append(f"• {f.intitule} — {f.universite.nom}" + (f" ({lieu})" if lieu else '')
                      + (f" : {', '.join(detail)}" if detail else ''))
    # « accessibles » seulement si la fiche CONFIRME série ou moyenne ; sinon on ne l'affirme pas.
    nb_confirmees = sum(1 for f in choix if f in confirmees)
    entete = (f"Avec {conditions}, voici des formations accessibles d'après nos fiches :" if nb_confirmees == len(choix)
              else f"Avec {conditions}, voici des formations qui peuvent te correspondre (la série et la moyenne "
                   "exigées ne sont pas toujours indiquées dans nos fiches) :")
    reponse = (entete + '\n' + '\n'.join(lignes)
               + "\n\nLes conditions exactes (série, moyenne, concours) sont à confirmer auprès de chaque "
                 "établissement. Pour des suggestions selon tes passions, complète ton profil et ouvre "
                 "la page Orientation.")
    sources = [{'titre': f.universite.nom, 'url': f.universite.site_web_officiel or None} for f in choix]
    return {'reponse': reponse, 'sources': list({s['titre']: s for s in sources}.values())}


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

    # Gemini (ia/agent.py) traite tout ce qui demande de comprendre : questions, remarques,
    # demandes de reformulation, hors sujet. Les formules simples (salut, merci, au revoir) et
    # « est-ce fiable ? » gardent leur réponse instantanée par règles.
    via_agent = intention in (intentions.QUESTION, intentions.PAS_COMPRIS, intentions.AVIS, intentions.HORS_SUJET)
    cle_agent = cache.cle('chat:agent', message) if via_agent and not historique else None
    reponse_agent = None
    if via_agent:
        reponse_agent = cache.lire(cle_agent) if cle_agent else None
        if reponse_agent:
            resultat.update(reponse_agent, depuis_cache=True)
        else:
            reponse_agent = agent.repondre(message, profil, historique, min(echeance, debut + settings.GEMINI_DELAI_SECONDES))
            if reponse_agent:
                resultat.update(reponse_agent)
                if cle_agent:
                    cache.ecrire(cle_agent, {k: reponse_agent[k] for k in ('reponse', 'sources', 'recherche_web')},
                                 settings.CACHE_REPONSE_TTL_HEURES * 3600)
            else:
                # Gemini indisponible ou réponse refusée : le chatbot local répond, avec son propre délai.
                echeance = max(echeance, time.monotonic() + 8)

    if reponse_agent:
        pass
    elif intention == intentions.FIABILITE:
        resultat.update(_fiabilite_reponse_precedente(historique))
    elif intention != intentions.QUESTION:
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


def _fiabilite_reponse_precedente(historique):
    """« Est-ce que cette info est fiable ? » : d'où vient la réponse précédente, et à quel
    point on peut s'y fier (site officiel de l'établissement, site public, presse…)."""
    from veille import fiabilite
    from veille.models import Universite

    precedente = next((t for t in reversed(historique or []) if t.get('role') == 'assistant'), None)
    if precedente is None:
        return {'reponse': "De quelle information parles-tu ? Pose-moi d'abord ta question, puis je "
                           "t'indiquerai d'où vient la réponse.", 'sources': []}
    sources = [s for s in precedente.get('sources') or [] if isinstance(s, dict) and s.get('url')]
    if not sources:
        return {'reponse': "Ma réponse précédente ne s'appuyait sur aucune source vérifiable. Ne la "
                           "considère pas comme sûre : vérifie sur le site officiel de l'établissement "
                           "ou auprès de son service de scolarité.", 'sources': []}
    try:
        sites_etablissements = {
            fiabilite.domaine(u) for u in Universite.objects.exclude(site_web_officiel__isnull=True)
            .exclude(site_web_officiel='').values_list('site_web_officiel', flat=True)
        }
    except DatabaseError:
        sites_etablissements = set()
    lignes, toutes_officielles = [], True
    for s in sources[:5]:
        hote = fiabilite.domaine(s['url'])
        niveau = fiabilite.niveau_fiabilite(s['url'])
        if hote in sites_etablissements or any(hote.endswith('.' + d) for d in sites_etablissements):
            nature = "site officiel de l'établissement"
        elif niveau == fiabilite.OFFICIEL:
            nature = 'site officiel (État, ministère ou organisme public)'
        elif niveau == fiabilite.PRESSE:
            nature = 'presse reconnue'
            toutes_officielles = False
        else:
            nature = 'source non officielle'
            toutes_officielles = False
        lignes.append(f"• {s.get('titre') or hote} — {nature} : {s['url']}")
    conclusion = (
        "Ces informations viennent de sources officielles : elles sont fiables à la date où elles ont "
        "été publiées. Les montants et dates peuvent changer d'une année à l'autre : confirme-les sur "
        "le site avant toute démarche."
        if toutes_officielles else
        "Une partie vient de sources non officielles : vérifie-la sur le site officiel de "
        "l'établissement ou auprès de son service de scolarité avant toute démarche."
    )
    return {'reponse': "Ma réponse précédente vient de :\n" + '\n'.join(lignes) + '\n\n' + conclusion,
            'sources': sources[:5]}


def _repondre_question(message, profil, historique, echeance):
    site = _site_demande(message, historique)
    if site:
        return {**site, 'recherche_web': False, 'avertissements': []}
    # « Quelles filières avec un bac S2 et 13 ? » : formations de la base filtrées par série et
    # moyenne, au lieu d'un extrait de texte pris au hasard par la recherche par mots.
    par_bac = _formations_pour_bac(message, profil)
    if par_bac:
        return {**par_bac, 'recherche_web': False, 'avertissements': []}
    # « Quelles formations à l'UCAD / dans cette université ? » : la liste de la base.
    par_etab = _formations_d_un_etablissement(message, historique)
    if par_etab:
        return {**par_etab, 'recherche_web': False, 'avertissements': []}
    # « Où étudier l'informatique ? », « écoles de journalisme à Dakar » : tout le catalogue,
    # par domaine, avec la ville et le statut demandés.
    par_domaine = _etablissements_pour_un_domaine(message)
    if par_domaine:
        return {**par_domaine, 'recherche_web': False, 'avertissements': []}
    # Frais, inscription, concours, dates, contacts d'un établissement : vérifié ou contacts.
    avertissements_factuels = []
    factuelle = _question_factuelle(message, historique, echeance, avertissements_factuels)
    if factuelle:
        return {**factuelle, 'recherche_web': bool(factuelle['sources'] and factuelle['sources'][0].get('url')
                                                   and 'officiel' in factuelle['reponse']),
                'avertissements': avertissements_factuels}
    # Questions de tous les jours (actualités, offres, établissements d'une ville) : réponse
    # exacte et immédiate depuis la base, sans attendre le modèle (voir ia/reponses_base.py).
    instantanee = reponses_base.repondre(message)
    if instantanee:
        return {**instantanee, 'recherche_web': False, 'avertissements': []}
    avertissements = []
    # Question de suivi (« quelles formations dans CETTE université ? ») : la recherche porte
    # sur l'établissement cité plus tôt dans la conversation.
    recherche = message
    if etablissements_chat.trouver(message) is None and etablissements_chat.renvoie_a_un_etablissement(message):
        precedent = etablissements_chat.depuis_historique(historique)
        if precedent:
            recherche = f"{message} {precedent['nom']}"
    liens = liens_officiels(recherche)
    documents = chercher_dans_la_base(recherche)
    recherche_web = False
    if not _base_suffisante(documents, _mots_importants(recherche)):
        documents_web = _chercher_sur_le_web(recherche, historique, echeance, avertissements)
        recherche_web = bool(documents_web)
        # La base ne couvrait pas la question : les résultats web, plus pertinents, d'abord.
        documents = (documents_web + documents)[:NB_SOURCES_MAX]

    # Question sur UN établissement : on écarte tout document qui ne parle pas de lui (avant,
    # une question sur l'UGB pouvait être « répondue » avec un texte sur l'UASZ).
    cible = etablissements_chat.etablissement_de_la_question(recherche, historique)
    if cible:
        gardes = [d for d in documents
                  if (etablissements_chat.trouver(f"{d.get('titre', '')} {d.get('texte', '')}") or {}).get('id') == cible['id']]
        if not gardes and documents:
            avertissements.append('sources_hors_etablissement_ecartees')
            return {**_renvoi_general(cible), 'recherche_web': recherche_web, 'avertissements': avertissements}
        documents = gardes

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
