import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/entity_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/actualite.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/news_provider.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Actualités'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Fil d\'actualités'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_NewsFeedTab(), _NotificationsTab()],
      ),
    );
  }
}

class _NewsFeedTab extends ConsumerWidget {
  const _NewsFeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsListProvider);
    final categorie = ref.watch(newsCategoryFilterProvider);
    final dateFormat = DateFormat('d MMM', 'fr_FR');

    return RefreshIndicator(
      onRefresh: () => ref.read(newsListProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Toutes'),
                      selected: categorie == null,
                      onSelected: (_) =>
                          ref.read(newsCategoryFilterProvider.notifier).state = null,
                    ),
                  ),
                  for (final cat in CategorieActualite.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.label),
                        selected: categorie == cat,
                        onSelected: (selected) => ref
                            .read(newsCategoryFilterProvider.notifier)
                            .state = selected ? cat : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
          newsAsync.when(
            loading: () => const SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(child: SkeletonCard(height: 140)),
            ),
            error: (error, _) => SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Impossible de charger les actualités',
                message: error is Failure ? error.message : null,
                actionLabel: 'Réessayer',
                onAction: () => ref.read(newsListProvider.notifier).refresh(),
              ),
            ),
            data: (page) => page.items.isEmpty
                ? const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.newspaper_outlined,
                      title: 'Aucune actualité dans cette catégorie',
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverList.separated(
                      itemCount: page.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final actu = page.items[i];
                        return _NewsCard(actualite: actu, dateFormat: dateFormat);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.actualite, required this.dateFormat});
  final Actualite actualite;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntityCard(
          imageUrl: actualite.imageUrl ?? '',
          title: actualite.categorie.label,
          subtitle: dateFormat.format(actualite.datePublication),
          width: 110,
          height: 110,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actualite.titre,
                style: context.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                actualite.contenu,
                style: context.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (actualite.auteur != null) ...[
                const SizedBox(height: 4),
                Text(actualite.auteur!, style: context.textTheme.labelSmall),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsTab extends ConsumerWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SkeletonLoader(height: 60),
            SizedBox(height: 10),
            SkeletonLoader(height: 60),
          ],
        ),
      ),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Impossible de charger les notifications',
        message: error is Failure ? error.message : null,
      ),
      data: (page) => page.items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Aucune notification',
            )
          : Column(
              children: [
                if (page.nbNonLues > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
                        child: const Text('Tout marquer comme lu'),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: page.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final notif = page.items[i];
                      return _NotificationTile(
                        notification: notif,
                        onTap: () =>
                            ref.read(notificationsProvider.notifier).markRead(notif.id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead ? AppColors.surface : AppColors.greenSoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: notification.isRead ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notification.isRead
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
                color: notification.isRead ? AppColors.textSecondary : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.titre, style: context.textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(notification.corps, style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
