"""
Thésaurus des DOMAINES d'études : relie les métiers, passions et matières d'un élève aux
formations et aux domaines affichés sur les fiches des établissements.

Pourquoi : le petit modèle d'embeddings rapprochait mal les mots rares (« douane » ->
Puériculteur, mesuré le 21/10/2026). Traduire d'abord le profil en domaines rend les
recommandations cohérentes, explicables (« en lien avec ton projet de douanier ») et
couvre « de tout et de rien ». Le modèle reste en appoint pour les mots absents d'ici.

Connaissance générale des filières (quelle formation mène à quel métier), jamais de
donnée inventée sur un établissement : ce que propose une école vient de sa fiche.

Mots-clés écrits SANS accents et en minuscules ; un mot de 5 lettres ou plus compte aussi
comme début de mot (« informati » -> informatique, informaticien).
"""
import re

from services.cache import normaliser_texte

DOMAINES = {
    'sante': ('Santé et médecine', [
        'sante', 'medecin', 'medecine', 'infirmi', 'sage femme', 'sages femmes', 'pharmac', 'dentist',
        'dentaire', 'kine', 'kinesitherap', 'soins', 'soignant', 'hopital', 'chirurg', 'pediatr', 'paramedic',
        'laborantin', 'biologie medicale', 'radiolog', 'puericult', 'orthoprot', 'aide soignant', 'nutrition',
        'obstetri', 'anesthes', 'medical', 'medicale', 'docteur', 'sanitaire', 'ambulanc', 'urgences']),
    'informatique': ('Informatique et numérique', [
        'informati', 'developpeu', 'developpement web', 'programm', 'codage', 'coder', 'logiciel', 'reseau',
        'cybersecur', 'securite informatique', 'data', 'donnees', 'intelligence artificielle', 'ordinateur',
        'jeux video', 'web', 'telecom', 'systemes d information', 'base de donnees',
        'application', 'robotiq', 'genie informatique', 'technologies de l information']),
    'droit': ('Droit et sciences juridiques', [
        'droit', 'juriste', 'juridique', 'avocat', 'magistrat', 'juge', 'notaire', 'huissier', 'greffier',
        'justice', 'legislat', 'sciences juridiques', 'criminolog']),
    'douane_commerce_international': ('Douane, transit et commerce international', [
        'douane', 'douanier', 'transit', 'transitaire', 'declarant', 'import', 'export', 'commerce international',
        'commerce exterieur', 'echanges internationaux']),
    'finance_comptabilite': ('Finance, banque, comptabilité', [
        'finance', 'banque', 'banquier', 'bancaire', 'assurance', 'comptab', 'audit', 'fiscal', 'impots',
        'tresor', 'microfinance', 'actuari', 'controle de gestion', 'expert comptable']),
    'economie': ('Économie', ['economi', 'econometr', 'statisti', 'analyse economique', 'developpement economique']),
    'gestion_management': ('Gestion, management et ressources humaines', [
        'gestion', 'management', 'manager', 'entreprise', 'entrepreneu', 'administration des entreprises',
        'ressources humaines', 'ressource humaine', 'rh', 'gestion de projet', 'administrat', 'secretari',
        'assistant de direction', 'qualite', 'business']),
    'commerce_marketing': ('Commerce, vente et marketing', [
        'commerce', 'commercial', 'vente', 'vendeur', 'marketing', 'publicit', 'negoci', 'grande distribution',
        'e commerce', 'relation client']),
    'communication_journalisme': ('Journalisme, communication et audiovisuel', [
        'journalis', 'communication', 'media', 'radio', 'television', 'tele', 'audiovisuel', 'cinema',
        'photograph', 'montage video', 'realisation', 'reportage', 'presentat', 'animateur', 'multimedia', 'relations publiques']),
    'lettres_langues': ('Lettres, langues et sciences humaines', [
        'francais', 'lettres', 'litterat', 'langues', 'anglais', 'espagnol', 'allemand', 'arabe', 'portugais',
        'chinois', 'traduct', 'traducteur', 'interpret', 'ecriture', 'ecrivain', 'philosoph', 'histoire',
        'geograph', 'linguisti', 'sciences humaines', 'documentation', 'archiv', 'bibliothec']),
    'education': ('Éducation et enseignement', [
        'enseign', 'professeur', 'instituteur', 'education', 'pedagog', 'formateur', 'petite enfance',
        'sciences de l education', 'maitre', 'eleves']),
    'agriculture_environnement': ('Agriculture, élevage et environnement', [
        'agricult', 'agricole', 'agronom', 'elevage', 'eleveur', 'peche', 'aquacult', 'veterinai', 'environnement',
        'ecolog', 'climat', 'eau', 'foret', 'agroalimentaire', 'horticult', 'agrobusiness', 'developpement rural',
        'nature', 'animaux', 'aliment', 'traitement des aliments']),
    'genie_civil_btp': ('Génie civil, BTP et architecture', [
        'genie civil', 'btp', 'batiment', 'construction', 'architect', 'urbanis', 'topograph', 'geometre',
        'travaux publics', 'routes', 'immobilier', 'chantier', 'beton']),
    'industrie_energie': ('Électricité, énergie et industrie', [
        'electric', 'electrotech', 'energie', 'solaire', 'electroni', 'automatis', 'automatism', 'mecani',
        'maintenance', 'industri', 'genie electrique', 'froid', 'climatis', 'petrole', 'gaz', 'mines', 'soudure',
        'mecatroni', 'genie mecanique', 'minier', 'miniere', 'extraction']),
    'transport_logistique': ('Transport et logistique', [
        'logisti', 'transport', 'supply chain', 'chaine logistique',
        'maritime', 'marine', 'portuaire', 'port', 'navigation', 'chemin de fer', 'ferroviai']),
    'aeronautique': ('Aéronautique et aviation', [
        'aviation', 'aeronauti', 'pilote', 'aerien', 'avion', 'avions', 'hotesse de l air', 'steward',
        'aeroport', 'controleur aerien', 'aeromecani']),
    'tourisme_hotellerie': ('Tourisme, hôtellerie et restauration', [
        'tourisme', 'hotel', 'hotellerie', 'restaura', 'cuisine', 'cuisinier', 'chef', 'patisser', 'boulang',
        'voyage', 'accueil', 'evenementiel', 'reception']),
    'arts_design': ('Arts, design et mode', [
        'art', 'arts', 'artiste', 'dessin', 'design', 'graphis', 'infographi', 'mode', 'stylis', 'couture',
        'musique', 'musicien', 'chant', 'danse', 'theatre', 'peinture', 'sculpture', 'culture', 'patrimoine', 'artisanat', 'textile', 'vetement', 'chaussure', 'cuir']),
    'sport': ('Sport et éducation physique', [
        'sport', 'football', 'basket', 'athletisme', 'lutte', 'education physique', 'staps', 'entraineur',
        'coach', 'fitness']),
    'sciences': ('Sciences fondamentales', [
        'mathemat', 'maths', 'physique', 'chimie', 'biologie', 'sciences naturelles', 'svt', 'geologie',
        'sciences de la vie', 'astronom', 'recherche scientifique', 'sciences exactes', 'sciences de la terre']),
    'securite_defense': ('Sécurité et défense', [
        'militaire', 'armee', 'soldat', 'gendarm', 'police', 'policier', 'securite publique', 'defense nationale',
        'pompier', 'sapeur', 'renseignement']),
    'sciences_politiques': ('Sciences politiques et relations internationales', [
        'diplomat', 'relations internationales', 'sciences politiques', 'politique', 'ambassad',
        'administration publique', 'fonction publique', 'gouvernance']),
    'social': ('Social, psychologie et humanitaire', [
        'social', 'sociale', 'assistant social', 'psycholog', 'sociolog', 'humanitaire', 'ong', 'travail social',
        'aide a la personne', 'developpement communautaire']),
    'etudes_islamiques': ('Études islamiques et arabes', ['islam', 'islamique', 'coran', 'theologie', 'etudes arabes']),
}

