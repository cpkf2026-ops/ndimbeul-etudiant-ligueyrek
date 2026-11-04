import 'package:flutter/foundation.dart' show kIsWeb;

/// Détermine si l'app doit utiliser les jeux de données mockés au lieu des
/// vrais endpoints. Bascule via `--dart-define=USE_MOCK=true|false`.
///
/// C'est le SEUL point de bascule mock/API réelle de toute l'application —
/// voir `core/di/providers_scope.dart` qui lit ce flag pour choisir quelle
/// implémentation de RemoteDataSource injecter dans chaque Repository.
///
/// Par défaut : la VRAIE API (Laravel + service IA). En mode démo (données
/// fictives), le chat renvoyait toujours la même phrase, quelle que soit la
/// question. Repasser en démo : `--dart-define=USE_MOCK=true`.
const bool kUseMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

/// Exception au mode démo : le fil d'actualités lit TOUJOURS la vraie API
/// (alimentée toutes les 2 h par la veille IA), même quand le reste de l'app
/// est mocké — l'endpoint `/news` est public, aucune connexion n'est requise.
/// Repasser en données fictives : `--dart-define=USE_MOCK_NEWS=true`.
const bool kUseMockNews = bool.fromEnvironment('USE_MOCK_NEWS', defaultValue: false);

/// Même exception pour les offres (Emploi & Stages) : liste et détail lisent la
/// vraie API (`/jobs` est public), alimentée toutes les 2 h par la veille IA.
/// Les favoris restent liés à un vrai compte (connexion API requise).
/// Repasser en données fictives : `--dart-define=USE_MOCK_JOBS=true`.
const bool kUseMockJobs = bool.fromEnvironment('USE_MOCK_JOBS', defaultValue: false);

/// Fréquence à laquelle les fils Actualités et Emploi & Stages se rechargent tout
/// seuls tant que l'app est ouverte. La veille IA côté serveur passe toutes les
/// 2 h : avec 15 min, une nouveauté apparaît au plus 15 min après son ajout.
const Duration kRafraichissementFils = Duration(minutes: 5);

abstract final class AppConstants {
  static const String appName = 'Ndimbeul-Etudiant';

  static const String _baseUrlDefini = String.fromEnvironment('API_BASE_URL');

  /// `--dart-define=API_BASE_URL=...` si fourni (APK pour un vrai téléphone : adresse du
  /// PC sur le Wi-Fi ou serveur en ligne) ; sinon, sur le web, la MÊME machine que celle
  /// qui sert la page (localhost sur le PC, 192.168.x.x depuis un téléphone sur le Wi-Fi),
  /// et `10.0.2.2` ailleurs (alias de la machine hôte depuis l'émulateur Android).
  ///
  /// Sur le web, l'application est servie par Laravel lui-même (`/app/`) : l'API est
  /// alors sur la MÊME origine (`/api/v1`), ce qui marche en local, sur le Wi-Fi et via
  /// un lien public (tunnel HTTPS). Seul l'ancien serveur de dev (port 8090) appelle le 8000.
  static String get baseUrl {
    if (_baseUrlDefini.isNotEmpty) return _baseUrlDefini;
    if (!kIsWeb) return 'http://10.0.2.2:8000/api/v1';
    if (Uri.base.port == 8090) return 'http://${Uri.base.host}:8000/api/v1';
    return '${Uri.base.origin}/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int defaultPageSize = 20;

  // Clés de stockage sécurisé
  static const String keyAccessToken = 'ndimbeul_access_token';
  static const String keyRefreshToken = 'ndimbeul_refresh_token';
  static const String keyUserRole = 'ndimbeul_user_role';
  // Dernier compte chargé, pour rester connecté après une actualisation de page
  // même si le serveur est lent ou injoignable à ce moment-là.
  static const String keyCachedUser = 'ndimbeul_utilisateur';

  // "Se souvenir de moi" — email pré-rempli au retour sur l'écran de connexion
  static const String keyRememberedEmail = 'ndimbeul_remembered_email';

  // Clés cache local (offline partiel)
  static const String cacheUniversities = 'cache_universities';
  static const String cacheJobs = 'cache_jobs';
  static const String cacheFavorites = 'cache_favorites';
}
