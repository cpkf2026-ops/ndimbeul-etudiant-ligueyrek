import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/actualite_admin.dart';
import '../../domain/repositories/admin_news_repository.dart';
import '../datasources/admin_news_remote_datasource.dart';

class AdminNewsRepositoryImpl implements AdminNewsRepository {
  AdminNewsRepositoryImpl({required AdminNewsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AdminNewsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ActualiteAdmin>>> getNews() async {
    try {
      final models = await _remoteDataSource.getNews();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (_) {
      return const Left(Failure.unexpected());
    }
  }
}
