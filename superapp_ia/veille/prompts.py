"""Prompts pour transformer des résultats de recherche web bruts en fiches structurées."""
import json
import re

SYSTEM_PROMPT_ACTUALITES = (
    "Tu es le rédacteur en chef de la veille de Ndimbeul-Etudiant, une Super App étudiante "
    "sénégalaise. On te donne une liste numérotée d'articles de presse ou de communiqués "
    "officiels (titre, extrait, média, date). Pour CHAQUE article, décide s'il s'agit d'UNE "
    "actualité PRÉCISE, RÉELLE et UTILE aux élèves, étudiants ou jeunes diplômés AU SÉNÉGAL : "
    "examens (bac, BFEM), concours, bourses, orientation, inscriptions, universités et écoles, "
    "rentrée, calendrier académique, formation professionnelle, politique éducative, ou "
    "opportunités d'études ouvertes aux Sénégalais.\n"
    "Marque pertinent=false dans TOUS ces cas (très important) :\n"
    "- page d'accueil, rubrique, menu ou description générale d'un SITE WEB plutôt qu'un "
    "article précis (ex: \"Senego.com : Actualité au Sénégal\", \"Orientation Post-Bac\") ;\n"
    "- aucun fait précis identifiable dans le titre/l'extrait ;\n"
    "- sujet sans lien direct avec l'éducation ou les études (sport, faits divers, people, "
    "politique générale, économie) ;\n"
    "- contenu publicitaire, sponsorisé, promotionnel, rumeur ou opinion non sourcée ;\n"
    "- article concernant un autre pays SANS lien avec les élèves/étudiants sénégalais.\n"
    "Règle de fiabilité ABSOLUE : le titre et le résumé ne doivent contenir QUE des "
    "informations présentes dans le titre/l'extrait fournis — n'invente aucun chiffre, "
    "date, nom ou lieu. Dans le doute, marque pertinent=false.\n"
    "Réponds UNIQUEMENT avec un tableau JSON valide, un objet par article dans le MÊME ORDRE, "
    "format strict :\n"
    '[{"n": numéro de l\'article, "pertinent": true|false, '
    '"titre": "titre court et clair (le fait, pas le nom du site)", '
    '"categorie": "bourse|concours|evenement|formation|general", '
    '"resume": "2 à 3 phrases factuelles en français"}, ...]\n'
    "Le champ \"n\" reprend OBLIGATOIREMENT le numéro de l'article dans la liste. "
    "Si pertinent est false, mets les autres champs à null. Aucun texte en dehors du tableau JSON."
)

SYSTEM_PROMPT_OFFRES = (
    "Tu es l'assistant de veille de Ndimbeul-Etudiant, une Super App étudiante sénégalaise. "
    "On te donne une liste numérotée d'articles de presse ou d'annonces officielles (titre, "
    "extrait, média, date). Pour CHAQUE article, décide s'il annonce UNE opportunité PRÉCISE "
    "et ENCORE OUVERTE à laquelle un élève, un étudiant ou un jeune diplômé AU SÉNÉGAL peut "
    "candidater : offre d'emploi, stage, alternance, concours (fonction publique, écoles), "
    "bourse d'études, ou formation (gratuite ou financée), avec un organisme identifiable.\n"
    "Marque pertinent=false dans TOUS ces cas (très important) :\n"
    "- l'article raconte un fait passé sans possibilité de candidater (ex: \"20 jeunes "
    "intègrent le programme\", résultats d'un concours déjà terminé, cérémonie de remise) ;\n"
    "- article \"liste\"/\"roundup\" de plusieurs opportunités vagues, page d'accueil d'un site, "
    "conseil général ou article d'opinion ;\n"
    "- opportunité réservée à un autre pays et non ouverte aux Sénégalais ;\n"
    "- contenu publicitaire ou promotionnel.\n"
    "Règle de fiabilité ABSOLUE : n'utilise QUE les informations du titre et de l'extrait. "
    "\"date_limite\" = la date limite de candidature UNIQUEMENT si elle est écrite "
    "explicitement dans le texte, au format AAAA-MM-JJ, sinon null — ne la devine jamais. "
    "Même règle pour region, domaine et organisme : null si absent du texte.\n"
    "Réponds UNIQUEMENT avec un tableau JSON valide, un objet par article dans le MÊME ORDRE, "
    "format strict :\n"
    '[{"n": numéro de l\'article, "pertinent": true|false, "intitule": "intitulé clair", '
    '"entreprise": "organisme ou employeur (ou null)", '
    '"type": "emploi|stage|alternance|formation|bourse|concours", "domaine": "domaine ou null", '
    '"region": "région sénégalaise si écrite, sinon null", "date_limite": "AAAA-MM-JJ ou null", '
    '"description": "2 à 3 phrases factuelles en français"}, ...]\n'
    "Le champ \"n\" reprend OBLIGATOIREMENT le numéro de l'article dans la liste. "
    "Si pertinent est false, mets les autres champs à null. Aucun texte en dehors du tableau JSON."
)


