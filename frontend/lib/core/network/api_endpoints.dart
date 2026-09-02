/// Constantes des routes API Laravel — reflète exactement `backend/routes/api.php`.
/// Base URL définie dans [AppConstants.baseUrl]. Fichier centralisé et
/// partagé par toutes les features : ne pas dupliquer ces constantes ailleurs.
abstract final class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Profile
  static const String profileMe = '/profile/me';

  // Universities
  static const String universities = '/universities';
  static const String universitiesCompare = '/universities/compare';
  static const String universitiesHistory = '/universities/history';
  static String universityDetail(String id) => '/universities/$id';
  static String universityTrack(String id) => '/universities/$id/track';

  // Formations
  static const String formations = '/formations';
  static const String formationsCompare = '/formations/compare';
  static const String formationsFavorites = '/formations/favorites';
  static String formationDetail(String id) => '/formations/$id';
  static String formationFavorite(String id) => '/formations/$id/favorite';

  // Jobs
  static const String jobs = '/jobs';
  static const String jobsFavorites = '/jobs/favorites';
  static String jobDetail(String id) => '/jobs/$id';
  static String jobFavorite(String id) => '/jobs/$id/favorite';

  // News
  static const String news = '/news';
  static String newsDetail(String id) => '/news/$id';

  // Alerts / notifications
  static const String alerts = '/alerts';
  static String alertDetail(String id) => '/alerts/$id';
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // AI
  static const String aiChat = '/ai/chat';
  static const String aiRecommendations = '/ai/recommendations';
  static const String aiConversations = '/ai/conversations';
  static String aiConversation(String id) => '/ai/conversations/$id';

  // Admin — établissement (admin_etablissement | super_admin)
  static const String adminUniversities = '/admin/universities';
  static String adminUniversityDetail(String id) => '/admin/universities/$id';
  static String adminUniversityFormations(String universiteId) =>
      '/admin/universities/$universiteId/formations';
  static String adminFormationDetail(String id) => '/admin/formations/$id';
  static String adminUniversityBourses(String universiteId) =>
      '/admin/universities/$universiteId/bourses';
  static String adminBourseDetail(String id) => '/admin/bourses/$id';
  static String adminUniversityLogements(String universiteId) =>
      '/admin/universities/$universiteId/logements';
  static String adminLogementDetail(String id) => '/admin/logements/$id';
  static String adminUniversityFrais(String universiteId) =>
      '/admin/universities/$universiteId/frais';
  static String adminFraisDetail(String id) => '/admin/frais/$id';
  static const String adminSources = '/admin/sources';
  static String adminSourceDetail(String id) => '/admin/sources/$id';
  static const String adminDocumentsUpload = '/admin/documents/upload';

  // Admin — plateforme (super_admin uniquement)
  static const String adminUsers = '/admin/users';
  static String adminUserRole(String id) => '/admin/users/$id/role';
  static String adminUserSuspend(String id) => '/admin/users/$id/suspend';
  static String adminUserReactivate(String id) => '/admin/users/$id/reactivate';
  static String adminUserDelete(String id) => '/admin/users/$id';
  static const String adminQuality = '/admin/quality';
}
