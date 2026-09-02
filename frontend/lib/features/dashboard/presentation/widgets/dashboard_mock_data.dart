import '../../../../shared/constants/app_images.dart';

/// Données d'aperçu pour l'Accueil — remplacées par les providers réels
/// des features `universities` / `news` / `jobs` une fois ces modules
/// branchés (voir §11 : le dashboard consomme leurs Repository/UseCase).
class DashboardActuality {
  const DashboardActuality({
    required this.title,
    required this.category,
    required this.imageUrl,
  });

  final String title;
  final String category;
  final String imageUrl;
}

class DashboardUniversity {
  const DashboardUniversity({
    required this.id,
    required this.nom,
    required this.sousTitre,
    required this.imageUrl,
    required this.nbFormations,
  });

  final String id;
  final String nom;
  final String sousTitre;
  final String imageUrl;
  final int nbFormations;
}

class DashboardHousing {
  const DashboardHousing({
    required this.title,
    required this.distance,
    required this.prix,
    required this.imageUrl,
  });

  final String title;
  final String distance;
  final String prix;
  final String imageUrl;
}

final List<DashboardActuality> kMockActualites = [
  DashboardActuality(
    title: 'Ouverture des inscriptions CAMPUSEN 2026',
    category: 'Inscriptions',
    imageUrl: AppImages.etudiantsGroupe,
  ),
  DashboardActuality(
    title: 'Nouvelles bourses d\'excellence ISEP disponibles',
    category: 'Bourses',
    imageUrl: AppImages.bibliotheque,
  ),
  DashboardActuality(
    title: 'Journée portes ouvertes UCAD — 20 septembre',
    category: 'Événement',
    imageUrl: AppImages.amphi,
  ),
];

// Photos réelles et spécifiques à chaque établissement (voir
// CREDITS_IMAGES.md) — plus aucune photo générique dupliquée entre
// plusieurs universités sur cette section. ISEP Thiès n'a aucune photo de
// bâtiment exploitable trouvée (aucune page Wikipédia/Commons dédiée) ;
// repli sur une photo réelle mais spécifique tout de même — des étudiants
// en atelier, tirée du site officiel isep-thies.sn — plutôt qu'une photo
// générique sans rapport (bibliothèque déjà utilisée ailleurs).
final List<DashboardUniversity> kMockUniversities = [
  DashboardUniversity(
    id: 'univ_ucad',
    nom: 'UCAD',
    sousTitre: 'Cheikh Anta Diop University',
    imageUrl: AppImages.campusUcadReal,
    nbFormations: 132,
  ),
  DashboardUniversity(
    id: 'univ_isep_thies',
    nom: 'ISEP Thiès',
    sousTitre: 'Institut Supérieur',
    imageUrl: AppImages.isepThiesAtelier,
    nbFormations: 24,
  ),
  DashboardUniversity(
    id: 'univ_esp',
    nom: 'ESP',
    sousTitre: 'École Sup. Polytechnique',
    imageUrl: AppImages.campusEspReal,
    nbFormations: 41,
  ),
  DashboardUniversity(
    id: 'univ_ugb',
    nom: 'UGB',
    sousTitre: 'Gaston Berger',
    imageUrl: AppImages.campusUgbReal,
    nbFormations: 78,
  ),
  DashboardUniversity(
    id: 'univ_uam',
    nom: 'UAM',
    sousTitre: 'Amadou Mahtar Mbow',
    imageUrl: AppImages.etudiantsDakar,
    nbFormations: 30,
  ),
];

final List<DashboardHousing> kMockHousing = [
  DashboardHousing(
    title: 'Cité des Étudiants Thiès',
    distance: '0.5 km du campus',
    prix: '45 000 FCFA',
    imageUrl: AppImages.logement1,
  ),
  DashboardHousing(
    title: 'Résidence Le Savoir',
    distance: '1.2 km du campus',
    prix: '35 000 FCFA',
    imageUrl: AppImages.logement2,
  ),
];