SYSTEM_PROMPT_UNIVERSITES = (
    "Tu es l'assistant de veille de Ndimbeul-Etudiant, une Super App étudiante sénégalaise. "
    "On te donne une liste numérotée de résultats de recherche web (titre + extrait). Pour "
    "CHAQUE résultat, décide s'il désigne réellement UN SEUL établissement d'enseignement "
    "supérieur précis AU SÉNÉGAL (université, institut, ISEP, grande école, école de formation), "
    "avec un nom propre officiel.\n"
    "Marque pertinent=false dans TOUS ces cas (très important, source d'erreurs fréquentes) :\n"
    "- la page est un ANNUAIRE/PORTAIL/COMPARATIF qui liste PLUSIEURS établissements "
    "(ex: \"Liste des écoles de...\", \"Toutes les écoles au Sénégal\", \"Meilleures universités "
    "publiques...\", \"Écoles à Thiès\") — même si des noms d'établissements apparaissent dedans ;\n"
    "- le titre est le nom d'un SITE WEB généraliste ou d'un blog (ex: \"senegalecoles.com\", "
    "\"Écoles.senegal\") et non le nom d'un établissement ;\n"
    "- le résultat mentionne plusieurs établissements à la fois sans que le texte porte sur "
    "UN SEUL d'entre eux en particulier ;\n"
    "- c'est un article qui PARLE d'éducation en général, un calendrier, une actualité — pas la "
    "fiche d'un établissement précis ;\n"
    "- le résultat est hors-sujet ou concerne un autre pays.\n"
    "Quand pertinent=true, le champ \"nom\" doit être UNIQUEMENT le nom propre officiel de CET "
    "établissement (jamais une liste, jamais plusieurs noms séparés par une virgule, jamais un "
    "nom de domaine/site web).\n"
    "Champ \"lien_est_site_officiel\" (TRÈS IMPORTANT, source d'erreurs fréquentes) : l'URL du "
    "résultat est-elle le SITE OFFICIEL de cet établissement (son propre nom de domaine) ? "
    "Réponds false si l'URL est un article qui PARLE de l'établissement, un annuaire, un blog, "
    "un réseau social, ou tout autre site tiers (ex: leadersenegalais.com, comparek.sn, "
    "senlocal.com, expat.com, schoolandcollegelistings.com, etudespro.com ne sont JAMAIS des "
    "sites officiels d'établissement). Dans le doute, réponds false plutôt que de risquer un "
    "mauvais lien.\n"
    "Réponds UNIQUEMENT avec un tableau JSON valide, un objet par résultat dans le MÊME ORDRE, "
    "format strict :\n"
    '[{"pertinent": true|false, "nom": "nom complet et officiel de l\'établissement, ou null", '
    '"type": "public|prive", "lien_est_site_officiel": true|false, '
    '"region": "une région parmi Dakar, Thiès, Saint-Louis, Diourbel, Ziguinchor, Kaolack, '
    'Kaffrine, Kolda, Louga, Matam, Sédhiou, Tambacounda, Kédougou, Fatick, ou null si inconnue", '
    '"commune": "ville/commune si identifiable, sinon null", '
    '"description": "1 à 2 phrases factuelles en français"}, ...]\n'
    "Si pertinent est false, mets les autres champs à null. Aucun texte en dehors du tableau JSON."
)


SYSTEM_PROMPT_FORMATIONS = (
    "Tu es l'assistant de veille de Ndimbeul-Etudiant, une Super App étudiante sénégalaise. "
    "On te donne le texte brut extrait du site web d'un établissement d'enseignement supérieur "
    "sénégalais. Ta mission : lister UNIQUEMENT les filières/formations EXPLICITEMENT NOMMÉES "
    "dans ce texte (jamais une formation plausible mais non mentionnée — si le texte ne liste "
    "aucune filière exploitable, réponds avec un tableau vide []).\n"
    "Pour chaque filière trouvée :\n"
    "- \"intitule\" : le nom exact de la filière (ex: \"Licence Informatique\"), jamais un nom "
    "générique inventé ;\n"
    "- \"niveau\" : un seul parmi bts, licence, master, doctorat, déduit du texte (diplôme "
    "post-bac non précisé -> licence par défaut) ;\n"
    "- \"domaine\" : le domaine général (ex: \"Informatique\", \"Gestion\") si identifiable, "
    "sinon null ;\n"
    "- \"series_acceptees\" : liste des séries du bac explicitement mentionnées comme requises "
    "(ex: [\"S1\",\"S2\"]), ou null si le texte ne précise aucune série ;\n"
    "- \"debouches\" : les métiers/débouchés EXPLICITEMENT mentionnés pour cette filière dans le "
    "texte (ex: \"développeur web, data analyst, ingénieur logiciel\"), en une phrase courte, ou "
    "null si le texte n'en mentionne aucun — c'est ce qui permet de proposer la bonne formation "
    "selon le métier envisagé par l'étudiant, ne l'invente donc jamais.\n"
    "Réponds UNIQUEMENT avec un tableau JSON valide, aucun texte autour :\n"
    '[{"intitule": "...", "niveau": "licence", "domaine": "..." ou null, '
    '"series_acceptees": [...] ou null, "debouches": "..." ou null}, ...]'
)


