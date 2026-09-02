import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

/// Attache automatiquement le token Sanctum à chaque requête.
///
/// NOTE : ce backend utilise Laravel Sanctum avec des tokens opaques SANS
/// expiration (`config/sanctum.php` -> `'expiration' => null`), pas un
/// vrai JWT à courte durée de vie. `/auth/refresh` révoque le token courant
/// et en émet un nouveau, mais exige déjà un Bearer valide — il ne peut donc
/// pas servir à "rattraper" un 401 (le token qui a expiré/été révoqué est
/// justement celui qu'il faudrait présenter). Un 401 signifie ici que la
/// session est réellement invalide : on efface la session locale et on
/// laisse l'erreur remonter en [Failure.unauthorized] pour que l'UI
/// redirige vers l'écran de connexion, sans tentative de refresh silencieux.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService storage,
    required Dio refreshDio,
  })  : _storage = storage,
        _refreshDio = refreshDio;

  final SecureStorageService _storage;
  // Conservé pour un futur usage (rotation proactive de token), volontairement
  // non utilisé dans le flux d'erreur — voir note de classe ci-dessus.
  // ignore: unused_field
  final Dio _refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.accessToken;
    if (token != null && !options.path.contains(ApiEndpoints.login)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.clear();
    }
    handler.next(err);
  }
}
