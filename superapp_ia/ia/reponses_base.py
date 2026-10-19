"""
Réponses instantanées aux questions de tous les jours, construites directement à partir
de notre base (module 4, chatbot) : dernières actualités, offres de stage ou d'emploi,
liste d'établissements par ville ou par statut.

Pourquoi sans LLM : ces questions ont une réponse EXACTE en base, toujours à jour (la
veille l'alimente toutes les 2 h). Une requête SQL répond en moins d'une seconde, là où
le modèle local mettrait 15 à 25 s sur ce PC, avec un risque d'erreur. Le LLM reste
utilisé pour les questions précises (conditions d'admission, filières, démarches…).

Chaque fonction retourne {'reponse', 'sources'} ou None si la question ne la concerne pas.
"""
from django.db.models import F, Q

from services.cache import normaliser_texte
from veille.models import Actualite, OffreEmploi, Universite

NB_ELEMENTS = 3
NB_ETABLISSEMENTS = 6

_MOTS_ACTUALITES = {'actualite', 'actualites', 'actu', 'actus', 'nouvelles', 'news', 'nouveautes'}
_EXPRESSIONS_ACTUALITES = ('quoi de neuf', 'dernieres infos', 'derniere info', 'infos du jour')
_CATEGORIES_ACTUALITES = {
    'bourse': 'bourse', 'bourses': 'bourse', 'concours': 'concours',
    'formation': 'formation', 'formations': 'formation',
    'evenement': 'evenement', 'evenements': 'evenement', 'calendrier': 'evenement',
}

_TYPES_OFFRES = {
    'stage': 'stage', 'stages': 'stage', 'stagiaire': 'stage',
    'emploi': 'emploi', 'emplois': 'emploi', 'job': 'emploi', 'jobs': 'emploi', 'travail': 'emploi',
    'concours': 'concours', 'alternance': 'alternance',
}
_MOTS_OFFRES = {'offre', 'offres', 'recrutement', 'recrute', 'opportunite', 'opportunites', 'poste', 'postes'}
_MOTS_RECHERCHE = {
    'des', 'quelles', 'quels', 'cherche', 'recherche', 'disponible', 'disponibles', 'ya', 'y',
    'trouver', 'liste', 'nouveaux', 'nouvelles', 'derniers', 'dernieres', 'ouverts', 'ouvertes',
}

_MOTS_ETABLISSEMENTS = {
    'universite', 'universites', 'ecole', 'ecoles', 'etablissement', 'etablissements',
    'institut', 'instituts', 'isep', 'fac', 'facs', 'faculte', 'facultes',
}
_MOTS_LISTE = {'liste', 'quelles', 'quels', 'lesquelles', 'lesquels', 'toutes', 'tous', 'ou', 'combien', 'existe'}
REGIONS = (
    'Dakar', 'Thiès', 'Saint-Louis', 'Ziguinchor', 'Kaolack', 'Diourbel', 'Louga', 'Fatick',
    'Kolda', 'Matam', 'Kaffrine', 'Kédougou', 'Sédhiou', 'Tambacounda',
)

# Mots qui ne précisent pas le DOMAINE d'une offre (« des offres de stage disponibles ? »).
_MOTS_NEUTRES_OFFRES = {
    'y', 'a', 't', 'il', 'des', 'de', 'du', 'les', 'la', 'le', 'en', 'pour', 'un', 'une', 'au',
    'aux', 'quelles', 'quels', 'disponible', 'disponibles', 'ouvert', 'ouverts', 'ouvertes',
    'recent', 'recents', 'recentes', 'dernieres', 'derniers', 'nouvelles', 'nouveaux', 'je',
    'cherche', 'veux', 'voir', 'trouver', 'senegal', 'moi', 'stp', 'svp', 'est', 'ce', 'qu',
    'avez', 'vous', 'as', 'tu', 'actuellement', 'en', 'ce', 'moment', 'existe', 'ya', 'quoi',
}


def _date_courte(valeur):
    return valeur.strftime('%d/%m') if valeur else None


def actualites(message, mots, texte):
    if not (mots & _MOTS_ACTUALITES or any(e in texte for e in _EXPRESSIONS_ACTUALITES)):
        return None
    publiees = Actualite.objects.filter(statut='publie')
    categorie = next((_CATEGORIES_ACTUALITES[m] for m in mots if m in _CATEGORIES_ACTUALITES), None)
    if categorie:
        publiees = publiees.filter(categorie=categorie)
    dernieres = list(publiees.order_by(F('date_publication').desc(nulls_last=True))[:NB_ELEMENTS])
    if not dernieres:
        return None

    lignes = []
    for i, a in enumerate(dernieres, start=1):
        details = ', '.join(filter(None, [a.source_nom, _date_courte(a.date_publication)]))
        lignes.append(f"• {a.titre}{f' ({details})' if details else ''} [{i}]")
    sujet = f'sur les {categorie}s' if categorie else ''
    return {
        'reponse': (
            f"Voici les dernières actualités {sujet} :\n".replace('  ', ' ')
            + '\n'.join(lignes)
            + "\nTu retrouves tout le fil, mis à jour toutes les 2 h, dans l'onglet Actualités."
        ),
        'sources': [{'titre': a.titre, 'url': a.source_url} for a in dernieres],
    }


