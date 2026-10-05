"""
Liste de référence des principaux établissements d'enseignement supérieur
sénégalais, connus avec certitude (universités publiques officielles +
grandes écoles publiques + établissements privés reconnus de longue date).

Cette liste sert de SOCLE FIABLE chargé une fois (voir pipeline.charger_seed_universites) :
elle garantit que l'application affiche toujours les établissements majeurs avec de
vraies informations, même si la découverte web (recherche_web + classification LLM,
voir pipeline.veiller_universites) est bruitée ou momentanément indisponible. La
découverte web continue ensuite d'enrichir la base avec les instituts privés plus
petits/moins connus, au fil de la veille automatique (Celery Beat, 1x/jour).

Volontairement limitée aux établissements dont l'existence est certaine : mieux vaut
une liste incomplète que des noms inventés.
"""

SEED_UNIVERSITES = [
    # --- Universités publiques ---
    {
        'nom': 'Université Cheikh Anta Diop de Dakar',
        'code_unique': 'UCAD',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'public',
        'site_web_officiel': 'https://ucad.sn',
        'description': "La plus ancienne et la plus grande université publique du Sénégal, fondée en 1957.",
    },
    {
        'nom': 'Université Gaston Berger de Saint-Louis',
        'code_unique': 'UGB',
        'region': 'Saint-Louis', 'commune': 'Saint-Louis', 'type': 'public',
        'site_web_officiel': 'https://ugb.sn',
        'description': "Deuxième université publique du Sénégal, créée en 1990.",
    },
    {
        'nom': 'Université Assane Seck de Ziguinchor',
        'code_unique': 'UASZ',
        'region': 'Ziguinchor', 'commune': 'Ziguinchor', 'type': 'public',
        'site_web_officiel': 'https://uasz.sn',
        'description': "Université publique de la région de Ziguinchor, en Casamance.",
    },
    {
        'nom': 'Université Alioune Diop de Bambey',
        'code_unique': 'UADB',
        'region': 'Diourbel', 'commune': 'Bambey', 'type': 'public',
        'site_web_officiel': 'https://uadb.edu.sn',
        'description': "Université publique de la région de Diourbel.",
    },
    {
        'nom': 'Université Iba Der Thiam de Thiès',
        'code_unique': 'UIDT',
        'region': 'Thiès', 'commune': 'Thiès', 'type': 'public',
        'site_web_officiel': 'https://uidt.edu.sn',
        'description': "Université publique de Thiès (anciennement Université de Thiès).",
    },
    {
        'nom': "Université du Sine Saloum El Hadji Ibrahima Niasse",
        'code_unique': 'USSEIN',
        'region': 'Kaffrine', 'commune': 'Kaffrine', 'type': 'public',
        'site_web_officiel': 'https://ussein.edu.sn',
        'description': "Université publique du Sine Saloum, couvrant Kaffrine, Kaolack et Fatick.",
    },
    {
        'nom': 'Université Amadou Mahtar Mbow',
        'code_unique': 'UAM',
        'region': 'Dakar', 'commune': 'Diamniadio', 'type': 'public',
        'site_web_officiel': 'https://uam.sn',
        'description': "Université publique nouvelle génération basée au pôle urbain de Diamniadio.",
    },
    {
        'nom': 'Université Virtuelle du Sénégal',
        'code_unique': 'UVS',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'public',
        'site_web_officiel': 'https://uvs.sn',
        'description': "Université publique 100% à distance, avec des espaces numériques ouverts dans tout le pays.",
    },
    # --- Grandes écoles publiques ---
    {
        'nom': 'École Supérieure Polytechnique de Dakar',
        'code_unique': 'ESP-DAKAR',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'public',
        'site_web_officiel': 'https://esp.sn',
        'description': "École d'ingénieurs publique rattachée à l'UCAD.",
    },
    {
        'nom': 'École Normale Supérieure de Dakar',
        'code_unique': 'ENS-DAKAR',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'public',
        'site_web_officiel': None,
        'description': "École publique de formation des enseignants, rattachée à l'UCAD.",
    },
    {
        'nom': 'École Nationale d\'Administration et de Magistrature',
        'code_unique': 'ENAM',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'public',
        'site_web_officiel': None,
        'description': "École publique de formation des hauts fonctionnaires et magistrats.",
    },
    {
        'nom': "École Nationale d'Économie Appliquée",
        'code_unique': 'ENEA',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'public',
        'site_web_officiel': 'https://enea.sn',
        'description': "École publique de formation en statistique, planification et économie appliquée.",
    },
    {
        'nom': 'École Polytechnique de Thiès',
        'code_unique': 'EPT',
        'region': 'Thiès', 'commune': 'Thiès', 'type': 'public',
        'site_web_officiel': 'https://ept.sn',
        'description': "École d'ingénieurs de statut parapublic, réputée au Sénégal.",
    },
    # --- Établissements privés reconnus ---
    {
        'nom': 'Institut Supérieur de Management de Dakar',
        'code_unique': 'ISM-DAKAR',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'prive',
        'site_web_officiel': 'https://ism.sn',
        'description': "Groupe d'enseignement supérieur privé, l'un des plus anciens du Sénégal.",
    },
    {
        'nom': 'Institut Africain de Management',
        'code_unique': 'IAM',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'prive',
        'site_web_officiel': 'https://iam.sn',
        'description': "École supérieure de commerce et de management privée.",
    },
    {
        'nom': 'Université Dakar Bourguiba',
        'code_unique': 'UDB',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'prive',
        'site_web_officiel': None,
        'description': "Université privée sénégalo-tunisienne.",
    },
    {
        'nom': 'Université Libre de Dakar',
        'code_unique': 'ULD',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'prive',
        'site_web_officiel': 'https://uld.sn',
        'description': "Université privée pluridisciplinaire, l'une des plus anciennes universités privées du pays.",
    },
    {
        'nom': 'École Supérieure Multinationale des Télécommunications',
        'code_unique': 'ESMT',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'prive',
        'site_web_officiel': 'https://esmt.sn',
        'description': "École régionale spécialisée dans les télécommunications et le numérique.",
    },
    {
        'nom': 'Centre Africain d\'Études Supérieures en Gestion',
        'code_unique': 'CESAG',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'prive',
        'site_web_officiel': 'https://cesag.sn',
        'description': "École régionale de gestion de haut niveau, sous l'égide de la BCEAO.",
    },
    {
        'nom': 'Institut Supérieur d\'Informatique',
        'code_unique': 'ISI-DAKAR',
        'region': 'Dakar', 'commune': 'Dakar', 'type': 'prive',
        'site_web_officiel': None,
        'description': "École supérieure privée spécialisée en informatique et technologies.",
    },
]
