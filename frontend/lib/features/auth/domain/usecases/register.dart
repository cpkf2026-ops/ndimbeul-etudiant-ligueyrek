import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
  });

  final String nom;
  final String prenom;
  final String email;
  final String password;
}

class Register implements UseCase<User, RegisterParams> {
  const Register(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<User>> call(RegisterParams params) {
    return _repository.register(
      nom: params.nom,
      prenom: params.prenom,
      email: params.email,
      password: params.password,
    );
  }
}
