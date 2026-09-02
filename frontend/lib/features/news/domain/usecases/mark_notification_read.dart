import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationRead implements UseCase<void, String> {
  const MarkNotificationRead(this._repository);
  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.markRead(id);
}
