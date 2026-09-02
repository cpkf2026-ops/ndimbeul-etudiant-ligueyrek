import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/source_donnee.dart';
import '../repositories/source_repository.dart';

class GetSources implements UseCase<List<SourceDonnee>, NoParams> {
  const GetSources(this._repository);
  final SourceRepository _repository;

  @override
  Future<Result<List<SourceDonnee>>> call(NoParams params) {
    return _repository.getSources();
  }
}
