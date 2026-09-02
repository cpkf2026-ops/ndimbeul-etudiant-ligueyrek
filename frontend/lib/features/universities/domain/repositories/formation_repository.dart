import '../../../../core/utils/result.dart';
import '../entities/formation.dart';
import '../entities/paginated_result.dart';
import '../entities/universite.dart';

abstract interface class FormationRepository {
  Future<Result<PaginatedResult<Formation>>> getFormations({
    String? domaine,
    NiveauFormation? niveau,
    String? region,
    EtablissementType? typeEtablissement,
    String? serieBac,
    String? universiteId,
    int page = 1,
    int perPage = 20,
  });

  /// Compare 2 à 4 formations (CDC UC07).
  Future<Result<List<Formation>>> compareFormations(List<String> ids);

  Future<Result<List<Formation>>> getFavoriteFormations();

  Future<Result<void>> favoriteFormation(String id);

  Future<Result<void>> unfavoriteFormation(String id);
}
