import '../../domain/entities/paginated_result.dart';
import '../models/formation_model.dart';
import 'formation_remote_datasource.dart';
import 'mock_university_data.dart';

/// Jeu de données mocké — recherche de formations à plat sur l'ensemble des
/// universités mockées (voir §10).
class MockFormationRemoteDataSource implements FormationRemoteDataSource {
  static final Set<String> _favorites = {};

  @override
  Future<PaginatedResult<FormationModel>> getFormations({
    String? domaine,
    String? niveau,
    String? region,
    String? typeEtablissement,
    String? serieBac,
    String? universiteId,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var filtered = MockUniversityData.toutesLesFormations.where((f) {
      if (domaine != null && f.domaine != domaine) return false;
      if (niveau != null && f.niveau.name != niveau) return false;
      if (universiteId != null && f.universiteId != universiteId) return false;
      if (serieBac != null && f.seriesAcceptees != null && !f.seriesAcceptees!.contains(serieBac)) {
        return false;
      }
      if (region != null) {
        final universite = MockUniversityData.universiteDe(f.universiteId);
        if (universite.region != region) return false;
      }
      if (typeEtablissement != null) {
        final universite = MockUniversityData.universiteDe(f.universiteId);
        if (universite.type.name != typeEtablissement) return false;
      }
      return true;
    }).map((f) => f.copyWith(estFavori: _favorites.contains(f.id))).toList();

    final start = ((page - 1) * perPage).clamp(0, filtered.length);
    final end = (start + perPage).clamp(0, filtered.length);

    return PaginatedResult(
      items: filtered.sublist(start, end),
      currentPage: page,
      lastPage: (filtered.length / perPage).ceil().clamp(1, 999),
      total: filtered.length,
    );
  }

  @override
  Future<List<FormationModel>> compareFormations(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockUniversityData.toutesLesFormations.where((f) => ids.contains(f.id)).toList();
  }

  @override
  Future<List<FormationModel>> getFavoriteFormations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockUniversityData.toutesLesFormations
        .where((f) => _favorites.contains(f.id))
        .map((f) => f.copyWith(estFavori: true))
        .toList();
  }

  @override
  Future<void> favoriteFormation(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _favorites.add(id);
  }

  @override
  Future<void> unfavoriteFormation(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _favorites.remove(id);
  }
}
