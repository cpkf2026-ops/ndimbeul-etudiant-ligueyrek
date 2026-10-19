import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../admin/presentation/widgets/bouton_ajout_admin.dart';
import '../../../../app/router/route_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/content_max_width.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/gradient_page_header.dart';
import '../../../../shared/widgets/responsive_grid.dart';
import '../../../../shared/widgets/section_reveal.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/actualite.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/news_provider.dart';
import '../providers/veille_etat_provider.dart';

/// Couleur + icône par catégorie d'actualité.
extension _CategorieStyle on CategorieActualite {
  Color get color => switch (this) {
        CategorieActualite.bourse => const Color(0xFFD9534F),
        CategorieActualite.concours => const Color(0xFF8A5CD0),
        CategorieActualite.evenement => AppColors.info,
        CategorieActualite.formation => AppColors.accentDark,
        CategorieActualite.general => const Color(0xFF1F7A5A),
      };

  IconData get icon => switch (this) {
        CategorieActualite.bourse => Icons.savings_rounded,
        CategorieActualite.concours => Icons.emoji_events_rounded,
        CategorieActualite.evenement => Icons.event_rounded,
        CategorieActualite.formation => Icons.menu_book_rounded,
        CategorieActualite.general => Icons.public_rounded,
      };
}

/// "il y a 5 min", "il y a 3 h", "hier", "12 mars".
String _relativeDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.isNegative || diff.inMinutes < 1) return 'à l\'instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays == 1) return 'hier';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  return DateFormat('d MMM yyyy', 'fr_FR').format(date);
}

