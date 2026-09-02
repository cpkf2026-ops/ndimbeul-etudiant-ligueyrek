import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/user_admin_repository.dart';

class SuspendUser implements UseCase<void, String> {
  const SuspendUser(this._repository);
  final UserAdminRepository _repository;

  @override
  Future<Result<void>> call(String id) {
    return _repository.suspendUser(id);
  }
}
