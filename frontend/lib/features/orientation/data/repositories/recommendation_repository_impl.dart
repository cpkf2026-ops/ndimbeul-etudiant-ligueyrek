import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/recommandation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl({required RecommendationRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RecommendationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Recommandation>>> getRecommendations() async {
    try {
      final models = await _remoteDataSource.getRecommendations();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, errors: e.errors));
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
