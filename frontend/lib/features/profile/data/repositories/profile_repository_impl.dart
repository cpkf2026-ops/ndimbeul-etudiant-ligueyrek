import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/profil_academique.dart';
import '../../domain/entities/profil_etudiant.dart';
import '../../domain/entities/profil_lyceen.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profil_etudiant_model.dart';
import '../models/profil_lyceen_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ProfilAcademique>> getProfile() async {
    try {
      final envelope = await _remoteDataSource.getProfile();
      if (envelope.role == 'etudiant') {
        return Right(
          ProfilAcademique.etudiant(ProfilEtudiantModel.fromJson(envelope.profil).toEntity()),
        );
      }
      return Right(
        ProfilAcademique.lyceen(ProfilLyceenModel.fromJson(envelope.profil).toEntity()),
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
  Future<Result<ProfilLyceen>> updateProfilLyceen(ProfilLyceen profil) async {
    try {
      final result = await _remoteDataSource.updateProfilLyceen(
        ProfilLyceenModel.fromEntity(profil),
      );
      return Right(result.toEntity());
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
  Future<Result<ProfilEtudiant>> updateProfilEtudiant(ProfilEtudiant profil) async {
    try {
      final result = await _remoteDataSource.updateProfilEtudiant(
        ProfilEtudiantModel.fromEntity(profil),
      );
      return Right(result.toEntity());
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
}
