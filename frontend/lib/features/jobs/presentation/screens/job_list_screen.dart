import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/search_bar_custom.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/offre_emploi.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(jobListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String? _failureMessage(Object error) =>
      error is Failure ? error.message : 'Une erreur est survenue.';

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobListProvider);
    final filters = ref.watch(jobFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Emploi, stages & bourses'),
        actions: [
          IconButton(
            onPressed: () => context.push(RoutePaths.jobsFavorites),
            icon: const Icon(Icons.bookmark_outline_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(jobListProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBarCustom(
                  hint: 'Domaine, entreprise, région...',
                  onSubmitted: (value) => ref.read(jobFiltersProvider.notifier).state =
                      filters.copyWith(domaine: value.isEmpty ? null : value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final type in JobType.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type.label),
                          selected: filters.type == type,
                          onSelected: (selected) {
                            ref.read(jobFiltersProvider.notifier).state = filters.copyWith(
                              type: selected ? type : null,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            jobsAsync.when(
              loading: () => const SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(child: SkeletonCard(height: 120)),
              ),
              error: (error, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Impossible de charger les offres',
                  message: _failureMessage(error),
                  actionLabel: 'Réessayer',
                  onAction: () => ref.read(jobListProvider.notifier).refresh(),
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.work_off_outlined,
                        title: 'Aucune offre trouvée',
                        message: 'Modifiez vos filtres ou revenez plus tard.',
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList.separated(
                        itemCount: page.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final job = page.items[i];
                          return JobCard(
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
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
