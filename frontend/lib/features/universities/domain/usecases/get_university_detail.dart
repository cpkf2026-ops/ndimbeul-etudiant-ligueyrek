import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/universite.dart';
import '../repositories/university_repository.dart';

class GetUniversityDetail implements UseCase<Universite, String> {
  const GetUniversityDetail(this._repository);
  final UniversityRepository _repository;

  @override
  Future<Result<Universite>> call(String id) => _repository.getUniversityDetail(id);
}
