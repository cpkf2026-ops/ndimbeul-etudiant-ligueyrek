import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/source_donnee_model.dart';

abstract interface class SourceRemoteDataSource {
  Future<List<SourceDonneeModel>> getSources();

  Future<SourceDonneeModel> createSource({
    String? universiteId,
    required String type,
    required String urlOuChemin,
    String? categorie,
  });

  Future<SourceDonneeModel> updateSource({
    required String id,
    String? universiteId,
    required String type,
    required String urlOuChemin,
    String? categorie,
  });

  Future<void> deleteSource(String id);

  Future<Map<String, dynamic>> uploadDocument({
    required Uint8List bytes,
    required String filename,
    String? sourceId,
    String? universiteId,
    String? categorie,
  });
}

/// Implémentation réelle — appelle `/api/v1/admin/sources*` sur Laravel.
/// `data['data']` peut être doublement enveloppé si le contrôleur sérialise
/// un paginator brut (`{data: {data: [...], meta, links}}`) — on déballe
/// défensivement les deux formes.
class SourceRemoteDataSourceImpl implements SourceRemoteDataSource {
  SourceRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) return raw['data'] as List;
    return const [];
  }

  @override
  Future<List<SourceDonneeModel>> getSources() async {
    try {
      final response = await _dio.get(ApiEndpoints.adminSources);
      final body = (response.data as Map<String, dynamic>)['data'];
      return _extractList(body)
          .map((e) => SourceDonneeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<SourceDonneeModel> createSource({
    String? universiteId,
    required String type,
    required String urlOuChemin,
    String? categorie,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.adminSources,
        data: {
          'universite_id': universiteId,
          'type': type,
          'url_ou_chemin': urlOuChemin,
          'categorie': categorie,
        },
      );
      return SourceDonneeModel.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<SourceDonneeModel> updateSource({
    required String id,
    String? universiteId,
    required String type,
    required String urlOuChemin,
    String? categorie,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.adminSourceDetail(id),
        data: {
          'universite_id': universiteId,
          'type': type,
          'url_ou_chemin': urlOuChemin,
          'categorie': categorie,
        },
      );
      return SourceDonneeModel.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteSource(String id) async {
    try {
      await _dio.delete(ApiEndpoints.adminSourceDetail(id));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> uploadDocument({
    required Uint8List bytes,
    required String filename,
    String? sourceId,
    String? universiteId,
    String? categorie,
  }) async {
    try {
      final formData = FormData.fromMap({
        'document': MultipartFile.fromBytes(bytes, filename: filename),
        if (sourceId != null) 'source_id': sourceId,
        if (universiteId != null) 'universite_id': universiteId,
        if (categorie != null) 'categorie': categorie,
      });
      final response = await _dio.post(
        ApiEndpoints.adminDocumentsUpload,
        data: formData,
      );
      return (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>? ??
          const {};
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
