import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/job_page.dart';
import '../entities/offre_emploi.dart';
import '../repositories/job_repository.dart';

class GetJobsParams {
  const GetJobsParams({
    this.domaine,
    this.region,
    this.type,
    this.niveauRequis,
    this.dateLimiteAvant,
    this.page = 1,
    this.perPage = 20,
  });

  final String? domaine;
  final String? region;
  final JobType? type;
  final String? niveauRequis;
  final DateTime? dateLimiteAvant;
  final int page;
  final int perPage;
}

class GetJobs implements UseCase<JobPage, GetJobsParams> {
  const GetJobs(this._repository);
  final JobRepository _repository;

  @override
  Future<Result<JobPage>> call(GetJobsParams params) => _repository.list(
        domaine: params.domaine,
        region: params.region,
        type: params.type,
        niveauRequis: params.niveauRequis,
        dateLimiteAvant: params.dateLimiteAvant,
        page: params.page,
        perPage: params.perPage,
      );
}
