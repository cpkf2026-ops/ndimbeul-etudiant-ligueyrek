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

// -----------------------------------------------------------------------------
// Contenus de démonstration supplémentaires de l'Accueil — à remplacer par
// les données réelles du backend (calendrier, statistiques, avis).
// -----------------------------------------------------------------------------

/// Chiffre clé de la plateforme (bandeau animé sous le hero).
class DashboardKeyFigure {
  const DashboardKeyFigure({
    required this.value,
    required this.suffix,
    required this.label,
  });
  final int value;
  final String suffix;
  final String label;
}

const List<DashboardKeyFigure> kKeyFigures = [
  DashboardKeyFigure(value: 50, suffix: '+', label: 'Établissements'),
  DashboardKeyFigure(value: 1200, suffix: '+', label: 'Formations'),
  DashboardKeyFigure(value: 14, suffix: '', label: 'Régions couvertes'),
  DashboardKeyFigure(value: 24, suffix: '/7', label: 'Assistant IA'),
];

/// Avis d'utilisateur (contenu d'illustration).
class DashboardTestimonial {
  const DashboardTestimonial({
    required this.name,
    required this.profile,
    required this.quote,
  });
  final String name;
  final String profile;
  final String quote;
}

const List<DashboardTestimonial> kTestimonials = [
  DashboardTestimonial(
    name: 'Awa D.',
    profile: 'Bachelière S2 — Thiès',
    quote:
        "La simulation du bac m'a montré les filières accessibles avec ma moyenne. "
        "J'ai trouvé ma licence en informatique en quelques minutes.",
  ),
  DashboardTestimonial(
    name: 'Moussa N.',
    profile: 'Étudiant en L3 — UGB',
    quote:
        "Grâce aux alertes, je n'ai raté aucune bourse cette année. "
        "L'assistant IA répond même à 2h du matin !",
  ),
  DashboardTestimonial(
    name: 'Fatou S.',
    profile: 'Diplômée — Dakar',
    quote:
        "J'ai décroché mon premier stage via les offres de la plateforme. "
        "Tout est centralisé, c'est un vrai gain de temps.",
  ),
];
