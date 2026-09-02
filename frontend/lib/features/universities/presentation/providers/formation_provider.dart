import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/formation_remote_datasource.dart';
import '../../data/datasources/mock_formation_remote_datasource.dart';
import '../../data/repositories/formation_repository_impl.dart';
import '../../domain/entities/formation.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/repositories/formation_repository.dart';
import '../../domain/usecases/favorite_formation.dart';
import '../../domain/usecases/get_favorite_formations.dart';
import '../../domain/usecases/get_formations.dart';
import '../../domain/usecases/unfavorite_formation.dart';

final formationRemoteDataSourceProvider = Provider<FormationRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockFormationRemoteDataSource();
  return FormationRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final formationRepositoryProvider = Provider<FormationRepository>((ref) {
  return FormationRepositoryImpl(
    remoteDataSource: ref.watch(formationRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getFormationsUseCaseProvider =
    Provider((ref) => GetFormations(ref.watch(formationRepositoryProvider)));
final getFavoriteFormationsUseCaseProvider =
    Provider((ref) => GetFavoriteFormations(ref.watch(formationRepositoryProvider)));
final favoriteFormationUseCaseProvider =
    Provider((ref) => FavoriteFormation(ref.watch(formationRepositoryProvider)));
final unfavoriteFormationUseCaseProvider =
    Provider((ref) => UnfavoriteFormation(ref.watch(formationRepositoryProvider)));

final formationFiltersProvider = StateProvider<GetFormationsParams>(
  (ref) => const GetFormationsParams(),
);

class FormationListNotifier extends AsyncNotifier<PaginatedResult<Formation>> {
  @override
  Future<PaginatedResult<Formation>> build() async {
    final params = ref.watch(formationFiltersProvider);
    final result = await ref.read(getFormationsUseCaseProvider).call(params);
    return result.fold((failure) => throw failure, (page) => page);
  }

  Future<Failure?> toggleFavorite(Formation formation) async {
    final current = state.valueOrNull;
    if (current == null) return null;
    final updated = current.items
        .map((f) => f.id == formation.id ? f.copyWith(estFavori: !f.estFavori) : f)
        .toList();
    state = AsyncValue.data(
      PaginatedResult(
        items: updated,
        currentPage: current.currentPage,
        lastPage: current.lastPage,
        total: current.total,
      ),
    );
    final result = formation.estFavori
        ? await ref.read(unfavoriteFormationUseCaseProvider).call(formation.id)
        : await ref.read(favoriteFormationUseCaseProvider).call(formation.id);
    return result.fold((failure) {
      state = AsyncValue.data(current);
      return failure;
    }, (_) => null);
  }
}

final formationListProvider =
    AsyncNotifierProvider<FormationListNotifier, PaginatedResult<Formation>>(
  FormationListNotifier.new,
);

class FavoriteFormationsNotifier extends AsyncNotifier<List<Formation>> {
  @override
  Future<List<Formation>> build() async {
    final result = await ref.read(getFavoriteFormationsUseCaseProvider).call(const NoParams());
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((f) => f.id != id).toList());
    final result = await ref.read(unfavoriteFormationUseCaseProvider).call(id);
    result.fold((failure) => ref.invalidateSelf(), (_) => null);
  }
}

final favoriteFormationsProvider =
    AsyncNotifierProvider<FavoriteFormationsNotifier, List<Formation>>(
  FavoriteFormationsNotifier.new,
);
