import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Restaure la session au démarrage de l'app (le refresh du JWT lui-même
/// est géré de façon transparente par [AuthInterceptor] côté core/network).
class RestoreSession implements UseCase<User?, NoParams> {
  const RestoreSession(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<User?>> call(NoParams params) =>
      _repository.getCurrentUser();
}
