import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/universite.dart';
import '../repositories/university_repository.dart';

class GetUniversitiesHistory implements UseCase<List<Universite>, NoParams> {
  const GetUniversitiesHistory(this._repository);
  final UniversityRepository _repository;

  @override
  Future<Result<List<Universite>>> call(NoParams params) => _repository.getUniversitiesHistory();
}
