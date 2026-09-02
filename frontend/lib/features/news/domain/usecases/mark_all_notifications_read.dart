import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsRead implements UseCase<void, NoParams> {
  const MarkAllNotificationsRead(this._repository);
  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.markAllRead();
}