def offres(message, mots, texte):
    type_offre = next((_TYPES_OFFRES[m] for m in mots if m in _TYPES_OFFRES), None)
    # Il faut une vraie RECHERCHE d'offres : « comment préparer le concours de l'ENA ? »
    # contient « concours » mais appelle une explication, pas une liste d'annonces.
    recherche_d_offres = mots & _MOTS_OFFRES or (type_offre and mots & _MOTS_RECHERCHE)
    if not recherche_d_offres:
        return None
    actives = OffreEmploi.objects.filter(statut='active')
    if type_offre:
        actives = actives.filter(type=type_offre)

    # Mots restants = domaine recherché (« comptabilité », « informatique »…).
    domaine = [
        m for m in mots
        if len(m) >= 4 and m not in _MOTS_NEUTRES_OFFRES and m not in _TYPES_OFFRES and m not in _MOTS_OFFRES
    ]
    trouvees = actives
    if domaine:
        condition = Q()
        for mot in domaine:
            racine = mot[:5] if len(mot) >= 7 else mot
            condition |= Q(intitule__icontains=racine) | Q(domaine__icontains=racine) | Q(description__icontains=racine)
        trouvees = actives.filter(condition)

    liste = list(trouvees.order_by(F('date_collecte').desc(nulls_last=True), '-date_indexation')[:NB_ELEMENTS])
    if not liste:
        if domaine:  # rien dans ce domaine : laisser la recherche complète (base + web) chercher
            return None
        return {
            'reponse': "Je n'ai pas d'offre de ce type en ce moment. La veille en cherche de nouvelles "
                       "toutes les 2 h : reviens bientôt ou consulte l'onglet Emplois.",
            'sources': [],
        }

    nature = {'stage': 'de stage', 'emploi': "d'emploi", 'concours': 'de concours',
              'alternance': "d'alternance"}.get(type_offre, '')
    lignes = []
    for i, o in enumerate(liste, start=1):
        lieu = o.region if o.region and not o.region.startswith('Non précis') else None
        limite = f"date limite le {o.date_limite:%d/%m}" if o.date_limite else None
        details = ', '.join(filter(None, [lieu, limite]))
        lignes.append(f"• {o.intitule}{f' ({details})' if details else ''} [{i}]")
    return {
        'reponse': f"Voici les offres {nature} les plus récentes :\n".replace('  ', ' ')
                   + '\n'.join(lignes)
                   + "\nToutes les offres sont dans l'onglet Emplois.",
        'sources': [{'titre': o.intitule, 'url': o.source_url} for o in liste],
    }


def etablissements(message, mots, texte):
    if not (mots & _MOTS_ETABLISSEMENTS and mots & _MOTS_LISTE):
        return None
    region = next((r for r in REGIONS if f' {normaliser_texte(r)} ' in f' {texte} '), None)
    statut = 'prive' if mots & {'prive', 'privee', 'privees', 'prives'} else (
        'public' if mots & {'public', 'publique', 'publiques', 'publics'} else None)
    if not region and not statut:
        return None  # question trop large : la recherche complète s'en charge

    trouves = Universite.objects.filter(statut_actif=True)
    if region:
        trouves = trouves.filter(Q(region__icontains=region) | Q(commune__icontains=region))
    if statut:
        trouves = trouves.filter(type=statut)
    total = trouves.count()
    liste = list(trouves.order_by('nom')[:NB_ETABLISSEMENTS])
    if not liste:
        return None

    qualificatif = ' '.join(filter(None, [
        {'public': 'publics', 'prive': 'privés'}.get(statut), f'à {region}' if region else None,
    ]))
    lignes = [f"• {u.nom}" + (f" ({u.region})" if u.region and not region else '') for u in liste]
    suite = f"\n… et {total - len(liste)} autre(s)." if total > len(liste) else ''
    return {
        'reponse': f"Voici les établissements {qualificatif} de notre base ({total}) :\n"
                   + '\n'.join(lignes) + suite
                   + "\nTu trouveras leurs formations et leurs contacts dans l'onglet Universités.",
        'sources': [{'titre': u.nom, 'url': u.site_web_officiel or None} for u in liste],
    }


def repondre(message):
    """Première réponse instantanée qui s'applique, ou None (question à rechercher)."""
    texte = normaliser_texte(message)
    mots = set(texte.split())
    for regle in (actualites, offres, etablissements):
        resultat = regle(message, mots, texte)
        if resultat:
            return resultat
    return None
