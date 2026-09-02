import '../../../../core/utils/result.dart';
import '../entities/job_page.dart';
import '../entities/offre_emploi.dart';

abstract interface class JobRepository {
  Future<Result<JobPage>> list({
    String? domaine,
    String? region,
    JobType? type,
    String? niveauRequis,
    DateTime? dateLimiteAvant,
    int page = 1,
    int perPage = 20,
  });

  Future<Result<OffreEmploi>> detail(String id);

  Future<Result<List<OffreEmploi>>> favorites();

  Future<Result<void>> favorite(String id);

  Future<Result<void>> unfavorite(String id);
}