Future<void> _ouvrirSource(BuildContext context, Actualite actualite) async {
  final url = actualite.sourceUrl;
  if (url == null || url.isEmpty) {
    context.showSnack('Aucun lien source disponible pour cette actualité.');
    return;
  }
  final ouvert = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ouvert && context.mounted) {
    context.showSnack('Impossible d\'ouvrir le lien.', isError: true);
  }
}

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(notificationsProvider).valueOrNull?.nbNonLues ?? 0;

    return Scaffold(
      // Visible seulement pour les administrateurs (ajout assisté par l'IA).
      floatingActionButton: const BoutonAjoutAdmin(libelle: 'Ajouter une actualité', route: RoutePaths.adminAjoutActualite),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          if (_tab == 0) {
            ref.invalidate(veilleEtatProvider);
            await ref.read(newsListProvider.notifier).refresh();
          } else {
            ref.invalidate(notificationsProvider);
            await ref.read(notificationsProvider.future);
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SectionReveal(
                child: GradientPageHeader(
                  eyebrow: 'Infos & alertes',
                  straightTitle: 'Restez',
                  accentTitle: 'informé.',
                  subtitle: 'Bourses, concours, événements : l\'essentiel de la vie '
                      'étudiante au Sénégal.',
                  actions: [
                    HeaderIconButton(
                      icon: Icons.notifications_rounded,
                      tooltip: 'Notifications',
                      badgeCount: unread,
                      onTap: () => setState(() => _tab = 1),
                    ),
                  ],
                  bottom: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _SegmentedTabs(
                      index: _tab,
                      unread: unread,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                  ),
                ),
              ),
            ),
            if (_tab == 0) ..._feedSlivers(context) else ..._notificationSlivers(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Fil d'actualités
  // ---------------------------------------------------------------------------

  List<Widget> _feedSlivers(BuildContext context) {
    final newsAsync = ref.watch(newsListProvider);
    final categorie = ref.watch(newsCategoryFilterProvider);
    final horizontal = context.pageHorizontalPadding;

    void select(CategorieActualite? cat) =>
        ref.read(newsCategoryFilterProvider.notifier).state = cat;

    return [
      SliverToBoxAdapter(
        child: ContentMaxWidth(
          maxWidth: 1200,
          child: SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 6),
              children: [
                _CategoryPill(
                  label: 'Tout',
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  selected: categorie == null,
                  onTap: () => select(null),
                ),
                for (final cat in CategorieActualite.values)
                  _CategoryPill(
                    label: cat.label,
                    icon: cat.icon,
                    color: cat.color,
                    selected: categorie == cat,
                    onTap: () => select(categorie == cat ? null : cat),
                  ),
              ],
            ),
          ),
        ),
      ),
      ...newsAsync.when(
        loading: () => [
          SliverToBoxAdapter(
            child: ContentMaxWidth(
              maxWidth: 1200,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 0),
                child: const Column(
                  children: [
                    SkeletonLoader(height: 240, borderRadius: 24),
                    SizedBox(height: 16),
                    SkeletonLoader(height: 110, borderRadius: 20),
                    SizedBox(height: 12),
                    SkeletonLoader(height: 110, borderRadius: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
        error: (error, _) => [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Impossible de charger les actualités',
              message: error is Failure ? error.message : null,
              actionLabel: 'Réessayer',
              onAction: () => ref.read(newsListProvider.notifier).refresh(),
            ),
          ),
        ],
        data: (page) {
          if (page.items.isEmpty) {
            return [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.newspaper_rounded,
                  title: 'Rien de neuf par ici',
                  message: 'Aucune actualité dans cette catégorie pour le moment.',
                  actionLabel: categorie != null ? 'Voir toutes les actualités' : null,
                  onAction: categorie != null ? () => select(null) : null,
                ),
              ),
            ];
          }

          final featured = page.items.first;
          final rest = page.items.skip(1).toList();
          final isMobile = context.isMobile;
          final derniereMaj = page.items
              .map((a) => a.dateIndexation)
              .whereType<DateTime>()
              .fold<DateTime?>(null, (max, d) => max == null || d.isAfter(max) ? d : max);

          return [
            SliverToBoxAdapter(
              child: ContentMaxWidth(
                maxWidth: 1200,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 4),
                  child: SectionReveal(child: _AiWatchBanner(derniereMaj: derniereMaj)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ContentMaxWidth(
                maxWidth: 1200,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 0),
                  child: SectionReveal(
                    delay: const Duration(milliseconds: 60),
                    child: _FeaturedNewsCard(actualite: featured),
                  ),
                ),
              ),
            ),
            if (rest.isNotEmpty)
              SliverToBoxAdapter(
                child: ContentMaxWidth(
                  maxWidth: 1200,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontal, 26, horizontal, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Dernières actualités', style: context.textTheme.headlineMedium),
                        const Spacer(),
                        Text('${page.total} articles', style: context.textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: ContentMaxWidth(
                maxWidth: 1200,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 110),
                  child: ResponsiveGrid(
                    tabletColumns: 2,
                    desktopColumns: 3,
                    spacing: 16,
                    runSpacing: isMobile ? 12 : 16,
                    children: [
                      for (var i = 0; i < rest.length; i++)
                        SectionReveal(
                          delay: Duration(milliseconds: 40 * (i % 9) + 100),
                          child: isMobile
                              ? _CompactNewsCard(actualite: rest[i])
                              : _GridNewsCard(actualite: rest[i]),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  List<Widget> _notificationSlivers(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final horizontal = context.pageHorizontalPadding;

    return notificationsAsync.when(
      loading: () => [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 0),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) => const SkeletonLoader(height: 76, borderRadius: 18),
          ),
        ),
      ],
      error: (error, _) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Impossible de charger les notifications',
            message: error is Failure ? error.message : null,
            actionLabel: 'Réessayer',
            onAction: () => ref.invalidate(notificationsProvider),
          ),
        ),
      ],
      data: (page) {
        if (page.items.isEmpty) {
          return [
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.notifications_off_rounded,
                title: 'Vous êtes à jour',
                message: 'Aucune notification pour le moment. Nous vous préviendrons '
                    'dès qu\'une opportunité vous correspond.',
              ),
            ),
          ];
        }

        final groups = <String, List<AppNotification>>{};
        for (final n in page.items) {
          groups.putIfAbsent(_groupLabel(n.createdAt), () => []).add(n);
        }

        return [
          SliverToBoxAdapter(
            child: ContentMaxWidth(
              maxWidth: 820,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal - 8, 0),
                child: Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        style: context.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${page.nbNonLues} ',
                            style: context.textTheme.titleMedium,
                          ),
                          TextSpan(text: page.nbNonLues > 1 ? 'non lues' : 'non lue'),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (page.nbNonLues > 0)
                      TextButton.icon(
                        onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('Tout marquer comme lu'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ContentMaxWidth(
              maxWidth: 820,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 10),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: context.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final notif in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SectionReveal(
                            child: _NotificationTile(
                              notification: notif,
                              onTap: () =>
                                  ref.read(notificationsProvider.notifier).markRead(notif.id),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ];
      },
    );
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Cette semaine';
    return 'Plus ancien';
  }
}

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.index, required this.unread, required this.onChanged});
  final int index;
  final int unread;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final half = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: index * half,
                top: 0,
                bottom: 0,
                width: half,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _segment(0, Icons.newspaper_rounded, 'Fil d\'actualités'),
                  _segment(1, Icons.notifications_rounded, 'Notifications', badge: unread),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _segment(int i, IconData icon, String label, {int badge = 0}) {
    final selected = index == i;
    final fg = selected ? AppColors.primary : Colors.white;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? color : AppColors.border),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: selected ? Colors.white : color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Image d'actualité — réseau, asset local ou repli dégradé + icône de
/// catégorie quand aucune image n'est disponible.
class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.actualite, this.iconSize = 40});
  final Actualite actualite;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = actualite.imageUrl ?? '';
    final fallback = _ImageFallback(categorie: actualite.categorie, iconSize: iconSize);
    if (url.isEmpty) return fallback;
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => const SkeletonLoader(height: double.infinity, borderRadius: 0),
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.categorie, required this.iconSize});
  final CategorieActualite categorie;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = categorie.color;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c, Color.lerp(c, AppColors.primary, 0.55)!],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -iconSize * 0.4,
            bottom: -iconSize * 0.4,
            child: Icon(categorie.icon,
                size: iconSize * 2.6, color: Colors.white.withValues(alpha: 0.12)),
          ),
          Center(
            child: Icon(categorie.icon,
                size: iconSize, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.categorie, this.solid = false});
  final CategorieActualite categorie;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final c = categorie.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? Colors.white : c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categorie.icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            categorie.label,
            style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Grande carte "À la une" — image plein cadre, voile dégradé, titre blanc.
