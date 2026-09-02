import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/actualite_admin_model.dart';

/// Aucun endpoint d'écriture n'existe côté backend pour les actualités —
/// lecture seule via `GET /api/v1/news`, réutilisé ici tel quel (voir
/// `AdminNewsRepository` et `AdminNewsScreen`).
abstract interface class AdminNewsRemoteDataSource {
  Future<List<ActualiteAdminModel>> getNews();
}

class AdminNewsRemoteDataSourceImpl implements AdminNewsRemoteDataSource {
  AdminNewsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<ActualiteAdminModel>> getNews() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.news,
        queryParameters: {'per_page': 50},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data
          .map((e) => ActualiteAdminModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }
    return ServerException(
      message: e.response?.data?['message'] as String? ?? 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}
