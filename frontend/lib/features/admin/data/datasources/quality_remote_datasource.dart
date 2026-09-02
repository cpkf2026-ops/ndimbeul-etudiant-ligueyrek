import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/quality_metrics_model.dart';

abstract interface class QualityRemoteDataSource {
  Future<QualityMetricsModel> getQualityMetrics();
}

/// Implémentation réelle — appelle `/api/v1/admin/quality` sur Laravel.
class QualityRemoteDataSourceImpl implements QualityRemoteDataSource {
  QualityRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<QualityMetricsModel> getQualityMetrics() async {
    try {
      final response = await _dio.get(ApiEndpoints.adminQuality);
      return QualityMetricsModel.fromJson(
        response.data as Map<String, dynamic>,
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
