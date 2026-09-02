import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/quality_metrics.dart';
import '../../domain/repositories/quality_repository.dart';
import '../datasources/quality_remote_datasource.dart';

class QualityRepositoryImpl implements QualityRepository {
  QualityRepositoryImpl({required QualityRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QualityRemoteDataSource _remoteDataSource;

  @override
  Future<Result<QualityMetrics>> getQualityMetrics() async {
    try {
      final model = await _remoteDataSource.getQualityMetrics();
      return Right(model.toEntity());
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
}
