"""Prompt système et assemblage du prompt final (PARTIE 6 du cahier des charges)."""
import re

from services.texte import extrait_pertinent

SYSTEM_PROMPT = """
Tu es l'assistant IA de Ndimbeul-Etudiant, un conseiller d'orientation
virtuel pour les lycéens et étudiants sénégalais. Réponds toujours en
français, de façon naturelle et logique selon ce que demande RÉELLEMENT le
message :
- Une salutation ou une phrase de politesse ("salut", "bonjour", "merci") ->
  réponds simplement dans le même registre, sans chercher à tout prix à
  parler d'orientation ou à réclamer un profil.
- Une question générale de culture générale ou de logique (qui ne dépend pas
  des données propres à l'app) -> réponds directement avec tes connaissances.
- Une question qui nécessite une information factuelle sur le Sénégal
  (établissement, filière, offre, bourse, frais, dates, adresse...) ->
  appuie-toi sur le CONTEXTE fourni (documents/établissements/offres) et,
  si utile, le PROFIL de l'étudiant (série du bac, moyenne, matières fortes,
  région, passions) pour personnaliser ta réponse. Si l'information n'est
  pas dans le CONTEXTE, dis-le clairement au lieu de l'inventer, et
  propose à l'étudiant de préciser sa question plutôt que d'improviser.
Présente toujours tes suggestions comme des recommandations, jamais comme
des décisions à la place de l'étudiant. Cite la source de chaque information
factuelle quand elle est disponible (nom de l'établissement/offre — les liens
cliquables sont ajoutés automatiquement par l'application à partir de tes
sources citées, pas besoin de les écrire toi-même).
RÉPONSE COURTE OBLIGATOIRE : maximum 3-4 phrases (le modèle tourne sur un
serveur local sans GPU, chaque mot coûte du temps de réponse). Va droit à
l'essentiel, pas de liste à puces ni de longue introduction ; propose de
détailler un point si l'étudiant le demande ensuite.
""".strip()

PROFIL_LABELS = {
    'serie_bac': 'Série du bac',
    'moyenne_generale': 'Moyenne générale',
    'matieres_fortes': 'Matières fortes',
    'mobilite': 'Mobilité géographique',
    'pref_public_prive': 'Préférence public/privé',
    'region_cible': 'Région ciblée',
    'passions': 'Passions',
    'metiers_envisages': 'Métiers envisagés',
}


def construire_contexte(documents):
    """documents: liste de {'titre', 'texte', 'score', ...} triée par pertinence décroissante."""
    if not documents:
        return "Aucun document pertinent n'a été trouvé dans la base de connaissances pour cette question."

    blocs = []
    for i, doc in enumerate(documents, start=1):
        blocs.append(f"[Source {i} - {doc.get('titre') or 'Document sans titre'}]\n{doc['texte']}")
    return '\n\n'.join(blocs)


def construire_profil(profil):
    if not profil:
        return "Aucun profil renseigné."

    lignes = []
    for cle, label in PROFIL_LABELS.items():
        valeur = profil.get(cle)
        if valeur in (None, '', []):
            continue
        if isinstance(valeur, list):
            valeur = ', '.join(str(v) for v in valeur)
        lignes.append(f'- {label} : {valeur}')

    return '\n'.join(lignes) if lignes else "Aucun profil renseigné."


def construire_messages(question, documents, profil, historique=None):
    """Assemble [SYSTEM_PROMPT] + [CONTEXTE] + [PROFIL] + [QUESTION] au format chat OpenAI/Ollama."""
    contenu_utilisateur = (
        f"CONTEXTE (documents universités) :\n{construire_contexte(documents)}\n\n"
        f"PROFIL DE L'ÉTUDIANT :\n{construire_profil(profil)}\n\n"
        f"QUESTION : {question}"
    )

    messages = [{'role': 'system', 'content': SYSTEM_PROMPT}]
    # Limité à 6 derniers messages (3 échanges) : garde le contexte pertinent tout en
    # bornant la taille du prompt, donc le temps de premier token, sur ce CPU sans GPU.
    for tour in (historique or [])[-6:]:
        role = tour.get('role')
        contenu = tour.get('contenu') or tour.get('content')
        if role in ('user', 'assistant') and contenu:
            messages.append({'role': role, 'content': contenu})
    messages.append({'role': 'user', 'content': contenu_utilisateur})
    return messages


SYSTEM_PROMPT_EXPLICATION_RECOMMANDATION = (
    "Tu es l'assistant IA de Ndimbeul-Etudiant. Rédige une explication courte (1 à 2 phrases, "
    "en français) de pourquoi cette formation est recommandée à cet étudiant, en te basant "
    "uniquement sur les éléments fournis (profil et score de correspondance). Reste factuel, "
    "bienveillant, et présente-la comme une suggestion, jamais comme une décision à sa place."
)


def construire_messages_explication_recommandation(formation, universite, profil, details):
    """PARTIE 8 : courte explication en langage naturel pour chaque formation recommandée."""
    contenu = (
        f"Formation : {formation.intitule} ({formation.niveau}) — domaine : {formation.domaine or 'non précisé'}\n"
        f"Université : {universite.nom} ({universite.region or 'région non précisée'}, {universite.type})\n"
        f"Profil étudiant : série {profil.get('serie_bac') or 'non renseignée'}, "
        f"passions : {', '.join(profil.get('passions') or []) or 'non renseignées'}, "
        f"métiers envisagés : {', '.join(profil.get('metiers_envisages') or []) or 'non renseignés'}\n"
        f"Détail du score de correspondance (/100) : {details}\n\n"
        'Rédige uniquement l\'explication (1-2 phrases maximum, sans préambule).'
    )
    return [
        {'role': 'system', 'content': SYSTEM_PROMPT_EXPLICATION_RECOMMANDATION},
        {'role': 'user', 'content': contenu},
    ]


