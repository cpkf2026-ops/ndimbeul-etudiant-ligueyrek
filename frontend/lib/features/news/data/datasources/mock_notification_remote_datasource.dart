import '../models/app_notification_model.dart';
import 'notification_remote_datasource.dart';

/// Jeu de données mocké — notifications in-app (voir §10).
class MockNotificationRemoteDataSource implements NotificationRemoteDataSource {
  static final List<AppNotificationModel> _notifications = [
    AppNotificationModel(
      id: 'notif_1',
      type: 'App\\Notifications\\NouvelleOffreCorrespondante',
      titre: '2 nouvelles offres correspondantes',
      corps: 'Développeur Flutter Junior chez Sonatel Digital et 1 autre offre à découvrir.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotificationModel(
      id: 'notif_2',
      type: 'App\\Notifications\\DateLimiteBourse',
      titre: 'Date limite bientôt atteinte',
      corps: 'La bourse d\'excellence UCAD ferme ses candidatures dans 5 jours.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotificationModel(
      id: 'notif_3',
      type: 'App\\Notifications\\NouvelleUniversite',
      titre: 'Nouvelle université référencée',
      corps: 'L\'Institut Africain de Management vient d\'être ajouté à la plateforme.',
      readAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<NotificationPageModel> getNotifications({
    bool nonLuesSeulement = false,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final filtered = nonLuesSeulement
        ? _notifications.where((n) => n.readAt == null).toList()
        : _notifications;
    return (
      items: List.of(filtered),
      nbNonLues: _notifications.where((n) => n.readAt == null).length,
      currentPage: page,
      lastPage: 1,
    );
  }

  @override
  Future<void> markAllRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].readAt == null) {
        _notifications[i] = _notifications[i].copyWith(readAt: DateTime.now());
      }
    }
  }

  @override
  Future<void> markRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(readAt: DateTime.now());
    }
  }
}
