import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/offre_emploi.dart';
import '../models/offre_emploi_model.dart';

/// Page brute d'offres — items + métadonnées de pagination Laravel, avant
/// mapping vers l'entité `JobPage` du domain.
typedef JobListPageModel = ({
  List<OffreEmploiModel> items,
  int currentPage,
  int lastPage,
  int total,
});

abstract interface class JobRemoteDataSource {
  Future<JobListPageModel> list({
    String? domaine,
    String? region,
    JobType? type,
    String? niveauRequis,
    DateTime? dateLimiteAvant,
    int page = 1,
    int perPage = 20,
  });

  Future<OffreEmploiModel> detail(String id);

  Future<List<OffreEmploiModel>> favorites();

  Future<void> favorite(String id);

  Future<void> unfavorite(String id);
}

/// Implémentation réelle — appelle `/api/v1/jobs*` sur Laravel.
class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  JobRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<JobListPageModel> list({
    String? domaine,
    String? region,
    JobType? type,
    String? niveauRequis,
    DateTime? dateLimiteAvant,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.jobs,
        queryParameters: {
          if (domaine != null) 'domaine': domaine,
          if (region != null) 'region': region,
          if (type != null) 'type': type.name,
          if (niveauRequis != null) 'niveau_requis': niveauRequis,
          if (dateLimiteAvant != null)
            'date_limite_avant': DateFormat('yyyy-MM-dd').format(dateLimiteAvant),
          'page': page,
          'per_page': perPage,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List)
          .map((e) => OffreEmploiModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = data['meta'] as Map<String, dynamic>? ?? const {};
      return (
        items: items,
        currentPage: meta['current_page'] as int? ?? page,
        lastPage: meta['last_page'] as int? ?? page,
        total: meta['total'] as int? ?? items.length,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<OffreEmploiModel> detail(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.jobDetail(id));
      return OffreEmploiModel.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<OffreEmploiModel>> favorites() async {
    try {
      final response = await _dio.get(ApiEndpoints.jobsFavorites);
      return ((response.data as Map<String, dynamic>)['data'] as List)
          .map((e) => OffreEmploiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> favorite(String id) async {
    try {
      await _dio.post(ApiEndpoints.jobFavorite(id));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> unfavorite(String id) async {
    try {
      await _dio.delete(ApiEndpoints.jobFavorite(id));
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
