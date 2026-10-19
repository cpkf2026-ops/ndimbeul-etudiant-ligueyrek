"""Prompt du module 1 (orientation) : le LLM ne choisit que les MÉTIERS, parmi ceux
cités dans des sources numérotées. Formations et universités viennent de la base
et du moteur de score, sans LLM (voir recommandations/orientation.py)."""
import re

from services.texte import extrait_pertinent

# Le modèle ne fait que CHOISIR (noms + numéro de source, ~40 tokens à écrire au lieu de
# ~140 avec des justifications) : la justification est construite par orientation.py à
# partir de la source et des passions, donc toujours exacte. Prompt bref : le modèle le
# relit à chaque requête, à ~25 tokens/s sur ce CPU.
#
# Format de sortie en LIGNES (« nom | numéro ») plutôt qu'en JSON : mesuré sur ce CPU, le
# modèle écrit un JSON indenté qui épuise ~30 tokens par métier (accolades, espaces), contre
# ~8 tokens par ligne ici. 5 métiers tiennent ainsi en ~6 s au lieu de ~20 s.
SYSTEM_PROMPT_METIERS = (
    "Conseiller d'orientation au Sénégal. Choisis 3 à 5 métiers adaptés au profil, "
    "UNIQUEMENT parmi ceux écrits dans les SOURCES, nom recopié tel quel. "
    "Un métier est une profession (ex. infirmier, développeur), pas une filière ni un domaine. "
    "Une ligne par métier, au format : nom du métier | numéro de la source. Rien d'autre. "
    "Si aucune source ne cite de métier, réponds : AUCUN"
)

_LIGNE_METIER = re.compile(r'^\s*(?:[-*•]|\d+[.)])?\s*(.+?)\s*\|\s*\[?(\d+)\]?\s*$')


def lire_metiers(reponse):
    """'Développeur web | 3' (une ligne par métier) -> [{'nom': 'Développeur web', 'source': 3}].
    Les lignes qui ne respectent pas le format sont ignorées."""
    metiers = []
    for ligne in (reponse or '').splitlines():
        correspondance = _LIGNE_METIER.match(ligne)
        if correspondance:
            metiers.append({'nom': correspondance[1].strip(' "*'), 'source': int(correspondance[2])})
    return metiers

# Sur ce CPU, le modèle LIT le prompt à ~25 tokens/s : on n'envoie de chaque source que
# les phrases qui parlent de métiers ou des passions de l'élève.
LONGUEUR_MAX_SOURCE = 180
MOTS_METIERS = ('metier', 'metiers', 'debouche', 'debouches', 'emploi', 'carriere', 'poste', 'profession')


def construire_messages_metiers(profil, sources):
    mots = list(MOTS_METIERS) + [mot for passion in profil['passions'] for mot in passion.split()]
    lignes_sources = [
        f"[{i}] {source['titre']} — {extrait_pertinent(source['texte'], mots, LONGUEUR_MAX_SOURCE)}"
        for i, source in enumerate(sources, start=1)
    ]
    contenu = (
        f"PROFIL : bac {profil['serie_bac']}, moyenne {profil['moyenne']}/20, "
        f"passions : {', '.join(profil['passions'])}\n\n"
        "SOURCES :\n" + '\n'.join(lignes_sources)
    )
    return [
        {'role': 'system', 'content': SYSTEM_PROMPT_METIERS},
        {'role': 'user', 'content': contenu},
    ]
