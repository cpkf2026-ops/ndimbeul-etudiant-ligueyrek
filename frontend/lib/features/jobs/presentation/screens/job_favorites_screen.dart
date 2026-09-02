import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

class JobFavoritesScreen extends ConsumerWidget {
  const JobFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(jobFavoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Offres suivies')),
      body: favoritesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonCard(height: 120),
              SizedBox(height: 12),
              SkeletonCard(height: 120),
            ],
          ),
        ),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Impossible de charger vos favoris',
          message: error is Failure ? error.message : null,
        ),
        data: (jobs) => jobs.isEmpty
            ? EmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'Aucune offre suivie',
                message: 'Ajoutez des offres à vos favoris depuis la liste des offres.',
                actionLabel: 'Voir les offres',
                onAction: () => context.go(RoutePaths.jobs),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final job = jobs[i];
                  return JobCard(
                    job: job,
                    onTap: () => context.push(RoutePaths.jobDetailPath(job.id)),
                    onFavoriteTap: () => ref.read(jobFavoritesProvider.notifier).remove(job.id),
                  );
                },
              ),
      ),
    );
  }
}
