import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/formation_repository.dart';

class UnfavoriteFormation implements UseCase<void, String> {
  const UnfavoriteFormation(this._repository);
  final FormationRepository _repository;

  @override
  Future<Result<void>> call(String formationId) => _repository.unfavoriteFormation(formationId);
}
