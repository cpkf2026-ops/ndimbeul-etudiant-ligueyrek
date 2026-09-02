/// Détermine si l'app doit utiliser les jeux de données mockés au lieu des
/// vrais endpoints. Bascule via `--dart-define=USE_MOCK=true|false`.
///
/// C'est le SEUL point de bascule mock/API réelle de toute l'application —
/// voir `core/di/providers_scope.dart` qui lit ce flag pour choisir quelle
/// implémentation de RemoteDataSource injecter dans chaque Repository.
const bool kUseMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

abstract final class AppConstants {
  static const String appName = 'Ndimbeul-Etudiant';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int defaultPageSize = 20;

  // Clés de stockage sécurisé
  static const String keyAccessToken = 'ndimbeul_access_token';
  static const String keyRefreshToken = 'ndimbeul_refresh_token';
  static const String keyUserRole = 'ndimbeul_user_role';

  // "Se souvenir de moi" — email pré-rempli au retour sur l'écran de connexion
  static const String keyRememberedEmail = 'ndimbeul_remembered_email';

  // Clés cache local (offline partiel)
  static const String cacheUniversities = 'cache_universities';
  static const String cacheJobs = 'cache_jobs';
  static const String cacheFavorites = 'cache_favorites';
}
