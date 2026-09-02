import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/user_admin_repository.dart';

class DeleteUser implements UseCase<void, String> {
  const DeleteUser(this._repository);
  final UserAdminRepository _repository;

  @override
  Future<Result<void>> call(String id) {
    return _repository.deleteUser(id);
  }
}
