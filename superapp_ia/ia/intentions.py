"""
Détection rapide de l'intention d'un message, par règles (module 4, chatbot).

Une salutation, un remerciement ou un message hors sujet reçoit une réponse
immédiate, rédigée à l'avance : ni recherche web, ni LLM. C'est instantané, gratuit
en crédits Tavily, et libère le CPU pour les vraies questions.

Les règles sont volontairement prudentes : dans le doute, le message est traité
comme une QUESTION (le pire cas est alors une réponse un peu plus lente, jamais une
vraie question ignorée).
"""
import random
import re

from services.cache import normaliser_texte

SALUTATION = 'salutation'
REMERCIEMENT = 'remerciement'
AU_REVOIR = 'au_revoir'
HORS_SUJET = 'hors_sujet'
AIDE = 'aide'
PAS_COMPRIS = 'pas_compris'
QUESTION = 'question'

# Formules complètes, après normalisation (minuscules, sans accents ni ponctuation).
_SALUTATIONS = {
    'salut', 'bonjour', 'bonsoir', 'hello', 'hi', 'coucou', 'hey', 'yo', 'slt', 'bjr', 'cc',
    'salam', 'salamalekum', 'salamaleikoum', 'assalamou alaykoum', 'assalamu alaykum',
    'nanga def', 'na nga def', 'nangadef', 'naka nga def', 'mbaa mangi fi', 'ca va', 'cv',
    'comment ca va', 'comment vas tu', 'tu vas bien',
}
_REMERCIEMENTS = {
    'merci', 'merci beaucoup', 'merci bien', 'jerejef', 'jere jef', 'jerejeff', 'thanks',
    'thank you', 'super merci', 'ok merci', 'merci infiniment', 'top merci', 'parfait merci',
}
_AU_REVOIR = {
    'au revoir', 'bye', 'a plus', 'a bientot', 'bonne nuit', 'a demain', 'ciao',
    'ba beneen yoon', 'mangi dem',
}
# L'élève n'a pas compris la réponse précédente : on l'aide à reformuler.
_PAS_COMPRIS = {
    'pas compris', 'j ai pas compris', 'je n ai pas compris', 'jai pas compris', 'pas clair',
    'je comprends pas', 'je ne comprends pas', 'je comprend pas', 'comprends pas', 'hein',
    'quoi', 'comment ca', 'c est a dire', 'explique', 'explique moi', 'reexplique',
    'tu peux reformuler', 'reformule',
}
# Mots qui peuvent suivre un « merci » sans en faire une question (« merci c'est gentil »).
_COMPLIMENTS = {
    'c', 'est', 'gentil', 'gentille', 'gentile', 'sympa', 'cool', 'top', 'super', 'parfait',
    'genial', 'nickel', 'ok', 'd', 'accord', 'daccord', 'tres', 'trop', 'vraiment', 'pour', 'ta',
    'reponse', 'aide', 'ton', 'l', 'info', 'infos', 'information', 'informations', 'beaucoup',
}

# Demandes d'aide générales, sans sujet précis (« aide moi », « tu fais quoi ? ») : on
# explique ce que l'assistant sait faire, au lieu de laisser le modèle improviser.
_AIDE = {
    'aide', 'aide moi', 'aidez moi', 'help', 'au secours', 'j ai besoin d aide', 'besoin d aide',
    'tu peux m aider', 'peux tu m aider', 'vous pouvez m aider', 'pouvez vous m aider',
    'que peux tu faire', 'tu fais quoi', 'tu sers a quoi', 'comment ca marche', 'je suis perdu',
    'je suis perdue', 'je ne sais pas quoi faire', 'conseille moi', 'oriente moi', 'dimbali ma',
}
# Mots de politesse qui peuvent accompagner une salutation (« salut l'ami », « bonjour à toi »).
_MOTS_ACCOMPAGNEMENT = {
    'a', 'toi', 'vous', 'tous', 'l', 'ami', 'mon', 'frere', 'soeur', 'assistant', 'ndimbeul',
    'bot', 'cher', 'chere', 'encore', 'et', 'yow', 'waaw', 'oui', 'beaucoup',
    'stp', 'svp', 's', 'il', 'te', 'plait', 'please', 'moi', 'bien', 'sur',
}

# Vocabulaire du périmètre de l'application : sa présence suffit à traiter le message
# comme une vraie question, même s'il contient aussi un mot « hors sujet ».
_MOTS_DU_PERIMETRE = {
    'bac', 'bfem', 'examen', 'etude', 'etudes', 'etudier', 'universite', 'ecole', 'institut',
    'aide', 'conseil', 'orienter',
    'isep', 'ucad', 'ugb', 'uadb', 'uasz', 'formation', 'filiere', 'licence', 'master', 'bts',
    'orientation', 'campusen', 'inscription', 'bourse', 'concours', 'stage', 'emploi', 'travail',
    'metier', 'carriere', 'cv', 'diplome', 'serie', 'moyenne', 'frais', 'logement', 'campus',
    'etudiant', 'lycee', 'eleve', 'cours', 'professeur', 'recrutement', 'candidature', 'alternance',
}
# Sujets clairement extérieurs à l'orientation et à l'emploi.
_MOTS_HORS_SUJET = {
    'foot', 'football', 'match', 'lutte', 'ballon', 'recette', 'cuisiner', 'thieb', 'yassa',
    'film', 'serie tv', 'netflix', 'musique', 'chanson', 'blague', 'meteo', 'horoscope',
    'politique', 'election', 'president', 'amour', 'copine', 'copain', 'jeu video', 'fifa',
}

