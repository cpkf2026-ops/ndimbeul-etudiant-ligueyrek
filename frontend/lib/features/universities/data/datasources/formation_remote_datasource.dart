import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/formation_model.dart';

abstract interface class FormationRemoteDataSource {
  Future<PaginatedResult<FormationModel>> getFormations({
    String? domaine,
    String? niveau,
    String? region,
    String? typeEtablissement,
    String? serieBac,
    String? universiteId,
    int page = 1,
    int perPage = 20,
  });

  Future<List<FormationModel>> compareFormations(List<String> ids);

  Future<List<FormationModel>> getFavoriteFormations();

  Future<void> favoriteFormation(String id);

  Future<void> unfavoriteFormation(String id);
}

/// Implémentation réelle — appelle `/api/v1/formations*` sur Laravel.
class FormationRemoteDataSourceImpl implements FormationRemoteDataSource {
  FormationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<PaginatedResult<FormationModel>> getFormations({
    String? domaine,
    String? niveau,
    String? region,
    String? typeEtablissement,
    String? serieBac,
    String? universiteId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.formations,
        queryParameters: {
          if (domaine != null) 'domaine': domaine,
          if (niveau != null) 'niveau': niveau,
          if (region != null) 'region': region,
          if (typeEtablissement != null) 'type_etablissement': typeEtablissement,
          if (serieBac != null) 'serie_bac': serieBac,
          if (universiteId != null) 'universite_id': universiteId,
          'page': page,
          'per_page': perPage,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final items = (body['data'] as List)
          .map((e) => FormationModel.fromJson(e as Map<String, dynamic>))
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
  Future<List<FormationModel>> compareFormations(List<String> ids) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.formationsCompare,
        queryParameters: {'ids': ids.join(',')},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data.map((e) => FormationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<FormationModel>> getFavoriteFormations() async {
    try {
      final response = await _dio.get(ApiEndpoints.formationsFavorites);
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data.map((e) => FormationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> favoriteFormation(String id) async {
    try {
      await _dio.post(ApiEndpoints.formationFavorite(id));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> unfavoriteFormation(String id) async {
    try {
      await _dio.delete(ApiEndpoints.formationFavorite(id));
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
