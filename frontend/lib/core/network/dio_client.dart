import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Fabrique l'instance Dio principale de l'app (JWT auto-attach + refresh
/// transparent) et une instance "nue" réservée au refresh lui-même, pour
/// éviter toute boucle d'intercepteurs.
class DioClient {
  DioClient({required SecureStorageService storage}) {
    _refreshDio = Dio(_baseOptions);

    dio = Dio(_baseOptions);
    dio.interceptors.add(
      AuthInterceptor(storage: storage, refreshDio: _refreshDio),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),
      );
    }
  }

  late final Dio dio;
  late final Dio _refreshDio;

  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: const {'Accept': 'application/json'},
      );
}
