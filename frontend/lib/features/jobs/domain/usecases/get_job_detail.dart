import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/offre_emploi.dart';
import '../repositories/job_repository.dart';
import 'job_id_params.dart';

class GetJobDetail implements UseCase<OffreEmploi, JobIdParams> {
  const GetJobDetail(this._repository);
  final JobRepository _repository;

  @override
  Future<Result<OffreEmploi>> call(JobIdParams params) =>
      _repository.detail(params.id);
}
