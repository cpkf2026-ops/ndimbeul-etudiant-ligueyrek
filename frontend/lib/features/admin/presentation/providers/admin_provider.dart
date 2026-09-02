import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/admin_news_remote_datasource.dart';
import '../../data/datasources/mock_admin_datasources.dart';
import '../../data/datasources/quality_remote_datasource.dart';
import '../../data/datasources/source_remote_datasource.dart';
import '../../data/datasources/user_admin_remote_datasource.dart';
import '../../data/repositories/admin_news_repository_impl.dart';
import '../../data/repositories/quality_repository_impl.dart';
import '../../data/repositories/source_repository_impl.dart';
import '../../data/repositories/user_admin_repository_impl.dart';
import '../../domain/entities/actualite_admin.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/quality_metrics.dart';
import '../../domain/entities/source_donnee.dart';
import '../../domain/repositories/admin_news_repository.dart';
import '../../domain/repositories/quality_repository.dart';
import '../../domain/repositories/source_repository.dart';
import '../../domain/repositories/user_admin_repository.dart';
import '../../domain/usecases/create_source.dart';
import '../../domain/usecases/delete_source.dart';
import '../../domain/usecases/delete_user.dart';
import '../../domain/usecases/get_admin_news.dart';
import '../../domain/usecases/get_admin_users.dart';
import '../../domain/usecases/get_quality_metrics.dart';
import '../../domain/usecases/get_sources.dart';
import '../../domain/usecases/reactivate_user.dart';
import '../../domain/usecases/suspend_user.dart';
import '../../domain/usecases/update_source.dart';
import '../../domain/usecases/update_user_role.dart';
import '../../domain/usecases/upload_document.dart';

// --- Sources -----------------------------------------------------------

final sourceRemoteDataSourceProvider = Provider<SourceRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockSourceRemoteDataSource();
  return SourceRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  return SourceRepositoryImpl(
    remoteDataSource: ref.watch(sourceRemoteDataSourceProvider),
  );
});

final getSourcesUseCaseProvider = Provider(
  (ref) => GetSources(ref.watch(sourceRepositoryProvider)),
);
final createSourceUseCaseProvider = Provider(
  (ref) => CreateSource(ref.watch(sourceRepositoryProvider)),
);
final updateSourceUseCaseProvider = Provider(
  (ref) => UpdateSource(ref.watch(sourceRepositoryProvider)),
);
final deleteSourceUseCaseProvider = Provider(
  (ref) => DeleteSource(ref.watch(sourceRepositoryProvider)),
);
final uploadDocumentUseCaseProvider = Provider(
  (ref) => UploadDocument(ref.watch(sourceRepositoryProvider)),
);

class SourcesNotifier extends AsyncNotifier<List<SourceDonnee>> {
  @override
  Future<List<SourceDonnee>> build() async {
    final result = await ref
        .read(getSourcesUseCaseProvider)
        .call(const NoParams());
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<Failure?> create({
    String? universiteId,
    required SourceType type,
    required String urlOuChemin,
    String? categorie,
  }) async {
    final result = await ref
        .read(createSourceUseCaseProvider)
        .call(
          CreateSourceParams(
            universiteId: universiteId,
            type: type,
            urlOuChemin: urlOuChemin,
            categorie: categorie,
          ),
        );
    return result.fold((failure) => failure, (source) {
      state = AsyncValue.data([...state.valueOrNull ?? [], source]);
      return null;
    });
  }

  Future<Failure?> delete(String id) async {
    final previous = state.valueOrNull ?? [];
    state = AsyncValue.data(previous.where((s) => s.id != id).toList());
    final result = await ref.read(deleteSourceUseCaseProvider).call(id);
    return result.fold((failure) {
      state = AsyncValue.data(previous);
      return failure;
    }, (_) => null);
  }
}

final sourcesProvider =
    AsyncNotifierProvider<SourcesNotifier, List<SourceDonnee>>(
      SourcesNotifier.new,
    );

// --- Utilisateurs --------------------------------------------------------

final userAdminRemoteDataSourceProvider = Provider<UserAdminRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockProvider)) return MockUserAdminRemoteDataSource();
  return UserAdminRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final userAdminRepositoryProvider = Provider<UserAdminRepository>((ref) {
  return UserAdminRepositoryImpl(
    remoteDataSource: ref.watch(userAdminRemoteDataSourceProvider),
  );
});

