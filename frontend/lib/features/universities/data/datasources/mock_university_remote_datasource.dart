import '../../domain/entities/paginated_result.dart';
import '../models/universite_model.dart';
import 'mock_university_data.dart';
import 'university_remote_datasource.dart';

/// Jeu de données mocké — universités sénégalaises réelles (voir §10).
class MockUniversityRemoteDataSource implements UniversityRemoteDataSource {
  static final List<String> _history = [];

  @override
  Future<PaginatedResult<UniversiteModel>> getUniversities({
    String? region,
    String? type,
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var filtered = MockUniversityData.universites.where((u) {
      if (region != null && u.region != region) return false;
      if (type != null && u.type.name != type) return false;
      if (q != null && q.isNotEmpty) {
        final query = q.toLowerCase();
        if (!u.nom.toLowerCase().contains(query) &&
            !(u.region?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Liste allégée (sans fiche complète) — reflète le comportement réel de
    // /api/v1/universities côté Laravel (fiche uniquement sur `show`).
    filtered = filtered
        .map((u) => u.copyWith(
              formations: const [],
              bourses: const [],
              logements: const [],
              fraisScolarite: const [],
            ))
        .toList();

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
  Future<UniversiteModel> getUniversityDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final universite = MockUniversityData.universiteDe(id);
    _history.remove(id);
    _history.insert(0, id);
    return universite;
  }

  @override
  Future<List<UniversiteModel>> compareUniversities(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ids.map(MockUniversityData.universiteDe).toList();
  }

  @override
  Future<List<UniversiteModel>> getUniversitiesHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _history.map(MockUniversityData.universiteDe).toList();
  }

  @override
  Future<void> trackUniversity({required String id, required String statut}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _history.remove(id);
    _history.insert(0, id);
  }
}
