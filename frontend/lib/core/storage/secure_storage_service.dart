import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Wrapper de stockage des tokens de session.
///
/// Sur mobile/desktop : flutter_secure_storage (Keychain/Keystore natif).
/// Sur web : shared_preferences (localStorage). flutter_secure_storage web
/// chiffre via la Web Crypto API, mais le cycle écriture/lecture y échoue de
/// façon systématique sur certains navigateurs (DioException [unknown] /
/// "OperationError" dès qu'un token vient d'être écrit — le déchiffrement
/// échoue en le relisant juste après). Comme ce "chiffrement" web repose sur
/// une clé elle-même stockée dans le navigateur, il n'apporte de toute façon
/// pas de réelle protection supplémentaire par rapport à localStorage nu.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _storage.read(key: key);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _write(AppConstants.keyAccessToken, accessToken),
      _write(AppConstants.keyRefreshToken, refreshToken),
    ]);
  }

  Future<String?> get accessToken => _read(AppConstants.keyAccessToken);

  Future<String?> get refreshToken => _read(AppConstants.keyRefreshToken);

  Future<void> saveRole(String role) => _write(AppConstants.keyUserRole, role);

  Future<String?> get role => _read(AppConstants.keyUserRole);

  Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(AppConstants.keyAccessToken),
        prefs.remove(AppConstants.keyRefreshToken),
        prefs.remove(AppConstants.keyUserRole),
      ]);
      return;
    }
    await _storage.deleteAll();
  }

  Future<bool> get hasSession async => (await accessToken) != null;
}
