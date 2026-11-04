import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/constants/app_images.dart';
import '../../../../core/error/failures.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/content_max_width.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/gradient_page_header.dart';
import '../../../../shared/widgets/responsive_grid.dart';
import '../../../../shared/widgets/section_reveal.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

class JobFavoritesScreen extends ConsumerWidget {
  const JobFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(jobFavoritesProvider);
    final horizontal = context.pageHorizontalPadding;
    final count = favoritesAsync.valueOrNull?.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientPageHeader(
              imageFond: AppImages.dashboardHero,
              leading: HeaderIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Retour',
                onTap: () => Navigator.of(context).maybePop(),
              ),
              eyebrow: 'Mes favoris',
              straightTitle: 'Offres',
              accentTitle: 'suivies',
              subtitle: count == null
                  ? 'Retrouvez ici les opportunités que vous avez sauvegardées.'
                  : '$count offre${count > 1 ? 's' : ''} sauvegardée${count > 1 ? 's' : ''} '
                      '— ne manquez aucune date limite.',
            ),
          ),
          favoritesAsync.when(
            loading: () => SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 0),
              sliver: const SliverToBoxAdapter(
                child: Column(
                  children: [
                    SkeletonLoader(height: 150, borderRadius: 20),
                    SizedBox(height: 14),
                    SkeletonLoader(height: 150, borderRadius: 20),
                  ],
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Impossible de charger vos favoris',
                message: error is Failure ? error.message : null,
                actionLabel: 'Réessayer',
                onAction: () => ref.invalidate(jobFavoritesProvider),
              ),
            ),
            data: (jobs) => jobs.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.bookmark_border_rounded,
                      title: 'Aucune offre suivie',
                      message: 'Touchez le cœur sur une offre pour la retrouver ici.',
                      actionLabel: 'Explorer les offres',
                      onAction: () => context.go(RoutePaths.jobs),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: ContentMaxWidth(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 40),
                        child: ResponsiveGrid(
                          desktopColumns: 2,
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            for (var i = 0; i < jobs.length; i++)
                              SectionReveal(
                                delay: Duration(milliseconds: 40 * (i % 8)),
                                child: JobCard(
                                  job: jobs[i],
                                  onTap: () =>
                                      context.push(RoutePaths.jobDetailPath(jobs[i].id)),
                                  onFavoriteTap: () => ref
                                      .read(jobFavoritesProvider.notifier)
                                      .remove(jobs[i].id),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