SYSTEM_PROMPT_EXPLICATIONS_GROUPEES = (
    "Tu es l'assistant IA de Ndimbeul-Etudiant. On te donne une liste numérotée de formations "
    "recommandées à un étudiant. Pour CHAQUE formation, rédige une explication courte (1 phrase, "
    "en français) de pourquoi elle lui est recommandée, en te basant uniquement sur les éléments "
    "fournis. Réponds avec EXACTEMENT une ligne par formation, au format strict :\n"
    "1. <explication>\n2. <explication>\n...\n"
    "Rien d'autre : pas de préambule, pas de conclusion, pas de texte en dehors de cette liste "
    "numérotée. Reste factuel, bienveillant, et présente chaque explication comme une suggestion, "
    "jamais comme une décision à la place de l'étudiant."
)


def construire_messages_explications_groupees(resultats, profil):
    """PARTIE 8 : une explication par formation, en UN SEUL appel LLM (au lieu d'un par
    formation) — sur un LLM local CPU, dix appels séquentiels prennent plusieurs minutes,
    un seul appel groupé reste de l'ordre de la minute."""
    lignes_profil = construire_profil(profil)
    blocs_formations = []
    for i, resultat in enumerate(resultats, start=1):
        formation = resultat['formation']
        universite = formation.universite
        blocs_formations.append(
            f"{i}. {formation.intitule} ({formation.niveau}) — domaine : {formation.domaine or 'non précisé'} — "
            f"{universite.nom} ({universite.region or 'région non précisée'}, {universite.type}) — "
            f"score de correspondance : {resultat['score']}/100 {resultat['details']}"
        )

    contenu = (
        f"PROFIL DE L'ÉTUDIANT :\n{lignes_profil}\n\n"
        f"FORMATIONS RECOMMANDÉES ({len(resultats)}) :\n" + '\n'.join(blocs_formations) + '\n\n'
        f"Rédige les {len(resultats)} explications, une par ligne, numérotées de 1 à {len(resultats)}."
    )
    return [
        {'role': 'system', 'content': SYSTEM_PROMPT_EXPLICATIONS_GROUPEES},
        {'role': 'user', 'content': contenu},
    ]


def parser_explications_groupees(texte, nb_attendu):
    """Extrait les explications numérotées ('1. ...', '2. ...') d'une réponse LLM groupée.

    Retourne une liste de `nb_attendu` explications (None si une explication est introuvable
    pour un numéro donné, plutôt que de tout faire échouer sur un format légèrement différent).
    """
    explications = [None] * nb_attendu
    for ligne in (texte or '').splitlines():
        ligne = ligne.strip()
        match = re.match(r'^(\d+)[.\):]\s*(.+)$', ligne)
        if not match:
            continue
        numero = int(match.group(1))
        if 1 <= numero <= nb_attendu:
            explications[numero - 1] = match.group(2).strip()
    return explications


# --- Module 4 : chatbot avec sources numérotées (ia/chatbot.py) -----------------

# Volontairement bref : le modèle relit ce texte à chaque question (~25 tokens/s sur ce
# CPU). Chaque règle compte ; les contrôles de chatbot.py vérifient ensuite la réponse.
SYSTEM_PROMPT_CHAT_SOURCES = (
    "Assistant de Ndimbeul Étudiant (études, orientation, bourses, emploi au Sénégal). "
    "Réponds en français, en 2 phrases maximum, en tutoyant. "
    "Utilise SEULEMENT les SOURCES et cite [n] après chaque information. "
    "N'invente aucune date, chiffre ni nom. "
    "Si la réponse n'est pas dans les sources, dis-le et renvoie aux LIENS OFFICIELS."
)

# Sur ce CPU, le modèle LIT le prompt à ~25 tokens/s : chaque source est réduite à ses
# phrases utiles, l'historique est raccourci et les URL ne sont pas envoyées (l'app
# affiche elle-même les liens des sources).
LONGUEUR_MAX_SOURCE_CHAT = 170
LONGUEUR_MAX_MESSAGE_HISTORIQUE = 200


def construire_messages_chat(question, documents, liens_officiels, profil, historique, mots_cles=()):
    lignes = [
        f"[{i}] {doc.get('titre') or 'Source'} — "
        f"{extrait_pertinent(doc['texte'], mots_cles, LONGUEUR_MAX_SOURCE_CHAT)}"
        for i, doc in enumerate(documents, start=1)
    ]
    morceaux = ["SOURCES :\n" + ('\n'.join(lignes) if lignes else '(aucune source trouvée)')]
    morceaux.append(f"LIENS OFFICIELS : {', '.join(liens_officiels)}")
    if profil:
        morceaux.append(f"PROFIL DE L'ÉLÈVE :\n{construire_profil(profil)}")
    morceaux.append(f"QUESTION : {question}")

    messages = [{'role': 'system', 'content': SYSTEM_PROMPT_CHAT_SOURCES}]
    for tour in historique:
        role = tour.get('role')
        texte_tour = tour.get('contenu') or tour.get('content')
        if role in ('user', 'assistant') and texte_tour:
            messages.append({'role': role, 'content': texte_tour[:LONGUEUR_MAX_MESSAGE_HISTORIQUE]})
    contenu = '\n\n'.join(morceaux)
    messages.append({'role': 'user', 'content': contenu})
    return messages
