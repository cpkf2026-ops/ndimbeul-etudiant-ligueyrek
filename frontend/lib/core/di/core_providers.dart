import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage_service.dart';

/// `true` si l'app doit utiliser les jeux de données mockés au lieu des
/// vrais endpoints Laravel — seul point de bascule mock/API réelle,
/// lu par chaque provider de RemoteDataSource des features.
final useMockProvider = Provider<bool>((ref) => kUseMock);

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage: storage).dio;
});

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());