final getAdminUsersUseCaseProvider = Provider(
  (ref) => GetAdminUsers(ref.watch(userAdminRepositoryProvider)),
);
final updateUserRoleUseCaseProvider = Provider(
  (ref) => UpdateUserRole(ref.watch(userAdminRepositoryProvider)),
);
final suspendUserUseCaseProvider = Provider(
  (ref) => SuspendUser(ref.watch(userAdminRepositoryProvider)),
);
final reactivateUserUseCaseProvider = Provider(
  (ref) => ReactivateUser(ref.watch(userAdminRepositoryProvider)),
);
final deleteUserUseCaseProvider = Provider(
  (ref) => DeleteUser(ref.watch(userAdminRepositoryProvider)),
);

class AdminUsersNotifier extends AsyncNotifier<List<AdminUser>> {
  @override
  Future<List<AdminUser>> build() async {
    final result = await ref
        .read(getAdminUsersUseCaseProvider)
        .call(const GetAdminUsersParams());
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<Failure?> updateRole(String id, UserRole role) async {
    final result = await ref
        .read(updateUserRoleUseCaseProvider)
        .call(UpdateUserRoleParams(id: id, role: role));
    return result.fold((failure) => failure, (updated) {
      state = AsyncValue.data(
        (state.valueOrNull ?? []).map((u) => u.id == id ? updated : u).toList(),
      );
      return null;
    });
  }

  Future<Failure?> toggleSuspend(AdminUser user) async {
    final isActive = user.statut == UserStatut.actif;
    final previous = state.valueOrNull ?? [];
    state = AsyncValue.data(
      previous
          .map(
            (u) => u.id == user.id
                ? u.copyWith(
                    statut: isActive ? UserStatut.suspendu : UserStatut.actif,
                  )
                : u,
          )
          .toList(),
    );
    final result = isActive
        ? await ref.read(suspendUserUseCaseProvider).call(user.id)
        : await ref.read(reactivateUserUseCaseProvider).call(user.id);
    return result.fold((failure) {
      state = AsyncValue.data(previous);
      return failure;
    }, (_) => null);
  }

  Future<Failure?> deleteUser(String id) async {
    final previous = state.valueOrNull ?? [];
    state = AsyncValue.data(previous.where((u) => u.id != id).toList());
    final result = await ref.read(deleteUserUseCaseProvider).call(id);
    return result.fold((failure) {
      state = AsyncValue.data(previous);
      return failure;
    }, (_) => null);
  }
}

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<AdminUser>>(
      AdminUsersNotifier.new,
    );

// --- Qualité ---------------------------------------------------------------

final qualityRemoteDataSourceProvider = Provider<QualityRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockProvider)) return MockQualityRemoteDataSource();
  return QualityRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final qualityRepositoryProvider = Provider<QualityRepository>((ref) {
  return QualityRepositoryImpl(
    remoteDataSource: ref.watch(qualityRemoteDataSourceProvider),
  );
});

final getQualityMetricsUseCaseProvider = Provider(
  (ref) => GetQualityMetrics(ref.watch(qualityRepositoryProvider)),
);

final qualityMetricsProvider = FutureProvider<QualityMetrics>((ref) async {
  final result = await ref
      .read(getQualityMetricsUseCaseProvider)
      .call(const NoParams());
  return result.fold((failure) => throw failure, (metrics) => metrics);
});

// --- Actualités (lecture seule) --------------------------------------------

final adminNewsRemoteDataSourceProvider = Provider<AdminNewsRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockProvider)) return MockAdminNewsRemoteDataSource();
  return AdminNewsRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final adminNewsRepositoryProvider = Provider<AdminNewsRepository>((ref) {
  return AdminNewsRepositoryImpl(
    remoteDataSource: ref.watch(adminNewsRemoteDataSourceProvider),
  );
});

final getAdminNewsUseCaseProvider = Provider(
  (ref) => GetAdminNews(ref.watch(adminNewsRepositoryProvider)),
);

final adminNewsProvider = FutureProvider<List<ActualiteAdmin>>((ref) async {
  final result = await ref
      .read(getAdminNewsUseCaseProvider)
      .call(const NoParams());
  return result.fold((failure) => throw failure, (list) => list);
});
