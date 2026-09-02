import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(Failure.network());
    }
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(user.toEntity());
    } on AccountNotFoundException catch (e) {
      return Left(Failure.accountNotFound(message: e.message));
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

  @override
  Future<Result<User>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(Failure.network());
    }
    try {
      final user = await _remoteDataSource.register(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
        role: role,
      );
      return Right(user.toEntity());
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user?.toEntity());
    } on UnauthorizedException {
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
  Future<Result<void>> forgotPassword({required String email}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(Failure.network());
    }
    try {
      await _remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }
}
