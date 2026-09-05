import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CompleteProfileParams {
  const CompleteProfileParams({required this.statut, required this.fields});

  /// Statut choisi par l'utilisateur (lycéen, étudiant ou diplômé/en poste/
  /// en stage) — devient son `role`.
  final UserRole statut;

  /// Champs spécifiques au statut, au format attendu par le backend
  /// (`serie_bac`, `universite_actuelle`, `dernier_diplome`...).
  final Map<String, dynamic> fields;
}

class CompleteProfile implements UseCase<User, CompleteProfileParams> {
  const CompleteProfile(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<User>> call(CompleteProfileParams params) {
    return _repository.completeProfile(statut: params.statut, fields: params.fields);
  }
}
