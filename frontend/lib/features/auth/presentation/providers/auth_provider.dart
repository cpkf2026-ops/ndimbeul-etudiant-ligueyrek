import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/mock_auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/complete_profile.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/refresh_token.dart';
import '../../domain/usecases/register.dart';

/// Point de bascule mock/API réelle pour la feature auth — lit
/// [useMockProvider] (core/di) pour choisir l'implémentation injectée.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  if (ref.watch(useMockProvider)) {
    return MockAuthRemoteDataSource(storage: storage);
  }
  return AuthRemoteDataSourceImpl(dio: ref.watch(dioProvider), storage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final loginUseCaseProvider = Provider((ref) => Login(ref.watch(authRepositoryProvider)));
final registerUseCaseProvider =
    Provider((ref) => Register(ref.watch(authRepositoryProvider)));
final completeProfileUseCaseProvider =
    Provider((ref) => CompleteProfile(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => Logout(ref.watch(authRepositoryProvider)));
final restoreSessionUseCaseProvider =
    Provider((ref) => RestoreSession(ref.watch(authRepositoryProvider)));

/// Source de vérité globale de l'état de connexion — utilisée par les
/// guards du router (redirection selon rôle / session).
class AuthNotifier extends AsyncNotifier<User?> {
  /// Vrai juste après un appel à [login] réussi, jusqu'à la prochaine
  /// lecture via [consumeJustLoggedIn] — distingue une vraie connexion
  /// (message de bienvenue à afficher) d'une simple restauration de
  /// session silencieuse au démarrage de l'app (voir [build]).
  bool _justLoggedIn = false;

  /// Lit puis réinitialise le flag ci-dessus — à appeler une seule fois par
  /// écran d'atterrissage (tableau de bord / back-office admin) pour
  /// déclencher le message de bienvenue sans le répéter à chaque rebuild.
  bool consumeJustLoggedIn() {
    final value = _justLoggedIn;
    _justLoggedIn = false;
    return value;
  }

  @override
  Future<User?> build() async {
    final result = await ref.read(restoreSessionUseCaseProvider).call(const NoParams());
    return result.fold((failure) => null, (user) => user);
  }

  Future<Failure?> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(loginUseCaseProvider)
        .call(LoginParams(email: email, password: password));
    return result.fold(
      (failure) {
        state = AsyncValue.data(state.valueOrNull);
        return failure;
      },
      (user) {
        _justLoggedIn = true;
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  Future<Failure?> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await ref.read(registerUseCaseProvider).call(
          RegisterParams(nom: nom, prenom: prenom, email: email, password: password),
        );
    return result.fold(
      (failure) {
        state = AsyncValue.data(state.valueOrNull);
        return failure;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  /// Étape "Compléter mon profil" : fixe le statut choisi et les champs
  /// spécifiques associés.
  Future<Failure?> completeProfile({
    required UserRole statut,
    required Map<String, dynamic> fields,
  }) async {
    final result = await ref
        .read(completeProfileUseCaseProvider)
        .call(CompleteProfileParams(statut: statut, fields: fields));
    return result.fold(
      (failure) => failure,
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call(const NoParams());
    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
