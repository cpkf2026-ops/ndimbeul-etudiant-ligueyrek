import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/formation_repository.dart';

class FavoriteFormation implements UseCase<void, String> {
  const FavoriteFormation(this._repository);
  final FormationRepository _repository;

  @override
  Future<Result<void>> call(String formationId) => _repository.favoriteFormation(formationId);
}
