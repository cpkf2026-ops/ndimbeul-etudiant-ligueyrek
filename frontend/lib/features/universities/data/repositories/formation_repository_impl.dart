import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/formation.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/universite.dart';
import '../../domain/repositories/formation_repository.dart';
import '../datasources/formation_remote_datasource.dart';

class FormationRepositoryImpl implements FormationRepository {
  FormationRepositoryImpl({
    required FormationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final FormationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<PaginatedResult<Formation>>> getFormations({
    String? domaine,
    NiveauFormation? niveau,
    String? region,
    EtablissementType? typeEtablissement,
    String? serieBac,
    String? universiteId,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(Failure.network());
    }
    try {
      final result = await _remoteDataSource.getFormations(
        domaine: domaine,
        niveau: niveau?.name,
        region: region,
        typeEtablissement: typeEtablissement?.name,
        serieBac: serieBac,
        universiteId: universiteId,
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
  Future<Result<List<Formation>>> compareFormations(List<String> ids) async {
    try {
      final models = await _remoteDataSource.compareFormations(ids);
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
  Future<Result<List<Formation>>> getFavoriteFormations() async {
    try {
      final models = await _remoteDataSource.getFavoriteFormations();
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
  Future<Result<void>> favoriteFormation(String id) async {
    try {
      await _remoteDataSource.favoriteFormation(id);
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
  Future<Result<void>> unfavoriteFormation(String id) async {
    try {
      await _remoteDataSource.unfavoriteFormation(id);
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
