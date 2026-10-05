import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profil_diplome_model.dart';
import '../models/profil_etudiant_model.dart';
import '../models/profil_lyceen_model.dart';

/// Enveloppe brute `{utilisateur: {role, profil: {...}}}` — le rôle
/// détermine quelle variante de profil est active (voir UtilisateurResource
/// côté backend, `profil` ∈ ProfilLyceenResource | ProfilEtudiantResource | ProfilDiplomeResource).
typedef ProfileEnvelope = ({String role, Map<String, dynamic> profil});

abstract interface class ProfileRemoteDataSource {
  Future<ProfileEnvelope> getProfile();

  Future<ProfilLyceenModel> updateProfilLyceen(ProfilLyceenModel profil);

  Future<ProfilEtudiantModel> updateProfilEtudiant(ProfilEtudiantModel profil);

  Future<ProfilDiplomeModel> updateProfilDiplome(ProfilDiplomeModel profil);
}

/// Implémentation réelle — appelle `/api/v1/profile/me` sur Laravel.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  // Le serveur de dev Laravel (PHP built-in, mono-thread sous Windows) peut mettre plus
  // de 15s/30s à répondre quand il est occupé par une autre requête (recommandations,
  // chat) — sans ce délai élargi, un enregistrement de profil échoue en timeout PENDANT
  // qu'un pic de charge est en cours, silencieusement pour l'utilisateur, qui croit ses
  // champs sauvegardés alors qu'ils ne le sont pas (voir recommendation_remote_datasource.dart
  // pour le même correctif appliqué en premier).
  static final _optionsTimeoutElargi = Options(
    connectTimeout: const Duration(minutes: 2),
    receiveTimeout: const Duration(minutes: 2),
  );

  @override
  Future<ProfileEnvelope> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profileMe, options: _optionsTimeoutElargi);
      final utilisateur =
          (response.data as Map<String, dynamic>)['utilisateur'] as Map<String, dynamic>;
      return (
        role: utilisateur['role'] as String,
        profil: (utilisateur['profil'] as Map<String, dynamic>?) ?? const {},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ProfilLyceenModel> updateProfilLyceen(ProfilLyceenModel profil) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.profileMe,
        data: profil.toUpdatePayload(),
        options: _optionsTimeoutElargi,
      );
      final utilisateur =
          (response.data as Map<String, dynamic>)['utilisateur'] as Map<String, dynamic>;
      return ProfilLyceenModel.fromJson(
        (utilisateur['profil'] as Map<String, dynamic>?) ?? const {},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ProfilEtudiantModel> updateProfilEtudiant(ProfilEtudiantModel profil) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.profileMe,
        data: profil.toUpdatePayload(),
        options: _optionsTimeoutElargi,
      );
      final utilisateur =
          (response.data as Map<String, dynamic>)['utilisateur'] as Map<String, dynamic>;
      return ProfilEtudiantModel.fromJson(
        (utilisateur['profil'] as Map<String, dynamic>?) ?? const {},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ProfilDiplomeModel> updateProfilDiplome(ProfilDiplomeModel profil) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.profileMe,
        data: profil.toUpdatePayload(),
        options: _optionsTimeoutElargi,
      );
      final utilisateur =
          (response.data as Map<String, dynamic>)['utilisateur'] as Map<String, dynamic>;
      return ProfilDiplomeModel.fromJson(
        (utilisateur['profil'] as Map<String, dynamic>?) ?? const {},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }
    if (e.response?.statusCode == 401) return const UnauthorizedException();
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