_REPONSES = {
    SALUTATION: [
        "Salut ! Je suis l'assistant de Ndimbeul Étudiant. Je peux t'aider pour ton orientation "
        "après le bac, les formations, les bourses, les stages ou l'emploi. Que veux-tu savoir ?",
        "Bonjour ! Ravi de te lire. Pose-moi ta question sur les études, l'orientation, les "
        "bourses ou les offres de stage et d'emploi au Sénégal.",
    ],
    REMERCIEMENT: [
        "Avec plaisir ! N'hésite pas si tu as une autre question sur tes études ou ton orientation.",
        "De rien, c'est un plaisir de t'aider. Bonne continuation dans tes démarches !",
    ],
    AU_REVOIR: [
        "À bientôt ! Bon courage pour la suite de tes études.",
        "Au revoir, et bonne chance dans tes projets !",
    ],
    HORS_SUJET: [
        "Je suis spécialisé dans l'orientation, les études, les bourses, les stages et l'emploi "
        "au Sénégal, donc je ne peux pas bien t'aider sur ce sujet. Une question sur ton "
        "parcours, une formation ou une université ?",
    ],
    PAS_COMPRIS: [
        "Pas de souci, je reformule autrement si tu précises ta question avec quelques mots "
        "clés : l'établissement, la filière ou le sujet. Par exemple : « conditions d'admission "
        "licence informatique UCAD », « bourses master 2026 » ou « stage comptabilité Dakar ».",
    ],
    AIDE: [
        "Bien sûr ! Je peux t'aider à :\n"
        "• trouver une formation ou une université (« Quelles licences en informatique à Dakar ? ») ;\n"
        "• connaître les conditions d'admission (« Quelle moyenne pour la licence de droit à l'UCAD ? ») ;\n"
        "• suivre les bourses, concours, stages et emplois (« Y a-t-il des stages en comptabilité ? ») ;\n"
        "• te tenir au courant de l'actualité du bac, du BFEM et de Campusen.\n"
        "Pour des conseils personnalisés, ouvre aussi l'onglet Orientation. Pose-moi ta question !",
    ],
}

# Fautes de frappe fréquentes, ramenées à la formule correcte avant la comparaison.
_CORRECTIONS = {
    'bonjours': 'bonjour', 'bonjoue': 'bonjour', 'bjour': 'bonjour', 'bonjou': 'bonjour',
    'bonsoirs': 'bonsoir', 'saluts': 'salut', 'mercis': 'merci', 'merc': 'merci', 'mrc': 'merci',
    'mci': 'merci', 'cc': 'coucou', 'aidee': 'aide', 'aid': 'aide',
}


def _corriger(mot):
    """'saluuut' -> 'salut', 'bonjours' -> 'bonjour' : lettres répétées réduites (3 ou plus
    deviennent 1), puis fautes courantes de la table ci-dessus."""
    mot = re.sub(r'(.)\1{2,}', r'\1', mot)
    return _CORRECTIONS.get(mot, mot)
_REPONSE_NANGA_DEF = (
    "Maa ngi fi rekk, jërëjëf ! Je suis l'assistant de Ndimbeul Étudiant : orientation, "
    "formations, bourses, stages, emploi… Comment puis-je t'aider ?"
)


def _est_formule(mots, formules):
    """Vrai si le message EST une formule de la liste, éventuellement accompagnée de
    quelques mots de politesse (« merci beaucoup l'ami »), et rien d'autre."""
    texte = ' '.join(mots)
    for formule in formules:
        if texte == formule or texte.startswith(formule + ' '):
            reste = texte[len(formule):].split()
            if all(m in _MOTS_ACCOMPAGNEMENT or m in formules for m in reste):
                return True
    return False


def detecter(message):
    """Retourne l'intention du message : SALUTATION, REMERCIEMENT, AU_REVOIR, AIDE,
    HORS_SUJET ou QUESTION."""
    mots = [_corriger(m) for m in normaliser_texte(message).split()]
    if not mots:
        return QUESTION
    # « Bonjour, aide-moi » : la salutation d'ouverture ne change pas la demande.
    # (« Bonjour à toi » reste une salutation : le reste n'est que de la politesse.)
    if len(mots) > 1 and mots[0] in _SALUTATIONS and any(m not in _MOTS_ACCOMPAGNEMENT for m in mots[1:]):
        mots = mots[1:]

    # Les formules de politesse sont courtes : « bonjour, quelles sont les bourses ? »
    # est une QUESTION, pas une salutation.
    if len(mots) <= 7:
        for intention, formules in ((SALUTATION, _SALUTATIONS), (REMERCIEMENT, _REMERCIEMENTS),
                                    (AU_REVOIR, _AU_REVOIR), (AIDE, _AIDE), (PAS_COMPRIS, _PAS_COMPRIS)):
            if _est_formule(mots, formules):
                return intention
        # « Merci c'est gentil », « merci, top » : un merci suivi de simples compliments.
        if mots[0] == 'merci' and all(m in _COMPLIMENTS or m in _MOTS_ACCOMPAGNEMENT for m in mots[1:]):
            return REMERCIEMENT

    texte = ' '.join(mots)
    dans_le_perimetre = any(mot in _MOTS_DU_PERIMETRE for mot in mots)
    hors_sujet = any(f' {sujet} ' in f' {texte} ' for sujet in _MOTS_HORS_SUJET)
    if hors_sujet and not dans_le_perimetre:
        return HORS_SUJET
    return QUESTION


def reponse_rapide(intention, message):
    """Réponse rédigée à l'avance pour une intention qui ne demande pas de recherche."""
    if intention == SALUTATION and 'def' in normaliser_texte(message).split():
        return _REPONSE_NANGA_DEF
    return random.choice(_REPONSES[intention])
