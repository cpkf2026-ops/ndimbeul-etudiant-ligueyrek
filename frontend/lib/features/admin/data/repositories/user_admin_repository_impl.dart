import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/user_admin_repository.dart';
import '../datasources/user_admin_remote_datasource.dart';

String _roleName(UserRole role) => switch (role) {
  UserRole.lyceen => 'lyceen',
  UserRole.etudiant => 'etudiant',
  UserRole.adminEtablissement => 'admin_etablissement',
  UserRole.superAdmin => 'super_admin',
};

class UserAdminRepositoryImpl implements UserAdminRepository {
  UserAdminRepositoryImpl({required UserAdminRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final UserAdminRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<AdminUser>>> getUsers({
    UserRole? role,
    UserStatut? statut,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final models = await _remoteDataSource.getUsers(
        role: role != null ? _roleName(role) : null,
        statut: statut?.name,
        page: page,
        perPage: perPage,
      );
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
  Future<Result<AdminUser>> updateUserRole({
    required String id,
    required UserRole role,
  }) async {
    try {
      final model = await _remoteDataSource.updateUserRole(
        id: id,
        role: _roleName(role),
      );
      return Right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> suspendUser(String id) async {
    try {
      await _remoteDataSource.suspendUser(id);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> reactivateUser(String id) async {
    try {
      await _remoteDataSource.reactivateUser(id);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      await _remoteDataSource.deleteUser(id);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }
}
