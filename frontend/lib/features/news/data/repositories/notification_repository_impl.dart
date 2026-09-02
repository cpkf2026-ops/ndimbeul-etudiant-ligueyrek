import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required NotificationRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<NotificationPage>> getNotifications({
    bool nonLuesSeulement = false,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final page_ = await _remoteDataSource.getNotifications(
        nonLuesSeulement: nonLuesSeulement,
        page: page,
        perPage: perPage,
      );
      return Right(
        NotificationPage(
          items: page_.items.map((e) => e.toEntity()).toList(),
          nbNonLues: page_.nbNonLues,
          currentPage: page_.currentPage,
          lastPage: page_.lastPage,
        ),
      );
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> markAllRead() async {
    try {
      await _remoteDataSource.markAllRead();
      return const Right(null);
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> markRead(String id) async {
    try {
      await _remoteDataSource.markRead(id);
      return const Right(null);
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }
}
