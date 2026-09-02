import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/admin_user.dart';
import '../repositories/user_admin_repository.dart';

class GetAdminUsersParams {
  const GetAdminUsersParams({
    this.role,
    this.statut,
    this.page = 1,
    this.perPage = 20,
  });

  final UserRole? role;
  final UserStatut? statut;
  final int page;
  final int perPage;
}

class GetAdminUsers implements UseCase<List<AdminUser>, GetAdminUsersParams> {
  const GetAdminUsers(this._repository);
  final UserAdminRepository _repository;

  @override
  Future<Result<List<AdminUser>>> call(GetAdminUsersParams params) {
    return _repository.getUsers(
      role: params.role,
      statut: params.statut,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
