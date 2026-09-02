import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/admin_user_model.dart';

abstract interface class UserAdminRemoteDataSource {
  Future<List<AdminUserModel>> getUsers({
    String? role,
    String? statut,
    int page = 1,
    int perPage = 20,
  });

  Future<AdminUserModel> updateUserRole({
    required String id,
    required String role,
  });

  Future<void> suspendUser(String id);

  Future<void> reactivateUser(String id);

  Future<void> deleteUser(String id);
}

/// Implémentation réelle — appelle `/api/v1/admin/users*` sur Laravel.
class UserAdminRemoteDataSourceImpl implements UserAdminRemoteDataSource {
  UserAdminRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) return raw['data'] as List;
    return const [];
  }

  @override
  Future<List<AdminUserModel>> getUsers({
    String? role,
    String? statut,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.adminUsers,
        queryParameters: {
          if (role != null) 'role': role,
          if (statut != null) 'statut': statut,
          'per_page': perPage,
        },
      );
      final body = (response.data as Map<String, dynamic>)['data'];
      return _extractList(
        body,
      ).map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AdminUserModel> updateUserRole({
    required String id,
    required String role,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.adminUserRole(id),
        data: {'role': role},
      );
      return AdminUserModel.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> suspendUser(String id) async {
    try {
      await _dio.put(ApiEndpoints.adminUserSuspend(id));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> reactivateUser(String id) async {
    try {
      await _dio.put(ApiEndpoints.adminUserReactivate(id));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete(ApiEndpoints.adminUserDelete(id));
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
    if (e.response?.statusCode == 403) {
      return const UnauthorizedException(
        message: 'Action réservée au super administrateur.',
      );
    }
    return ServerException(
      message: e.response?.data?['message'] as String? ?? 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}
