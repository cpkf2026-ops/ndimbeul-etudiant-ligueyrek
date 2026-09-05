import '../../../../core/utils/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> login({required String email, required String password});

  /// Inscription minimale : identité + mot de passe. Le statut est choisi
  /// séparément via [completeProfile].
  Future<Result<User>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  });

  /// Fixe le statut (lycéen/étudiant/diplômé) et les champs spécifiques
  /// associés, puis passe `profilComplete` à true.
  Future<Result<User>> completeProfile({
    required UserRole statut,
    required Map<String, dynamic> fields,
  });

  Future<Result<void>> logout();

  Future<Result<User?>> getCurrentUser();

  Future<Result<void>> forgotPassword({required String email});
}
