"""
Repérer de QUEL établissement parle une question du chat.

Problèmes corrigés (constatés le 21/10/2026) :
  - « j'ai DIT je veux le site de l'université de Bambey » -> le chatbot répondait DIT
    (Dakar Institute of Technology) : le verbe « dit » était pris pour le sigle « DIT » ;
  - « Bambey » seul ne retrouvait pas l'Université Alioune Diop de Bambey (il fallait le
    nom complet ou le sigle) ;
  - « le lien du site de CETTE université » : l'établissement de la réponse précédente
    n'était pas repris.

Règles : un sigle compte seulement s'il n'est pas un mot français courant ; un mot du nom
compte seulement s'il est DISTINCTIF (présent dans au plus 3 noms d'établissements :
« Bambey », « Berger », « Kocc »… mais jamais « Dakar », « université », « supérieur »).
"""
import re
import time
from collections import Counter

from django.db import DatabaseError
from django.db.models import Count, Max, Min

from services.cache import normaliser_texte
from veille.models import Universite

# Mots français de 2 à 5 lettres qui sont aussi des sigles d'établissements (DIT, EST, ISM…) :
# écrits en minuscules dans une phrase, ce sont des mots, pas des sigles.
MOTS_COURANTS = {
    'dit', 'est', 'des', 'les', 'une', 'ses', 'son', 'sur', 'par', 'pour', 'qui', 'que', 'ont', 'pas',
    'mon', 'ton', 'tes', 'mes', 'nos', 'vos', 'aux', 'ces', 'car', 'mais', 'donc', 'ici', 'oui', 'non',
    'bien', 'tout', 'plus', 'sup', 'faire', 'site', 'lien', 'bac', 'cap', 'sans', 'avec', 'dans',
    'elle', 'nous', 'vous', 'leur', 'fac', 'art', 'arts', 'mer', 'air', 'vie', 'ile', 'eau',
}
# Mots trop généraux pour désigner un établissement, même s'ils sont rares.
MOTS_GENERIQUES = {
    'universite', 'universitaire', 'institut', 'ecole', 'superieur', 'superieure', 'national', 'nationale',
    'centre', 'formation', 'groupe', 'enseignement', 'professionnel', 'senegal', 'dakar', 'prive', 'privee',
    'internationale', 'international', 'sciences', 'technologie', 'technologies', 'management', 'gestion',
    'campus', 'etudes', 'hautes', 'africain', 'africaine', 'polytechnique', 'faculte', 'business', 'school',
    'thies', 'saint', 'louis', 'technique', 'techniques', 'metiers', 'commerce', 'sante',
    # Domaines d'études : « je veux faire du droit » ne désigne pas l'institut « … de Droit ».
    'droit', 'informatique', 'ingenieurs', 'ingenierie', 'agriculture', 'agricole', 'communication',
    'journalisme', 'education', 'finance', 'banque', 'tourisme', 'marketing', 'environnement',
    'logistique', 'transport', 'medecine', 'pharmacie', 'architecture', 'economie', 'statistique',
    'paramedical', 'paramedicale', 'infirmier', 'design', 'numerique', 'digital', 'affaires', 'langues',
    # Mots courants qui figurent dans quelques noms (« École des savoir-faire », « Sahel Vert »…).
    'faire', 'savoir', 'vert', 'libre', 'zone', 'nord', 'ouest', 'moderne', 'excellence', 'avenir',
    'academie', 'college', 'elite', 'maison', 'nouvelle', 'nouvelles', 'reussite', 'avenue', 'perform',
    # Termes de filières présents dans quelques noms (« Institut en génie biomédical ») :
    # « formation en génie civil » ne désigne pas cet institut.
    'genie', 'civil', 'biomedical', 'hotellerie', 'hoteliere', 'cuisine', 'electricite', 'batiment',
    'travaux', 'publics', 'environnement', 'securite', 'audiovisuel', 'multimedia', 'statistiques',
}
# Mots-outils de 4 lettres ou plus : jamais distinctifs, même s'ils figurent dans peu de noms.
# Observé le 29/10/2026 : « pour » (Institut Professionnel POUR la Sécurité Informatique)
# faisait de « ok je vois merci pour votre réponse » une question sur Iprosi.
MOTS_OUTILS = {
    'pour', 'avec', 'dans', 'sans', 'sous', 'vers', 'chez', 'entre', 'contre', 'leur', 'leurs',
    'notre', 'votre', 'nous', 'vous', 'elle', 'elles', 'cette', 'tout', 'tous', 'toute', 'toutes',
    'plus', 'tres', 'bien', 'aussi', 'mais', 'donc', 'alors', 'apres', 'avant', 'depuis', 'selon',
}
# « cette université », « son site », « celle-ci » : la question renvoie à un établissement déjà cité.
RENVOI = re.compile(
    r"\b(cet(te)?\s+(universit|ecole|institut|etablissement|fac)|ce\s+(campus|centre|lycee)|"
    r"son\s+site|leur\s+site|celle[- ]ci|celui[- ]ci|cette\s+derniere|la[- ]bas|y\s+etudier)",
)