def construire_messages_formations(nom_universite, texte_page):
    contenu = (
        f"ÉTABLISSEMENT : {nom_universite}\n\n"
        f"TEXTE DE LA PAGE :\n{texte_page}\n\n"
        "Liste les filières explicitement nommées dans ce texte, au format JSON demandé."
    )
    return [
        {'role': 'system', 'content': SYSTEM_PROMPT_FORMATIONS},
        {'role': 'user', 'content': contenu},
    ]


def construire_messages_universites(resultats):
    contenu = (
        f"RÉSULTATS DE RECHERCHE ({len(resultats)}) :\n{_construire_bloc_resultats(resultats)}\n\n"
        f"Réponds avec un tableau JSON de {len(resultats)} objets, dans l'ordre."
    )
    return [
        {'role': 'system', 'content': SYSTEM_PROMPT_UNIVERSITES},
        {'role': 'user', 'content': contenu},
    ]


def _construire_bloc_resultats(resultats):
    lignes = []
    for i, r in enumerate(resultats, start=1):
        extrait = r['extrait'] or "(pas d'extrait)"
        lignes.append(f"{i}. TITRE : {r['titre']}\n   EXTRAIT : {extrait}")
    return '\n'.join(lignes)


def _construire_bloc_articles(resultats):
    """Comme _construire_bloc_resultats, avec le média et la date réelle de chaque
    article : le LLM juge mieux la fiabilité et l'actualité d'un fait daté et sourcé."""
    lignes = []
    for i, r in enumerate(resultats, start=1):
        extrait = r['extrait'] or "(pas d'extrait)"
        date_pub = r.get('date_publication')
        date_txt = date_pub.strftime('%d/%m/%Y') if date_pub else 'inconnue'
        media = r.get('source_nom') or r.get('lien', '')
        lignes.append(
            f"{i}. TITRE : {r['titre']}\n   EXTRAIT : {extrait}\n"
            f"   MÉDIA : {media} — DATE : {date_txt}"
        )
    return '\n'.join(lignes)


def construire_messages_actualites(resultats):
    contenu = (
        f"ARTICLES ({len(resultats)}) :\n{_construire_bloc_articles(resultats)}\n\n"
        f"Réponds avec un tableau JSON de {len(resultats)} objets, dans l'ordre."
    )
    return [
        {'role': 'system', 'content': SYSTEM_PROMPT_ACTUALITES},
        {'role': 'user', 'content': contenu},
    ]


def construire_messages_offres(resultats):
    contenu = (
        f"ARTICLES ({len(resultats)}) :\n{_construire_bloc_articles(resultats)}\n\n"
        f"Réponds avec un tableau JSON de {len(resultats)} objets, dans l'ordre."
    )
    return [
        {'role': 'system', 'content': SYSTEM_PROMPT_OFFRES},
        {'role': 'user', 'content': contenu},
    ]


def parser_reponse_json_liste(texte, nb_attendu):
    """Extrait le premier tableau JSON valide de la réponse LLM (qui ajoute parfois du texte
    ou des ``` autour) et ALIGNE chaque objet sur son article.

    Retourne (fiches, anomalie) : `fiches` est une liste de `nb_attendu` éléments (dict, ou
    None si absent) ; `anomalie` vaut None, 'json_invalide', 'tableau_absent' ou
    'desalignement'.

    Alignement : chaque objet doit porter le numéro de son article dans "n". Sans ce
    numéro, l'ordre n'est accepté que si le LLM a renvoyé EXACTEMENT un objet par article.
    Sinon, tout le lot est rejeté : associer un résumé au mauvais article (et donc au
    mauvais lien) serait pire que de ne rien publier."""
    vide = [None] * nb_attendu
    if not texte:
        return vide, 'tableau_absent'

    match = re.search(r'\[.*\]', texte, re.DOTALL)
    if not match:
        return vide, 'tableau_absent'

    try:
        elements = json.loads(match.group(0))
    except json.JSONDecodeError:
        return vide, 'json_invalide'

    if not isinstance(elements, list):
        return vide, 'json_invalide'

    objets = [e for e in elements if isinstance(e, dict)]
    numeros = [e.get('n') for e in objets]
    if objets and all(isinstance(n, int) for n in numeros):
        resultat = list(vide)
        for objet, n in zip(objets, numeros):
            if 1 <= n <= nb_attendu and resultat[n - 1] is None:
                resultat[n - 1] = objet
        return resultat, None

    if len(elements) == nb_attendu:
        return [e if isinstance(e, dict) else None for e in elements], None

    return vide, 'desalignement'
