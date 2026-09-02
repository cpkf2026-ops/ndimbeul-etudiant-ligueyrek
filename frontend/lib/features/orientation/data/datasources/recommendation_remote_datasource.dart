import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/recommandation_model.dart';

abstract interface class RecommendationRemoteDataSource {
  Future<List<RecommandationModel>> getRecommendations();
}

/// Implémentation réelle — appelle `/api/v1/ai/recommendations` sur Laravel.
class RecommendationRemoteDataSourceImpl implements RecommendationRemoteDataSource {
  RecommendationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<RecommandationModel>> getRecommendations() async {
    try {
      final response = await _dio.get(ApiEndpoints.aiRecommendations);
      final data = response.data;
      final list = data is Map<String, dynamic> ? data['data'] ?? data['recommendations'] : data;
      if (list is! List) return const [];
      return list.map((e) => RecommandationModel.fromJson(e as Map<String, dynamic>)).toList();
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
      return ValidationException(
        message: e.response?.data?['message'] as String? ??
            'Complétez votre profil pour obtenir des suggestions personnalisées.',
      );
    }
    if (e.response?.statusCode == 502) {
      return const ServerException(
        message: 'Le service de recommandation est momentanément indisponible.',
      );
    }
    return ServerException(
      message: e.response?.data?['message'] as String? ?? 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}
