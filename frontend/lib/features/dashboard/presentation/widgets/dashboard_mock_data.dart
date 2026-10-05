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
    title: 'Studio Fann Résidence',
    distance: "300 m de l'UCAD",
    prix: '60 000 FCFA',
    imageUrl: AppImages.logement3,
  ),
  DashboardHousing(
    title: 'Chambre partagée Sanar',
    distance: "0.8 km de l'UGB",
    prix: '25 000 FCFA',
    imageUrl: AppImages.logement4,
  ),
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

/// Échéance du calendrier académique — [daysFromNow] garde la démo à jour
/// quelle que soit la date du jour.
class DashboardKeyDate {
  const DashboardKeyDate({
    required this.title,
    required this.place,
    required this.daysFromNow,
    required this.kind,
  });
  final String title;
  final String place;
  final int daysFromNow;
  final String kind;

  DateTime get date => DateTime.now().add(Duration(days: daysFromNow));
}

const List<DashboardKeyDate> kKeyDates = [
  DashboardKeyDate(
    title: 'Clôture des inscriptions CAMPUSEN',
    place: "Plateforme nationale d'orientation",
    daysFromNow: 4,
    kind: 'Inscriptions',
  ),
  DashboardKeyDate(
    title: "Dépôt des dossiers de bourses d'excellence",
    place: 'Direction des Bourses — Dakar',
    daysFromNow: 11,
    kind: 'Bourses',
  ),
  DashboardKeyDate(
    title: "Concours d'entrée en classes préparatoires",
    place: 'ESP — Dakar',
    daysFromNow: 19,
    kind: 'Concours',
  ),
  DashboardKeyDate(
    title: "Salon de l'orientation et des métiers",
    place: 'CICES — Dakar',
    daysFromNow: 33,
    kind: 'Événement',
  ),
];

/// Filière porteuse (débouchés au Sénégal) avec tendance de la demande.
class DashboardTrendingField {
  const DashboardTrendingField({
    required this.name,
    required this.growth,
    required this.debouches,
  });
  final String name;
  final int growth;
  final String debouches;
}

const List<DashboardTrendingField> kTrendingFields = [
  DashboardTrendingField(
    name: 'Informatique & IA',
    growth: 38,
    debouches: 'Développeur, data analyst',
  ),
  DashboardTrendingField(
    name: 'Pétrole, gaz & énergie',
    growth: 31,
    debouches: 'Ingénieur procédés, HSE',
  ),
  DashboardTrendingField(
    name: 'Santé & médecine',
    growth: 24,
    debouches: 'Médecin, infirmier, pharmacien',
  ),
  DashboardTrendingField(
    name: 'Agronomie & agro-industrie',
    growth: 21,
    debouches: 'Ingénieur agronome',
  ),
  DashboardTrendingField(
    name: 'BTP & génie civil',
    growth: 18,
    debouches: 'Conducteur de travaux',
  ),
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
