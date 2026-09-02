import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/app_notification_model.dart';

typedef NotificationPageModel = ({
  List<AppNotificationModel> items,
  int nbNonLues,
  int currentPage,
  int lastPage,
});

abstract interface class NotificationRemoteDataSource {
  Future<NotificationPageModel> getNotifications({
    bool nonLuesSeulement = false,
    int page = 1,
    int perPage = 20,
  });

  Future<void> markAllRead();

  Future<void> markRead(String id);
}

/// Implémentation réelle — appelle `/api/v1/notifications*` sur Laravel.
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<NotificationPageModel> getNotifications({
    bool nonLuesSeulement = false,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: {
          if (nonLuesSeulement) 'non_lues': true,
          'page': page,
          'per_page': perPage,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final items = (body['data'] as List)
          .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = body['meta'] as Map<String, dynamic>? ?? const {};
      return (
        items: items,
        nbNonLues: meta['nb_non_lues'] as int? ?? items.where((n) => n.readAt == null).length,
        currentPage: meta['current_page'] as int? ?? page,
        lastPage: meta['last_page'] as int? ?? page,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _dio.put(ApiEndpoints.notificationsReadAll);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _dio.put(ApiEndpoints.notificationRead(id));
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
