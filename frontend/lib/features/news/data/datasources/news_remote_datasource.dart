import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/actualite.dart';
import '../models/actualite_model.dart';

typedef ActualitePageModel = ({
  List<ActualiteModel> items,
  int currentPage,
  int lastPage,
  int total,
});

abstract interface class NewsRemoteDataSource {
  Future<ActualitePageModel> getActualites({
    CategorieActualite? categorie,
    int page = 1,
    int perPage = 10,
  });

  Future<ActualiteModel> getActualiteDetail(String id);
}

/// Implémentation réelle — appelle `/api/v1/news*` sur Laravel.
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  NewsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<ActualitePageModel> getActualites({
    CategorieActualite? categorie,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.news,
        queryParameters: {
          if (categorie != null) 'categorie': categorie.name,
          'page': page,
          'per_page': perPage,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final items = (body['data'] as List)
          .map((e) => ActualiteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = body['meta'] as Map<String, dynamic>? ?? const {};
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
  Future<ActualiteModel> getActualiteDetail(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.newsDetail(id));
      return ActualiteModel.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
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
    return ServerException(
      message: e.response?.data?['message'] as String? ?? 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}
