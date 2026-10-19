"""Requêtes de recherche prédéfinies pour la veille automatique (PARTIE veille internet)."""

# Requêtes envoyées au moteur d'ACTUALITÉS (flux Bing News, voir
# recherche_web.rechercher_actualites) : chaque résultat est un article de presse
# daté. Couvre tout le parcours de l'élève/étudiant sénégalais.
REQUETES_ACTUALITES = [
    'éducation Sénégal',
    'enseignement supérieur Sénégal',
    'université Sénégal étudiants',
    'bourses étudiants Sénégal',
    'bourse d\'excellence Sénégal',
    'concours Sénégal recrutement',
    'concours d\'entrée école Sénégal',
    'baccalauréat Sénégal',
    'résultats bac Sénégal',
    'BFEM Sénégal',
    'examens scolaires Sénégal',
    'orientation bacheliers Sénégal Campusen',
    'rentrée scolaire Sénégal',
    'rentrée universitaire Sénégal',
    'UCAD',
    'Université Gaston Berger',
    'ISEP Sénégal',
    'formation professionnelle Sénégal jeunes',
    'ministère de l\'Éducation nationale Sénégal',
    'ministère de l\'Enseignement supérieur Sénégal',
    'étudiants sénégalais bourses étranger',
    # Institutions officielles (leurs communiqués sont repris par l'APS et la presse).
    'MESRI Sénégal communiqué',
    'Office du Bac Sénégal',
    'Campusen orientation',
    'Direction des bourses Sénégal',
    # Logement étudiant (bloc « Dernières infos logement » de l'accueil).
    'codification COUD',
    'logement étudiants Sénégal',
    'CROUS Sénégal étudiants',
    'cité universitaire Sénégal',
]

# Offres (emploi, stage, alternance, bourse, formation, concours), cherchées dans le
# même moteur d'ACTUALITÉS : les annonces de recrutement, concours et appels à
# candidatures y sont publiées DATÉES par la presse et les organismes officiels.
#
# La recherche web générale (DuckDuckGo HTML) n'est plus utilisée : son robots.txt
# interdit /html et /lite, et le service bloque désormais ces requêtes (HTTP 202).
# emploisenegal.com reste EXCLU (challenge anti-bot Cloudflare) : le contourner irait
# à l'encontre des conditions d'utilisation du site.
REQUETES_OFFRES = [
    'recrutement Sénégal',
    'avis de recrutement Sénégal',
    'appel à candidatures Sénégal',
    'appel à candidatures jeunes Sénégal',
    'concours fonction publique Sénégal',
    'concours direct Sénégal',
    'concours d\'entrée Sénégal inscriptions',
    'concours ENA Sénégal',
    'recrutement enseignants Sénégal',
    'recrutement jeunes diplômés Sénégal',
    'offre de stage Sénégal',
    'programme de stages Sénégal jeunes',
    'bourse d\'études Sénégal candidature',
    'bourses étudiants sénégalais étranger inscription',
    'formation gratuite jeunes Sénégal inscription',
    'bons de formation 3FPT',
    'ANPEJ emploi jeunes',
    'emploi jeunes Sénégal programme',
]

# Découverte exhaustive des établissements d'enseignement supérieur sénégalais
# (universités publiques/privées, ISEP, grandes écoles, instituts de formation).
# Combine des requêtes générales et une recherche par région (les 14 régions du Sénégal)
# pour maximiser la couverture des petits instituts privés peu connus au niveau national.
REQUETES_UNIVERSITES = [
    'liste universités publiques Sénégal',
    'liste universités et écoles privées Sénégal',
    'ISEP institut supérieur enseignement professionnel Sénégal',
    'grandes écoles Dakar',
    'grandes écoles Thiès Saint-Louis Ziguinchor',
    'institut supérieur formation professionnelle Sénégal',
    'école supérieure de gestion Sénégal',
    'université privée agréée Sénégal',
    'école de commerce Sénégal',
    'institut technologie informatique Sénégal',
    'école ingénieur Sénégal',
    'institut santé médecine paramédical Sénégal',
    'école formation professionnelle agréée MESRI Sénégal',
    'campus universitaire Sénégal inscription',
    # Centres de formation professionnelle et technique (explicitement demandés par
    # l'utilisateur, distincts des universités/grandes écoles ci-dessus).
    '3FPT centre de formation professionnelle Sénégal',
    'lycée technique professionnel Sénégal',
    'centre de formation professionnelle CFP Sénégal',
    'centre sectoriel formation professionnelle Sénégal',
    'formation qualifiante métiers Sénégal',
] + [
    f'université institut école supérieure {region} Sénégal'
    for region in (
        'Dakar', 'Thiès', 'Saint-Louis', 'Diourbel', 'Ziguinchor', 'Kaolack',
        'Kaffrine', 'Kolda', 'Louga', 'Matam', 'Sédhiou', 'Tambacounda',
        'Kédougou', 'Fatick',
    )
] + [
    f'centre de formation professionnelle {region} Sénégal'
    for region in (
        'Dakar', 'Thiès', 'Saint-Louis', 'Diourbel', 'Ziguinchor', 'Kaolack',
        'Kaffrine', 'Kolda', 'Louga', 'Matam', 'Sédhiou', 'Tambacounda',
        'Kédougou', 'Fatick',
    )
]