_CACHE = {'index': None, 'date': 0.0}
_DUREE_CACHE = 600  # secondes : le catalogue change rarement


def _mots(texte):
    return re.findall(r'[a-z0-9]+', normaliser_texte(texte or ''))


def _index():
    """Établissements actifs avec leurs sigles et leurs mots distinctifs (mis en cache, et
    recalculé dès que le catalogue change : ajout par un administrateur, correction…)."""
    actifs = Universite.objects.filter(statut_actif=True, deleted_at__isnull=True)
    try:
        # Nombre, dernière modification et bornes des identifiants : un changement de catalogue,
        # même dans la même seconde, donne une autre signature.
        signature = tuple(actifs.aggregate(n=Count('id'), maj=Max('updated_at'), a=Min('id'), b=Max('id')).values())
    except DatabaseError:
        return _CACHE['index'] or []
    if (_CACHE['index'] is not None and _CACHE.get('signature') == signature
            and time.monotonic() - _CACHE['date'] < _DUREE_CACHE):
        return _CACHE['index']
    try:
        lignes = list(actifs.values('id', 'nom', 'code_unique', 'site_web_officiel', 'region', 'commune'))
    except DatabaseError:
        return []
    frequence = Counter(m for u in lignes for m in set(_mots(re.sub(r'\(.*?\)', ' ', u['nom']))))
    index = []
    for u in lignes:
        # Entre parenthèses : un sigle seulement s'il est écrit en capitales (« (UGB) », pas « (Dakar) »).
        sigles = {normaliser_texte(s).replace(' ', '').replace('-', '')
                  for s in re.findall(r'\(([^)]{2,15})\)', u['nom']) if re.search(r'[A-Z]{2,}', s)}
        sigles |= {normaliser_texte(m) for m in re.findall(r'\b[A-Z][A-Z0-9]{2,}\b', u['nom'])}
        # Code de l'établissement (« UCAD », « ISM-DAKAR » -> « ism ») : le sigle de l'établissement
        # PRINCIPAL, prioritaire sur ses antennes (« ISM Zone Nord »).
        racine_code = normaliser_texte((u['code_unique'] or '').split('-')[0])
        # Seulement un vrai sigle : pas un mot du nom (codes générés « SAHEL-VERT », « AKADEMIA-DAKAR »).
        mots_du_nom = set(_mots(re.sub(r'\(.*?\)', ' ', u['nom'])))
        code_principal = (racine_code if racine_code.isalpha() and 3 <= len(racine_code) <= 6
                          and racine_code not in mots_du_nom else None)
        if code_principal:
            sigles.add(code_principal)
        sigles = {s for s in sigles if s not in MOTS_GENERIQUES}
        distinctifs = {
            m for m in _mots(re.sub(r'\(.*?\)', ' ', u['nom']))
            if len(m) >= 4 and frequence[m] <= 3 and m not in MOTS_GENERIQUES and m not in MOTS_OUTILS
        }
        index.append({**u, 'sigles': {s for s in sigles if len(s) >= 2}, 'distinctifs': distinctifs,
                      'code_principal': code_principal})
    _CACHE.update(index=index, date=time.monotonic(), signature=signature)
    return index


