import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../orientation/presentation/providers/recommendation_provider.dart';
import '../../data/datasources/mock_profile_remote_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profil_academique.dart';
import '../../domain/entities/profil_diplome.dart';
import '../../domain/entities/profil_etudiant.dart';
import '../../domain/entities/profil_lyceen.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profil_diplome.dart';
import '../../domain/usecases/update_profil_etudiant.dart';
import '../../domain/usecases/update_profil_lyceen.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockProfileRemoteDataSource();
  return ProfileRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(remoteDataSource: ref.watch(profileRemoteDataSourceProvider));
});

final getProfileUseCaseProvider = Provider((ref) => GetProfile(ref.watch(profileRepositoryProvider)));
final updateProfilLyceenUseCaseProvider =
    Provider((ref) => UpdateProfilLyceen(ref.watch(profileRepositoryProvider)));
final updateProfilEtudiantUseCaseProvider =
    Provider((ref) => UpdateProfilEtudiant(ref.watch(profileRepositoryProvider)));
final updateProfilDiplomeUseCaseProvider =
    Provider((ref) => UpdateProfilDiplome(ref.watch(profileRepositoryProvider)));

class ProfileNotifier extends AsyncNotifier<ProfilAcademique> {
  @override
  Future<ProfilAcademique> build() async {
    final result = await ref.read(getProfileUseCaseProvider).call(const NoParams());
    return result.fold((failure) => throw failure, (profil) => profil);
  }

  Future<Failure?> saveLyceen(ProfilLyceen profil) async {
    final previous = state;
    state = AsyncValue.data(ProfilAcademique.lyceen(profil));
    final result = await ref.read(updateProfilLyceenUseCaseProvider).call(
          UpdateProfilLyceenParams(profil),
        );
    return result.fold((failure) {
      state = previous;
      return failure;
    }, (updated) {
      state = AsyncValue.data(ProfilAcademique.lyceen(updated));
      // Les recommandations dépendent directement du profil (série, moyenne, passions,
      // matières fortes...) : sans invalidation, l'écran Orientation réafficherait la
      // liste calculée sur l'ANCIEN profil, en cache depuis le premier chargement.
      ref.invalidate(recommendationsProvider);
      return null;
    });
  }

  Future<Failure?> saveEtudiant(ProfilEtudiant profil) async {
    final previous = state;
    state = AsyncValue.data(ProfilAcademique.etudiant(profil));
    final result = await ref.read(updateProfilEtudiantUseCaseProvider).call(
          UpdateProfilEtudiantParams(profil),
        );
    return result.fold((failure) {
      state = previous;
      return failure;
    }, (updated) {
      state = AsyncValue.data(ProfilAcademique.etudiant(updated));
      return null;
    });
  }

  Future<Failure?> saveDiplome(ProfilDiplome profil) async {
    final previous = state;
    state = AsyncValue.data(ProfilAcademique.diplome(profil));
    final result = await ref.read(updateProfilDiplomeUseCaseProvider).call(
          UpdateProfilDiplomeParams(profil),
        );
    return result.fold((failure) {
      state = previous;
      return failure;
    }, (updated) {
      state = AsyncValue.data(ProfilAcademique.diplome(updated));
      return null;
    });
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfilAcademique>(
  ProfileNotifier.new,
);
