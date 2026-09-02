import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

class Login implements UseCase<User, LoginParams> {
  const Login(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<User>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}
