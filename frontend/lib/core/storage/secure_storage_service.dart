import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'session_onglet.dart';

/// Wrapper de stockage des tokens de session.
///
/// Sur mobile/desktop : flutter_secure_storage (Keychain/Keystore natif).
/// Sur web : sessionStorage (le temps de l'onglet, voir _write). flutter_secure_storage web
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

  static const _clesSession = [
    AppConstants.keyAccessToken,
    AppConstants.keyRefreshToken,
    AppConstants.keyUserRole,
    AppConstants.keyCachedUser,
  ];
  static bool _ancienneSessionPurgee = false;

  /// Web : la session vit le temps de l'ONGLET (sessionStorage). Une actualisation
  /// garde la connexion ; rouvrir le lien (ou un nouvel onglet) repart du splash puis
  /// de l'écran de connexion, comme sur le PC. Les anciennes versions gardaient la
  /// session pour toujours dans localStorage : on l'efface une fois.
  Future<void> _purgerAncienneSessionWeb() async {
    if (_ancienneSessionPurgee) return;
    _ancienneSessionPurgee = true;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([for (final cle in _clesSession) prefs.remove(cle)]);
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      await _purgerAncienneSessionWeb();
      ecrireSessionOnglet(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      await _purgerAncienneSessionWeb();
      return lireSessionOnglet(key);
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

  /// Dernier compte connu (JSON), relu quand le serveur ne répond pas à temps lors
  /// d'une actualisation de page : la session reste ouverte au lieu d'être perdue.
  Future<void> saveCachedUser(String json) => _write(AppConstants.keyCachedUser, json);

  Future<String?> get cachedUser => _read(AppConstants.keyCachedUser);

  Future<void> clear() async {
    if (kIsWeb) {
      await _purgerAncienneSessionWeb();
      for (final cle in _clesSession) {
        supprimerSessionOnglet(cle);
      }
      return;
    }
    await _storage.deleteAll();
  }

  Future<bool> get hasSession async => (await accessToken) != null;
}
