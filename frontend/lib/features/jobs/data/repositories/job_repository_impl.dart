import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/job_page.dart';
import '../../domain/entities/offre_emploi.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  JobRepositoryImpl({
    required JobRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final JobRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<JobPage>> list({
    String? domaine,
    String? region,
    JobType? type,
    String? niveauRequis,
    DateTime? dateLimiteAvant,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(Failure.network());
    }
    try {
      final page_ = await _remoteDataSource.list(
        domaine: domaine,
        region: region,
        type: type,
        niveauRequis: niveauRequis,
        dateLimiteAvant: dateLimiteAvant,
        page: page,
        perPage: perPage,
      );
      return Right(
        JobPage(
          items: page_.items.map((e) => e.toEntity()).toList(),
          currentPage: page_.currentPage,
          lastPage: page_.lastPage,
          total: page_.total,
        ),
      );
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<OffreEmploi>> detail(String id) async {
    try {
      final model = await _remoteDataSource.detail(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<List<OffreEmploi>>> favorites() async {
    try {
      final models = await _remoteDataSource.favorites();
      return Right(models.map((e) => e.toEntity()).toList());
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
  Future<Result<void>> favorite(String id) async {
    try {
      await _remoteDataSource.favorite(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> unfavorite(String id) async {
    try {
      await _remoteDataSource.unfavorite(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }
}
