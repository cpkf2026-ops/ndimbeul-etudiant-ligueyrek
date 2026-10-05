import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/mock_news_remote_datasource.dart';
import '../../data/datasources/mock_notification_remote_datasource.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/actualite.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_actualites.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_all_notifications_read.dart';
import '../../domain/usecases/mark_notification_read.dart';

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  // Fil réel (veille IA toutes les 2 h) même en mode démo — voir kUseMockNews.
  if (ref.watch(useMockProvider) && kUseMockNews) return MockNewsRemoteDataSource();
  return NewsRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    remoteDataSource: ref.watch(newsRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getActualitesUseCaseProvider =
    Provider((ref) => GetActualites(ref.watch(newsRepositoryProvider)));

final newsCategoryFilterProvider = StateProvider<CategorieActualite?>((ref) => null);

class NewsListNotifier extends AsyncNotifier<ActualitePage> {
  @override
  Future<ActualitePage> build() async {
    // Rechargement automatique (voir kRafraichissementFils) : le minuteur est
    // réarmé à chaque chargement et annulé si le provider est détruit. Pendant
    // le rechargement, la liste actuelle reste affichée (pas d'écran vide).
    final minuteur = Timer(kRafraichissementFils, ref.invalidateSelf);
    ref.onDispose(minuteur.cancel);
    final categorie = ref.watch(newsCategoryFilterProvider);
    final result =
        await ref.read(getActualitesUseCaseProvider).call(GetActualitesParams(categorie: categorie));
    return result.fold((failure) => throw failure, (page) => page);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final newsListProvider = AsyncNotifierProvider<NewsListNotifier, ActualitePage>(
  NewsListNotifier.new,
);

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  if (ref.watch(useMockProvider)) return MockNotificationRemoteDataSource();
  return NotificationRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

final getNotificationsUseCaseProvider =
    Provider((ref) => GetNotifications(ref.watch(notificationRepositoryProvider)));
final markAllNotificationsReadUseCaseProvider =
    Provider((ref) => MarkAllNotificationsRead(ref.watch(notificationRepositoryProvider)));
final markNotificationReadUseCaseProvider =
    Provider((ref) => MarkNotificationRead(ref.watch(notificationRepositoryProvider)));

class NotificationsNotifier extends AsyncNotifier<NotificationPage> {
  @override
  Future<NotificationPage> build() async {
    final result =
        await ref.read(getNotificationsUseCaseProvider).call(const GetNotificationsParams());
    return result.fold((failure) => throw failure, (page) => page);
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.items
        .map((n) => n.id == id ? n.copyWith(readAt: DateTime.now()) : n)
        .toList();
    state = AsyncValue.data(
      NotificationPage(
        items: updated,
        nbNonLues: (current.nbNonLues - 1).clamp(0, 999),
        currentPage: current.currentPage,
        lastPage: current.lastPage,
      ),
    );
    await ref.read(markNotificationReadUseCaseProvider).call(id);
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.items.map((n) => n.copyWith(readAt: DateTime.now())).toList();
    state = AsyncValue.data(
      NotificationPage(
        items: updated,
        nbNonLues: 0,
        currentPage: current.currentPage,
        lastPage: current.lastPage,
      ),
    );
    await ref.read(markAllNotificationsReadUseCaseProvider).call(const NoParams());
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, NotificationPage>(
  NotificationsNotifier.new,
);
