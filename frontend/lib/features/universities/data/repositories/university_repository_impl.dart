import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/universite.dart';
import '../../domain/repositories/university_repository.dart';
import '../datasources/university_remote_datasource.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  UniversityRepositoryImpl({
    required UniversityRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final UniversityRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<PaginatedResult<Universite>>> getUniversities({
    String? region,
    EtablissementType? type,
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(Failure.network());
    }
    try {
      final result = await _remoteDataSource.getUniversities(
        region: region,
        type: type?.name,
        q: q,
        page: page,
        perPage: perPage,
      );
      return Right(
        PaginatedResult(
          items: result.items.map((e) => e.toEntity()).toList(),
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          total: result.total,
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
  Future<Result<Universite>> getUniversityDetail(String id) async {
    try {
      final model = await _remoteDataSource.getUniversityDetail(id);
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
  Future<Result<List<Universite>>> compareUniversities(List<String> ids) async {
    try {
      final models = await _remoteDataSource.compareUniversities(ids);
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<List<Universite>>> getUniversitiesHistory() async {
    try {
      final models = await _remoteDataSource.getUniversitiesHistory();
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
  Future<Result<void>> trackUniversity({required String id, required String statut}) async {
    try {
      await _remoteDataSource.trackUniversity(id: id, statut: statut);
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
