import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Result<NotificationPage>> getNotifications({
    bool nonLuesSeulement = false,
    int page = 1,
    int perPage = 20,
  });

  Future<Result<void>> markAllRead();

  Future<Result<void>> markRead(String id);
}
