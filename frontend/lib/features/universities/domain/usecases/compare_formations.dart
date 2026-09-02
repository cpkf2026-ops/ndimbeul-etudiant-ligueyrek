import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/formation.dart';
import '../repositories/formation_repository.dart';

class CompareFormations implements UseCase<List<Formation>, List<String>> {
  const CompareFormations(this._repository);
  final FormationRepository _repository;

  @override
  Future<Result<List<Formation>>> call(List<String> ids) => _repository.compareFormations(ids);
}