class _FeaturedNewsCard extends StatelessWidget {
  const _FeaturedNewsCard({required this.actualite});
  final Actualite actualite;

  @override
  Widget build(BuildContext context) {
    final date = actualite.dateIndexation ?? actualite.datePublication;
    final height = context.isMobile ? 260.0 : 340.0;

    return _Hoverable(
      borderRadius: 24,
      onTap: () => _ouvrirSource(context, actualite),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _NewsImage(actualite: actualite, iconSize: 64),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.95),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'À LA UNE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(categorie: actualite.categorie, solid: true),
                  const SizedBox(height: 10),
                  Text(
                    actualite.titre,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: context.isMobile ? 20 : 26,
                      height: 1.25,
                    ),
                  ),
                  if (!context.isMobile) ...[
                    const SizedBox(height: 8),
                    Text(
                      actualite.contenu,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 14, color: Colors.white.withValues(alpha: 0.75)),
                      const SizedBox(width: 4),
                      Text(
                        _relativeDate(date),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                      if (actualite.auteur != null) ...[
                        Text('  •  ',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                        if (actualite.sourceVerifiee) ...[
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            actualite.auteur!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      const _ReadButton(onDark: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte compacte (mobile) — vignette à gauche, texte à droite.
class _CompactNewsCard extends StatelessWidget {
  const _CompactNewsCard({required this.actualite});
  final Actualite actualite;

  @override
  Widget build(BuildContext context) {
    final date = actualite.dateIndexation ?? actualite.datePublication;

    return _Hoverable(
      borderRadius: 20,
      bordered: true,
      onTap: () => _ouvrirSource(context, actualite),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 96,
                height: 104,
                child: _NewsImage(actualite: actualite, iconSize: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 104,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CategoryBadge(categorie: actualite.categorie),
                        const Spacer(),
                        Text(_relativeDate(date), style: context.textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      actualite.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(height: 1.3),
                    ),
                    const Spacer(),
                    _SourceLine(actualite: actualite),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte verticale (tablette/desktop) — image en haut, texte en dessous.
class _GridNewsCard extends StatelessWidget {
  const _GridNewsCard({required this.actualite});
  final Actualite actualite;

  @override
  Widget build(BuildContext context) {
    return _Hoverable(
      borderRadius: 20,
      bordered: true,
      onTap: () => _ouvrirSource(context, actualite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _NewsImage(actualite: actualite),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _CategoryBadge(categorie: actualite.categorie, solid: true),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 42,
                  child: Text(
                    actualite.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(height: 1.3),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: Text(
                    actualite.contenu,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _SourceLine(actualite: actualite, showDate: true)),
                    const SizedBox(width: 8),
                    const _ReadButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau en tête du fil : explique que les actualités sont collectées et
/// vérifiées automatiquement par l'IA, et quand a eu lieu le dernier passage.
class _AiWatchBanner extends ConsumerWidget {
  const _AiWatchBanner({required this.derniereMaj});
  final DateTime? derniereMaj;

  /// « vérifiée il y a 20 min · aucune nouveauté · prochaine vers 03:20 » : montre que la
  /// veille passe bien toutes les 2 h même quand elle ne trouve rien de neuf.
  String _texte(EtatVeille? etat) {
    if (etat?.derniereVerification == null) {
      return derniereMaj == null
          ? 'Sources officielles et presse reconnue uniquement, articles récents vérifiés.'
          : 'Sources officielles et presse reconnue · dernier ajout ${_relativeDate(derniereMaj!)}';
    }
    final resultat = etat!.ajoutes == 0
        ? 'aucune nouveauté'
        : '${etat.ajoutes} nouveauté${etat.ajoutes > 1 ? 's' : ''}';
    final prochaine = etat.prochainPassage == null
        ? ''
        : ' · prochaine vers ${DateFormat('HH:mm').format(etat.prochainPassage!)}';
    return 'Vérifiée ${_relativeDate(etat.derniereVerification!)} · $resultat$prochaine';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etat = ref.watch(veilleEtatProvider).valueOrNull?['actualites'];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veille IA — mise à jour toutes les 2 h',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                Text(_texte(etat), style: context.textTheme.labelSmall),
              ],
            ),
          ),
          const Icon(Icons.verified_user_rounded, size: 20, color: AppColors.success),
        ],
      ),
    );
  }
}

/// Média d'origine + badge de fiabilité ("Officiel" / "Vérifié").
class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.actualite, this.showDate = false});
  final Actualite actualite;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final officiel = actualite.sourceOfficielle;
    final verifie = actualite.sourceVerifiee;
    final couleur = officiel ? AppColors.info : AppColors.success;
    final date = actualite.datePublication;

    return Row(
      children: [
        if (verifie) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  officiel ? Icons.account_balance_rounded : Icons.verified_rounded,
                  size: 11,
                  color: couleur,
                ),
                const SizedBox(width: 3),
                Text(
                  officiel ? 'Officiel' : 'Vérifié',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: couleur),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            [
              if (actualite.auteur != null) actualite.auteur!,
              if (showDate) _relativeDate(date),
            ].join('  •  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ReadButton extends StatelessWidget {
  const _ReadButton({this.onDark = false});
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? AppColors.primary : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onDark ? AppColors.accent : AppColors.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Lire', style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 3),
          Icon(Icons.north_east_rounded, size: 13, color: fg),
        ],
      ),
    );
  }
}

/// Conteneur cliquable avec légère élévation au survol (web/desktop).
class _Hoverable extends StatefulWidget {
  const _Hoverable({
    required this.child,
    required this.onTap,
    required this.borderRadius,
    this.bordered = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final bool bordered;

  @override
  State<_Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<_Hoverable> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: widget.bordered ? Border.all(color: AppColors.border) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: _hovered ? 0.12 : 0.05),
              blurRadius: _hovered ? 26 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: widget.onTap, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  ({IconData icon, Color color}) get _style {
    final t = '${notification.type} ${notification.titre}'.toLowerCase();
    if (t.contains('bourse')) return (icon: Icons.savings_rounded, color: const Color(0xFFD9534F));
    if (t.contains('offre') || t.contains('job') || t.contains('emploi') || t.contains('stage')) {
      return (icon: Icons.work_rounded, color: AppColors.info);
    }
    if (t.contains('concours')) {
      return (icon: Icons.emoji_events_rounded, color: const Color(0xFF8A5CD0));
    }
    if (t.contains('universit') || t.contains('formation')) {
      return (icon: Icons.school_rounded, color: AppColors.accentDark);
    }
    return (icon: Icons.notifications_rounded, color: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final unread = !notification.isRead;

    return Material(
      color: unread ? AppColors.surface : AppColors.surface.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: unread ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unread ? style.color.withValues(alpha: 0.3) : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: unread ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  style.icon,
                  size: 20,
                  color: unread ? style.color : style.color.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                              color: unread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _relativeDate(notification.createdAt),
                          style: context.textTheme.labelSmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.corps,
                      style: context.textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
