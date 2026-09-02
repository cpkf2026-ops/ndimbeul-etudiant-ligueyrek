import '../../../../core/utils/result.dart';
import '../entities/paginated_result.dart';
import '../entities/universite.dart';

abstract interface class UniversityRepository {
  Future<Result<PaginatedResult<Universite>>> getUniversities({
    String? region,
    EtablissementType? type,
    String? q,
    int page = 1,
    int perPage = 20,
  });

  Future<Result<Universite>> getUniversityDetail(String id);

  /// Compare 2 à 4 universités (CDC §7.3 "Comparaison").
  Future<Result<List<Universite>>> compareUniversities(List<String> ids);

  Future<Result<List<Universite>>> getUniversitiesHistory();

  /// `statut` ∈ {suggeree, consultee, comparee} (CDC §7.4).
  Future<Result<void>> trackUniversity({required String id, required String statut});
}
