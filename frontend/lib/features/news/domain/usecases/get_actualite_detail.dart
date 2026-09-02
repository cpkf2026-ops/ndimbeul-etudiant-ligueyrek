import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/actualite.dart';
import '../repositories/news_repository.dart';

class GetActualiteDetail implements UseCase<Actualite, String> {
  const GetActualiteDetail(this._repository);
  final NewsRepository _repository;

  @override
  Future<Result<Actualite>> call(String id) => _repository.getActualiteDetail(id);
}
