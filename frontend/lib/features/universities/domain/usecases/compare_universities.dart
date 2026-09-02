import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/universite.dart';
import '../repositories/university_repository.dart';

class CompareUniversities implements UseCase<List<Universite>, List<String>> {
  const CompareUniversities(this._repository);
  final UniversityRepository _repository;

  @override
  Future<Result<List<Universite>>> call(List<String> ids) => _repository.compareUniversities(ids);
}