# Domaines VOISINS : quand le catalogue n'a rien dans le domaine exact (aviation, douane…),
# une formation d'un domaine voisin est proposée à demi-score, et présentée comme telle.
VOISINS = {
    'aeronautique': ['transport_logistique', 'industrie_energie'],
    'douane_commerce_international': ['transport_logistique', 'commerce_marketing', 'droit', 'finance_comptabilite'],
    'sante': ['sciences', 'social'],
    'droit': ['sciences_politiques', 'securite_defense'],
    'sciences_politiques': ['droit', 'lettres_langues'],
    'securite_defense': ['droit'],
    'informatique': ['sciences', 'industrie_energie'],
    'finance_comptabilite': ['economie', 'gestion_management'],
    'economie': ['finance_comptabilite', 'gestion_management'],
    'gestion_management': ['commerce_marketing', 'finance_comptabilite'],
    'commerce_marketing': ['gestion_management', 'communication_journalisme'],
    'communication_journalisme': ['lettres_langues', 'commerce_marketing'],
    'lettres_langues': ['communication_journalisme', 'education'],
    'education': ['lettres_langues', 'social'],
    'agriculture_environnement': ['sciences'],
    'genie_civil_btp': ['industrie_energie', 'arts_design'],
    'industrie_energie': ['genie_civil_btp', 'informatique'],
    'transport_logistique': ['douane_commerce_international', 'gestion_management'],
    'tourisme_hotellerie': ['commerce_marketing', 'gestion_management'],
    'arts_design': ['communication_journalisme'],
    'sport': ['education', 'sante'],
    'social': ['education', 'sante'],
}

# Poids d'un terme du profil selon sa nature : le métier visé compte plus qu'une passion,
# qui compte plus qu'une matière forte.
POIDS_METIER, POIDS_PASSION, POIDS_MATIERE = 3, 2, 1


def _mots(texte):
    return re.findall(r'[a-z0-9]+', normaliser_texte(texte or ''))


def _correspond(cle, mots, texte_normalise):
    if ' ' in cle:
        return f' {cle} ' in texte_normalise
    if len(cle) >= 5:
        return any(m.startswith(cle) for m in mots)
    return cle in mots


def domaines_du_texte(texte):
    """Domaines dont un mot-clé apparaît dans `texte` (intitulé, domaine de fiche…)."""
    mots = _mots(texte)
    texte_normalise = f" {' '.join(mots)} "
    return {d for d, (_, cles) in DOMAINES.items() if any(_correspond(c, mots, texte_normalise) for c in cles)}


def domaines_du_profil(profil):
    """{domaine: poids} et {domaine: [termes du profil qui y mènent]}, plus les termes inconnus."""
    poids, termes, inconnus = {}, {}, []
    sources = [(profil.get('metiers_envisages') or [], POIDS_METIER),
               (profil.get('passions') or [], POIDS_PASSION),
               (profil.get('matieres_fortes') or [], POIDS_MATIERE)]
    for liste, p in sources:
        for terme in liste:
            trouves = domaines_du_texte(terme)
            if not trouves:
                inconnus.append(terme)
            for d in trouves:
                poids[d] = poids.get(d, 0) + p
                termes.setdefault(d, []).append(terme)
    return poids, termes, inconnus


def libelle(domaine):
    return DOMAINES[domaine][0]
