import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/formation.dart';
import '../repositories/formation_repository.dart';

class GetFavoriteFormations implements UseCase<List<Formation>, NoParams> {
  const GetFavoriteFormations(this._repository);
  final FormationRepository _repository;

  @override
  Future<Result<List<Formation>>> call(NoParams params) => _repository.getFavoriteFormations();
}
