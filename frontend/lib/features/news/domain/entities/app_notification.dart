import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

/// Notification in-app — reflète une ligne de la table Laravel standard
/// `notifications` (DatabaseNotification), consultée via NotificationController.
/// `titre`/`corps` sont dérivés côté modèle (data/models) à partir de
/// l'enveloppe brute `data`, de façon défensive (voir AppNotificationModel).
@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String type,
    required String titre,
    required String corps,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _AppNotification;

  const AppNotification._();

  bool get isRead => readAt != null;
}

/// Page de résultats paginés de notifications (voir NotificationController::index meta).
@freezed
sealed class NotificationPage with _$NotificationPage {
  const factory NotificationPage({
    required List<AppNotification> items,
    required int nbNonLues,
    required int currentPage,
    required int lastPage,
  }) = _NotificationPage;

  const NotificationPage._();

  bool get hasMore => currentPage < lastPage;
}
