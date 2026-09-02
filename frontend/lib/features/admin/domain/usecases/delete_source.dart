import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/source_repository.dart';

class DeleteSource implements UseCase<void, String> {
  const DeleteSource(this._repository);
  final SourceRepository _repository;

  @override
  Future<Result<void>> call(String id) {
    return _repository.deleteSource(id);
  }
}
