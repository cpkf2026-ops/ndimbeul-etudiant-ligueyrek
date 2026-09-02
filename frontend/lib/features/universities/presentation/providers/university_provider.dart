import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/mock_university_remote_datasource.dart';
import '../../data/datasources/university_remote_datasource.dart';
import '../../data/repositories/university_repository_impl.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/universite.dart';
import '../../domain/repositories/university_repository.dart';
import '../../domain/usecases/compare_universities.dart';
import '../../domain/usecases/get_universities.dart';
import '../../domain/usecases/get_universities_history.dart';
import '../../domain/usecases/get_university_detail.dart';
import '../../domain/usecases/track_university.dart';

final universityRemoteDataSourceProvider = Provider<UniversityRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockUniversityRemoteDataSource();
  return UniversityRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final universityRepositoryProvider = Provider<UniversityRepository>((ref) {
  return UniversityRepositoryImpl(
    remoteDataSource: ref.watch(universityRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getUniversitiesUseCaseProvider =
    Provider((ref) => GetUniversities(ref.watch(universityRepositoryProvider)));
final getUniversityDetailUseCaseProvider =
    Provider((ref) => GetUniversityDetail(ref.watch(universityRepositoryProvider)));
final compareUniversitiesUseCaseProvider =
    Provider((ref) => CompareUniversities(ref.watch(universityRepositoryProvider)));
final getUniversitiesHistoryUseCaseProvider =
    Provider((ref) => GetUniversitiesHistory(ref.watch(universityRepositoryProvider)));
final trackUniversityUseCaseProvider =
    Provider((ref) => TrackUniversity(ref.watch(universityRepositoryProvider)));

class UniversityFilters {
  const UniversityFilters({this.region, this.type, this.q});
  final String? region;
  final EtablissementType? type;
  final String? q;

  UniversityFilters copyWith({String? region, EtablissementType? type, String? q}) =>
      UniversityFilters(
        region: region ?? this.region,
        type: type ?? this.type,
        q: q ?? this.q,
      );
}

final universityFiltersProvider =
    StateProvider<UniversityFilters>((ref) => const UniversityFilters());

class UniversityListNotifier extends AsyncNotifier<PaginatedResult<Universite>> {
  @override
  Future<PaginatedResult<Universite>> build() async {
    final filters = ref.watch(universityFiltersProvider);
    final result = await ref.read(getUniversitiesUseCaseProvider).call(
          GetUniversitiesParams(
            region: filters.region,
            type: filters.type,
            q: filters.q,
            // Catalogue élargi (Prompt 5) : ~60 établissements, servis en une
            // page (le back-office Laravel plafonne per_page à 100).
            perPage: 100,
          ),
        );
    return result.fold((failure) => throw failure, (page) => page);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final universityListProvider =
    AsyncNotifierProvider<UniversityListNotifier, PaginatedResult<Universite>>(
  UniversityListNotifier.new,
);

final universityDetailProvider =
    FutureProvider.family<Universite, String>((ref, id) async {
  final result = await ref.read(getUniversityDetailUseCaseProvider).call(id);
  final university = result.fold((failure) => throw failure, (u) => u);
  // Best-effort : trace la consultation sans bloquer l'affichage de la fiche.
  ref.read(trackUniversityUseCaseProvider).call(
        TrackUniversityParams(id: id, statut: 'consultee'),
      );
  return university;
});

final universitiesHistoryProvider = FutureProvider<List<Universite>>((ref) async {
  final result = await ref.read(getUniversitiesHistoryUseCaseProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (list) => list);
});

/// Sélection courante pour l'écran de comparaison (2 à 4 universités).
final universityCompareSelectionProvider = StateProvider<List<String>>((ref) => []);

final universityCompareProvider = FutureProvider<List<Universite>>((ref) async {
  final ids = ref.watch(universityCompareSelectionProvider);
  if (ids.length < 2) return [];
  final result = await ref.read(compareUniversitiesUseCaseProvider).call(ids);
  final list = result.fold((failure) => throw failure, (l) => l);
  ref.read(trackUniversityUseCaseProvider).call(
        TrackUniversityParams(id: ids.first, statut: 'comparee'),
      );
  return list;
});
