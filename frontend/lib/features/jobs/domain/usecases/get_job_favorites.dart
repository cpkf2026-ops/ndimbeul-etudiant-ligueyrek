import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/offre_emploi.dart';
import '../repositories/job_repository.dart';

class GetJobFavorites implements UseCase<List<OffreEmploi>, NoParams> {
  const GetJobFavorites(this._repository);
  final JobRepository _repository;

  @override
  Future<Result<List<OffreEmploi>>> call(NoParams params) =>
      _repository.favorites();
}
