import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Wrapper autour de flutter_secure_storage. Les tokens JWT ne transitent
/// JAMAIS par shared_preferences en clair — uniquement par ce service.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken, value: accessToken),
      _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> get accessToken =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> get refreshToken =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> saveRole(String role) =>
      _storage.write(key: AppConstants.keyUserRole, value: role);

  Future<String?> get role => _storage.read(key: AppConstants.keyUserRole);

  Future<void> clear() => _storage.deleteAll();

  Future<bool> get hasSession async => (await accessToken) != null;
}
