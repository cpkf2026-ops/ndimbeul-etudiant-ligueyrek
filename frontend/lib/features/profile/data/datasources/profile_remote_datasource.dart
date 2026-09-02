import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profil_etudiant_model.dart';
import '../models/profil_lyceen_model.dart';

/// Enveloppe brute `{utilisateur: {role, profil: {...}}}` — le rôle
/// détermine quelle variante de profil est active (voir UtilisateurResource
/// côté backend, `profil` ∈ ProfilLyceenResource | ProfilEtudiantResource).
typedef ProfileEnvelope = ({String role, Map<String, dynamic> profil});

abstract interface class ProfileRemoteDataSource {
  Future<ProfileEnvelope> getProfile();

  Future<ProfilLyceenModel> updateProfilLyceen(ProfilLyceenModel profil);

  Future<ProfilEtudiantModel> updateProfilEtudiant(ProfilEtudiantModel profil);
}

/// Implémentation réelle — appelle `/api/v1/profile/me` sur Laravel.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<ProfileEnvelope> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profileMe);
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
      final response = await _dio.put(ApiEndpoints.profileMe, data: profil.toUpdatePayload());
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
      final response = await _dio.put(ApiEndpoints.profileMe, data: profil.toUpdatePayload());
      final utilisateur =
          (response.data as Map<String, dynamic>)['utilisateur'] as Map<String, dynamic>;
      return ProfilEtudiantModel.fromJson(
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
