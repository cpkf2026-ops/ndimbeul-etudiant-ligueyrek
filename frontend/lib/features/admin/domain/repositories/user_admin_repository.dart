import '../../../../core/utils/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/admin_user.dart';

abstract interface class UserAdminRepository {
  /// UC14 — `GET /admin/users` (super_admin uniquement). [page]/[perPage]
  /// pilotent la pagination côté serveur (pas de méta de pagination exposée
  /// par le backend sur cet endpoint — voir note dans `admin_user_model.dart`).
  Future<Result<List<AdminUser>>> getUsers({
    UserRole? role,
    UserStatut? statut,
    int page = 1,
    int perPage = 20,
  });

  Future<Result<AdminUser>> updateUserRole({
    required String id,
    required UserRole role,
  });

  Future<Result<void>> suspendUser(String id);

  Future<Result<void>> reactivateUser(String id);

  Future<Result<void>> deleteUser(String id);
}