def trouver(texte):
    """L'établissement le plus clairement désigné dans `texte`, ou None."""
    if not texte:
        return None
    mots = set(_mots(texte))
    # Sigles écrits EN MAJUSCULES dans le texte d'origine : toujours des sigles (« DIT »).
    majuscules = {normaliser_texte(m) for m in re.findall(r'\b[A-Z][A-Z0-9]{1,}\b', texte)}
    meilleur, meilleur_score = None, 0
    for u in _index():
        score = 0
        for s in u['sigles']:
            if s in majuscules or (s in mots and s not in MOTS_COURANTS):
                score += 3
                if s == u['code_principal']:
                    score += 1  # même sigle partagé avec une antenne : l'établissement principal d'abord
        score += 2 * len(u['distinctifs'] & mots)
        # Nom complet présent tel quel (titre d'une source : « Université Cheikh Anta Diop »).
        nom_complet = ' '.join(_mots(re.sub(r'\(.*?\)', ' ', u['nom'])))
        if len(nom_complet) > 12 and f' {nom_complet} ' in f" {' '.join(_mots(texte))} ":
            score += 5
        if score >= 2:
            # Plusieurs établissements au même sigle (ISEP Thiès, Matam, Bignona…) : la ville citée départage.
            if set(_mots(f"{u['commune'] or ''} {u['region'] or ''}")) & mots:
                score += 2
            # À égalité, celui dont le nom complet est le plus présent dans la question
            # (« université du Sahel » -> Université du Sahel plutôt que Sahel Vert).
            noms = set(_mots(re.sub(r'\(.*?\)', ' ', u['nom'])))
            score += 0.1 * len(noms & mots) - 0.01 * len(noms - mots)
        if score > meilleur_score:
            meilleur, meilleur_score = u, score
    return meilleur if meilleur_score >= 2 else None


def renvoie_a_un_etablissement(question):
    return bool(RENVOI.search(normaliser_texte(question or '')))


def depuis_historique(historique):
    """Dernier établissement cité dans la conversation (sources des réponses d'abord)."""
    for tour in reversed(historique or []):
        for source in tour.get('sources') or []:
            u = trouver(source.get('titre') if isinstance(source, dict) else str(source))
            if u:
                return u
        u = trouver(str(tour.get('contenu') or tour.get('content') or ''))
        if u:
            return u
    return None


def cites_dans_la_derniere_reponse(historique):
    """Établissements (distincts) cités dans les sources de la dernière réponse du chatbot."""
    for tour in reversed(historique or []):
        if tour.get('role') != 'assistant':
            continue
        # Sources de la réponse, ou à défaut chaque ligne de son texte (« • Licence… — UGB »).
        morceaux = [s.get('titre') if isinstance(s, dict) else str(s) for s in tour.get('sources') or []]
        if not morceaux:
            morceaux = str(tour.get('contenu') or tour.get('content') or '').splitlines()
        trouves = []
        for morceau in morceaux:
            u = trouver(morceau)
            if u and u['id'] not in {t['id'] for t in trouves}:
                trouves.append(u)
        return trouves
    return []


def etablissement_de_la_question(question, historique=None):
    """Établissement cité dans la question, sinon (« cette université »…) celui de la conversation."""
    u = trouver(question)
    if u is None and renvoie_a_un_etablissement(question):
        u = depuis_historique(historique)
    return u
