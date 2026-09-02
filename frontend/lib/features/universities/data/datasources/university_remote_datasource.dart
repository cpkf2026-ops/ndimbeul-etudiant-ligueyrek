import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/universite_model.dart';

abstract interface class UniversityRemoteDataSource {
  Future<PaginatedResult<UniversiteModel>> getUniversities({
    String? region,
    String? type,
    String? q,
    int page = 1,
    int perPage = 20,
  });

  Future<UniversiteModel> getUniversityDetail(String id);

  Future<List<UniversiteModel>> compareUniversities(List<String> ids);

  Future<List<UniversiteModel>> getUniversitiesHistory();

  Future<void> trackUniversity({required String id, required String statut});
}

/// Implémentation réelle — appelle `/api/v1/universities*` sur Laravel.
class UniversityRemoteDataSourceImpl implements UniversityRemoteDataSource {
  UniversityRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<PaginatedResult<UniversiteModel>> getUniversities({
    String? region,
    String? type,
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.universities,
        queryParameters: {
          if (region != null) 'region': region,
          if (type != null) 'type': type,
          if (q != null) 'q': q,
          'page': page,
          'per_page': perPage,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final items = (body['data'] as List)
          .map((e) => UniversiteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = body['meta'] as Map<String, dynamic>;
      return PaginatedResult(
        items: items,
        currentPage: meta['current_page'] as int,
        lastPage: meta['last_page'] as int,
        total: meta['total'] as int,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<UniversiteModel> getUniversityDetail(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.universityDetail(id));
      return UniversiteModel.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<UniversiteModel>> compareUniversities(List<String> ids) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.universitiesCompare,
        queryParameters: {'ids': ids.join(',')},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data.map((e) => UniversiteModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<UniversiteModel>> getUniversitiesHistory() async {
    try {
      final response = await _dio.get(ApiEndpoints.universitiesHistory);
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      // Endpoint historique : sérialisation brute Eloquent (colonnes snake_case
      // à plat), différente de UniversiteResource (pas de wrapper `contact`,
      // pas de formations/bourses/logements chargés). On lit la relation
      // imbriquée `universite` telle quelle ; les champs contact restent
      // alors à null (dégradation gracieuse, cf. rapport de fin de tâche).
      return data
          .map((e) => (e as Map<String, dynamic>)['universite'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .map(UniversiteModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> trackUniversity({required String id, required String statut}) async {
    try {
      await _dio.post(ApiEndpoints.universityTrack(id), data: {'statut': statut});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

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
