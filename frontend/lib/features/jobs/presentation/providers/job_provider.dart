import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/job_remote_datasource.dart';
import '../../data/datasources/mock_job_remote_datasource.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../domain/entities/job_page.dart';
import '../../domain/entities/offre_emploi.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/usecases/favorite_job.dart';
import '../../domain/usecases/get_job_detail.dart';
import '../../domain/usecases/get_job_favorites.dart';
import '../../domain/usecases/get_jobs.dart';
import '../../domain/usecases/job_id_params.dart';
import '../../domain/usecases/unfavorite_job.dart';

final jobRemoteDataSourceProvider = Provider<JobRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockJobRemoteDataSource();
  return JobRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepositoryImpl(
    remoteDataSource: ref.watch(jobRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getJobsUseCaseProvider = Provider((ref) => GetJobs(ref.watch(jobRepositoryProvider)));
final getJobDetailUseCaseProvider =
    Provider((ref) => GetJobDetail(ref.watch(jobRepositoryProvider)));
final getJobFavoritesUseCaseProvider =
    Provider((ref) => GetJobFavorites(ref.watch(jobRepositoryProvider)));
final favoriteJobUseCaseProvider =
    Provider((ref) => FavoriteJob(ref.watch(jobRepositoryProvider)));
final unfavoriteJobUseCaseProvider =
    Provider((ref) => UnfavoriteJob(ref.watch(jobRepositoryProvider)));

/// Filtres actifs de la liste d'offres — modifiés par les widgets de filtre.
class JobFilters {
  const JobFilters({this.domaine, this.region, this.type});
  final String? domaine;
  final String? region;
  final JobType? type;

  JobFilters copyWith({String? domaine, String? region, JobType? type}) =>
      JobFilters(
        domaine: domaine ?? this.domaine,
        region: region ?? this.region,
        type: type ?? this.type,
      );
}

final jobFiltersProvider = StateProvider<JobFilters>((ref) => const JobFilters());

/// Liste paginée d'offres, réagit aux filtres actifs.
class JobListNotifier extends AsyncNotifier<JobPage> {
  @override
  Future<JobPage> build() async {
    final filters = ref.watch(jobFiltersProvider);
    final result = await ref.read(getJobsUseCaseProvider).call(
          GetJobsParams(
            domaine: filters.domaine,
            region: filters.region,
            type: filters.type,
          ),
        );
    return result.fold((failure) => throw failure, (page) => page);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;
    final filters = ref.read(jobFiltersProvider);
    final result = await ref.read(getJobsUseCaseProvider).call(
          GetJobsParams(
            domaine: filters.domaine,
            region: filters.region,
            type: filters.type,
            page: current.currentPage + 1,
          ),
        );
    result.fold((failure) => null, (nextPage) {
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...nextPage.items],
          currentPage: nextPage.currentPage,
          lastPage: nextPage.lastPage,
        ),
      );
    });
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<Failure?> toggleFavorite(OffreEmploi job) async {
    final current = state.valueOrNull;
    if (current == null) return null;
    final updated = current.items
        .map((j) => j.id == job.id ? j.copyWith(estFavori: !j.estFavori) : j)
        .toList();
    state = AsyncValue.data(current.copyWith(items: updated));

    final result = job.estFavori
        ? await ref.read(unfavoriteJobUseCaseProvider).call(JobIdParams(job.id))
        : await ref.read(favoriteJobUseCaseProvider).call(JobIdParams(job.id));

    return result.fold((failure) {
      // rollback optimiste en cas d'échec réseau
      state = AsyncValue.data(current);
      return failure;
    }, (_) => null);
  }
}

final jobListProvider = AsyncNotifierProvider<JobListNotifier, JobPage>(JobListNotifier.new);

final jobDetailProvider =
    FutureProvider.family<OffreEmploi, String>((ref, id) async {
  final result = await ref.read(getJobDetailUseCaseProvider).call(JobIdParams(id));
  return result.fold((failure) => throw failure, (job) => job);
});

class JobFavoritesNotifier extends AsyncNotifier<List<OffreEmploi>> {
  @override
  Future<List<OffreEmploi>> build() async {
    final result = await ref.read(getJobFavoritesUseCaseProvider).call(const NoParams());
    return result.fold((failure) => throw failure, (jobs) => jobs);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((j) => j.id != id).toList());
    final result = await ref.read(unfavoriteJobUseCaseProvider).call(JobIdParams(id));
    result.fold((failure) => ref.invalidateSelf(), (_) => null);
  }
}

final jobFavoritesProvider =
    AsyncNotifierProvider<JobFavoritesNotifier, List<OffreEmploi>>(
  JobFavoritesNotifier.new,
);
