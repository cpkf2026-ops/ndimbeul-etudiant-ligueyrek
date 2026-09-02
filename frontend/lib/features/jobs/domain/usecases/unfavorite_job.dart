import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/job_repository.dart';
import 'job_id_params.dart';

class UnfavoriteJob implements UseCase<void, JobIdParams> {
  const UnfavoriteJob(this._repository);
  final JobRepository _repository;

  @override
  Future<Result<void>> call(JobIdParams params) =>
      _repository.unfavorite(params.id);
}
