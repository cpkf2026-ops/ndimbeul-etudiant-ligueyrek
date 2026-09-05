import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  /// Inscription minimale : identité + mot de passe. Le statut (lycéen,
  /// étudiant, diplômé…) est choisi séparément via [completeProfile], voir
  /// CompleteProfileScreen.
  Future<UserModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  });

  /// `POST /profile/complete` — fixe le statut de l'utilisateur et enregistre
  /// les champs spécifiques à ce statut ; passe `profilComplete` à true.
  Future<UserModel> completeProfile({
    required UserRole statut,
    required Map<String, dynamic> fields,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<void> forgotPassword({required String email});
}

/// Implémentation réelle — appelle `/api/v1/auth/*` sur Laravel.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required Dio dio, required SecureStorageService storage})
      : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final SecureStorageService _storage;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Laravel Sanctum (pas de vrai JWT) : champ `mot_de_passe` (nommage FR du
      // CDC), enveloppe de réponse `utilisateur`, un seul token opaque sans
      // expiration (config/sanctum.php `expiration => null`) — voir _storage.saveTokens.
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'mot_de_passe': password},
      );
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      await _storage.saveTokens(accessToken: accessToken, refreshToken: accessToken);
      final user = UserModel.fromJson(data['utilisateur'] as Map<String, dynamic>);
      if (user.role != null) await _storage.saveRole(user.role!.name);
      return user;
    } on DioException catch (e) {
      // Laravel renvoie volontairement un 401 générique ("Identifiants
      // incorrects.") sans distinguer email inconnu / mot de passe erroné
      // (bonne pratique anti-énumération de comptes) — on ne peut donc pas
      // reproduire ici la distinction faite en mode mock (qui, lui, connaît
      // la liste des comptes). Par défaut, tout refus de connexion oriente
      // vers l'inscription plutôt que d'afficher une erreur bloquante.
      if (e.response?.statusCode == 401) {
        throw const AccountNotFoundException();
      }
      throw _mapError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'mot_de_passe': password,
          'mot_de_passe_confirmation': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      await _storage.saveTokens(accessToken: accessToken, refreshToken: accessToken);
      return UserModel.fromJson(data['utilisateur'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<UserModel> completeProfile({
    required UserRole statut,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.profileComplete,
        data: {'statut': _statutToJson(statut), ...fields},
      );
      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['utilisateur'] as Map<String, dynamic>);
      if (user.role != null) await _storage.saveRole(user.role!.name);
      return user;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException {
      // best-effort : on efface la session locale même si l'appel échoue
    } finally {
      await _storage.clear();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final hasSession = await _storage.hasSession;
    if (!hasSession) return null;
    try {
      final response = await _dio.get(ApiEndpoints.profileMe);
      return UserModel.fromJson(
        (response.data as Map<String, dynamic>)['utilisateur']
            as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  String _statutToJson(UserRole statut) => switch (statut) {
        UserRole.lyceen => 'lyceen',
        UserRole.etudiant => 'etudiant',
        UserRole.diplome => 'diplome',
        UserRole.adminEtablissement => 'admin_etablissement',
        UserRole.superAdmin => 'super_admin',
      };

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }
    if (e.response?.statusCode == 401) {
      return const UnauthorizedException();
    }
    if (e.response?.statusCode == 422) {
      final errors = (e.response?.data?['errors'] as Map?)?.map(
        (k, v) => MapEntry(k as String, List<String>.from(v as List)),
      );
      return ValidationException(
        message: e.response?.data?['message'] as String? ?? 'Données invalides',
        errors: errors,
      );
    }
    return ServerException(
      message: e.response?.data?['message'] as String? ?? 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}
