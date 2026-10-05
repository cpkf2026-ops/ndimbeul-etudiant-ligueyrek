import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/content_max_width.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/gradient_page_header.dart';
import '../../../../shared/widgets/region_dropdown_chip.dart';
import '../../../../shared/widgets/responsive_grid.dart';
import '../../../../shared/widgets/section_reveal.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/offre_emploi.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/job_type_style.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(jobFiltersProvider).domaine ?? '';
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(jobListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? _failureMessage(Object error) =>
      error is Failure ? error.message : 'Une erreur est survenue.';

  // `JobFilters.copyWith` ne sait pas remettre un champ à null — on
  // reconstruit donc l'objet explicitement pour pouvoir désélectionner.
  void _setFilters({
    required String? domaine,
    required String? region,
    required JobType? type,
  }) {
    ref.read(jobFiltersProvider.notifier).state =
        JobFilters(domaine: domaine, region: region, type: type);
  }

  void _resetFilters() {
    _searchController.clear();
    _setFilters(domaine: null, region: null, type: null);
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobListProvider);
    final filters = ref.watch(jobFiltersProvider);
    final hasFilters =
        filters.domaine != null || filters.region != null || filters.type != null;
    final horizontal = context.pageHorizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(jobListProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SectionReveal(
                child: GradientPageHeader(
                  eyebrow: 'Carrière',
                  straightTitle: 'Emplois, stages',
                  accentTitle: '& bourses',
                  subtitle: 'Les meilleures opportunités au Sénégal, vérifiées et mises à jour '
                      'chaque jour.',
                  actions: [
                    HeaderIconButton(
                      icon: Icons.bookmark_rounded,
                      tooltip: 'Offres suivies',
                      onTap: () => context.push(RoutePaths.jobsFavorites),
                    ),
                  ],
                  bottom: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: _HeaderSearch(
                      controller: _searchController,
                      region: filters.region,
                      onSubmitted: (value) => _setFilters(
                        domaine: value.trim().isEmpty ? null : value.trim(),
                        region: filters.region,
                        type: filters.type,
                      ),
                      onClear: () {
                        _searchController.clear();
                        _setFilters(domaine: null, region: filters.region, type: filters.type);
                      },
                      onRegionSelected: (region) => _setFilters(
                        domaine: filters.domaine,
                        region: region,
                        type: filters.type,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ContentMaxWidth(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 80),
                  child: SizedBox(
                    height: 64,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 6),
                      children: [
                        _TypePill(
                          label: 'Toutes',
                          icon: Icons.apps_rounded,
                          color: AppColors.primary,
                          selected: filters.type == null,
                          onTap: () => _setFilters(
                            domaine: filters.domaine,
                            region: filters.region,
                            type: null,
                          ),
                        ),
                        for (final type in JobType.values)
                          _TypePill(
                            label: type.label,
                            icon: type.icon,
                            color: type.color,
                            selected: filters.type == type,
                            onTap: () => _setFilters(
                              domaine: filters.domaine,
                              region: filters.region,
                              type: filters.type == type ? null : type,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ContentMaxWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: context.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: '${jobsAsync.valueOrNull?.total ?? '—'} ',
                                style: context.textTheme.titleMedium,
                              ),
                              const TextSpan(text: 'opportunités disponibles'),
                            ],
                          ),
                        ),
                      ),
                      if (hasFilters)
                        TextButton.icon(
                          onPressed: _resetFilters,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                          label: const Text('Réinitialiser'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (filters.region != null || filters.domaine != null)
              SliverToBoxAdapter(
                child: ContentMaxWidth(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (filters.domaine != null)
                          _ActiveFilterChip(
                            icon: Icons.search_rounded,
                            label: '« ${filters.domaine} »',
                            onRemove: () {
                              _searchController.clear();
                              _setFilters(
                                  domaine: null, region: filters.region, type: filters.type);
                            },
                          ),
                        if (filters.region != null)
                          _ActiveFilterChip(
                            icon: Icons.place_rounded,
                            label: filters.region!,
                            onRemove: () => _setFilters(
                                domaine: filters.domaine, region: null, type: filters.type),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            jobsAsync.when(
              loading: () => SliverToBoxAdapter(
                child: ContentMaxWidth(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    child: ResponsiveGrid(
                      desktopColumns: 2,
                      children: List.generate(4, (_) => const _JobCardSkeleton()),
                    ),
                  ),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Impossible de charger les offres',
                  message: _failureMessage(error),
                  actionLabel: 'Réessayer',
                  onAction: () => ref.read(jobListProvider.notifier).refresh(),
                ),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.work_off_outlined,
                      title: 'Aucune offre trouvée',
                      message: 'Essayez d\'élargir votre recherche ou revenez plus tard.',
                      actionLabel: hasFilters ? 'Effacer les filtres' : null,
                      onAction: hasFilters ? _resetFilters : null,
                    ),
                  );
                }

                Widget cardFor(OffreEmploi job) => JobCard(
                      job: job,
                      onTap: () => context.push(RoutePaths.jobDetailPath(job.id)),
                      onFavoriteTap: () async {
                        final failure =
                            await ref.read(jobListProvider.notifier).toggleFavorite(job);
                        if (failure != null && context.mounted) {
                          context.showSnack(failure.message, isError: true);
                        }
                      },
                    );

                return SliverToBoxAdapter(
                  child: ContentMaxWidth(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 110),
                      child: Column(
                        children: [
                          ResponsiveGrid(
                            desktopColumns: 2,
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              for (var i = 0; i < page.items.length; i++)
                                SectionReveal(
                                  delay: Duration(milliseconds: 40 * (i % 8)),
                                  child: cardFor(page.items[i]),
                                ),
                            ],
                          ),
                          if (page.hasMore)
                            const Padding(
                              padding: EdgeInsets.only(top: AppSpacing.lg),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSearch extends StatelessWidget {
  const _HeaderSearch({
    required this.controller,
    required this.region,
    required this.onSubmitted,
    required this.onClear,
    required this.onRegionSelected,
  });

  final TextEditingController controller;
  final String? region;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  /// Région choisie dans le menu déroulant — null = tout le Sénégal.
  final ValueChanged<String?> onRegionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Poste, domaine, entreprise…',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
            ),
          ),
          RegionDropdownChip(
            selected: region,
            onSelected: onRegionSelected,
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
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
        curve: Curves.easeOut,
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

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.close_rounded, size: 15, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCardSkeleton extends StatelessWidget {
  const _JobCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(width: 48, height: 48, borderRadius: 14),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(height: 14, width: 200),
                    SizedBox(height: 8),
                    SkeletonLoader(height: 12, width: 120),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              SkeletonLoader(height: 22, width: 70),
              SizedBox(width: 6),
              SkeletonLoader(height: 22, width: 90),
            ],
          ),
          SizedBox(height: 16),
          SkeletonLoader(height: 24, width: 110, borderRadius: 100),
        ],
      ),
    );
  }
}
