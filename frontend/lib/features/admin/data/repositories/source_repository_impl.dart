import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/source_donnee.dart';
import '../../domain/repositories/source_repository.dart';
import '../datasources/source_remote_datasource.dart';

class SourceRepositoryImpl implements SourceRepository {
  SourceRepositoryImpl({required SourceRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final SourceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<SourceDonnee>>> getSources() async {
    try {
      final models = await _remoteDataSource.getSources();
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
  Future<Result<SourceDonnee>> createSource({
    String? universiteId,
    required SourceType type,
    required String urlOuChemin,
    String? categorie,
  }) async {
    try {
      final model = await _remoteDataSource.createSource(
        universiteId: universiteId,
        type: type.name,
        urlOuChemin: urlOuChemin,
        categorie: categorie,
      );
      return Right(model.toEntity());
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<SourceDonnee>> updateSource({
    required String id,
    String? universiteId,
    required SourceType type,
    required String urlOuChemin,
    String? categorie,
  }) async {
    try {
      final model = await _remoteDataSource.updateSource(
        id: id,
        universiteId: universiteId,
        type: type.name,
        urlOuChemin: urlOuChemin,
        categorie: categorie,
      );
      return Right(model.toEntity());
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<void>> deleteSource(String id) async {
    try {
      await _remoteDataSource.deleteSource(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> uploadDocument({
    required Uint8List bytes,
    required String filename,
    String? sourceId,
    String? universiteId,
    String? categorie,
  }) async {
    try {
      final result = await _remoteDataSource.uploadDocument(
        bytes: bytes,
        filename: filename,
        sourceId: sourceId,
        universiteId: universiteId,
        categorie: categorie,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }
}
