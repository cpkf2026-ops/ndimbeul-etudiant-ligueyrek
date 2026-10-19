/// Constantes des chemins de navigation go_router.
abstract final class RoutePaths {
  // Écran d'accueil (splash, ~30s au lancement — voir SplashScreen)
  static const String splash = '/splash';

  // Public
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Complétion de profil obligatoire (connecté, mais profilComplete == false)
  static const String completeProfile = '/complete-profile';

  // Shell principal (bottom nav / sidebar)
  static const String dashboard = '/dashboard';

  // Fenêtre "Connexion requise" — ouverte par-dessus l'accueil quand un
  // visiteur non connecté touche une fonctionnalité réservée.
  static const String authRequired = '/dashboard/connexion-requise';
  static const String orientation = '/orientation';
  static const String profile = '/profile';

  // Universities
  static const String universities = '/universities';
  static const String universityDetail = '/universities/:id';
  static const String universitiesCompare = '/universities/compare';
  static String universityDetailPath(String id) => '/universities/$id';

  // Orientation
  static const String orientationRecommendations =
      '/orientation/recommendations';
  static const String orientationSimulation = '/orientation/simulation';

  // Chat / IA
  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';

  // Jobs
  static const String jobs = '/jobs';
  static const String jobDetail = '/jobs/:id';
  static const String jobsFavorites = '/jobs/favorites';
  static String jobDetailPath(String id) => '/jobs/$id';

  // News
  static const String news = '/news';

  // Admin
  static const String admin = '/admin';
  static const String adminSources = '/admin/sources';
  static const String adminUsers = '/admin/users';
  static const String adminNews = '/admin/news';
  // Ajout assisté par l'IA (sous /admin : protégé par la garde des administrateurs).
  static const String adminAjoutEtablissement = '/admin/ajout/etablissement';
  static const String adminAjoutActualite = '/admin/ajout/actualite';
  static const String adminAjoutOffre = '/admin/ajout/offre';
}
