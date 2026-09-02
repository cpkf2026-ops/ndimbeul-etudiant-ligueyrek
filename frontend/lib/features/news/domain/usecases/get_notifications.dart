import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsParams {
  const GetNotificationsParams({
    this.nonLuesSeulement = false,
    this.page = 1,
    this.perPage = 20,
  });
  final bool nonLuesSeulement;
  final int page;
  final int perPage;
}

class GetNotifications implements UseCase<NotificationPage, GetNotificationsParams> {
  const GetNotifications(this._repository);
  final NotificationRepository _repository;

  @override
  Future<Result<NotificationPage>> call(GetNotificationsParams params) {
    return _repository.getNotifications(
      nonLuesSeulement: params.nonLuesSeulement,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
