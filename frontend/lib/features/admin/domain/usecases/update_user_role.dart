import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/admin_user.dart';
import '../repositories/user_admin_repository.dart';

class UpdateUserRoleParams {
  const UpdateUserRoleParams({required this.id, required this.role});
  final String id;
  final UserRole role;
}

class UpdateUserRole implements UseCase<AdminUser, UpdateUserRoleParams> {
  const UpdateUserRole(this._repository);
  final UserAdminRepository _repository;

  @override
  Future<Result<AdminUser>> call(UpdateUserRoleParams params) {
    return _repository.updateUserRole(id: params.id, role: params.role);
  }
}
