import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/offre_emploi.dart';
import '../providers/job_provider.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Détail de l\'offre')),
      body: jobAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonLoader(height: 24, width: 220),
              SizedBox(height: 12),
              SkeletonLoader(height: 16),
              SizedBox(height: 8),
              SkeletonLoader(height: 100),
            ],
          ),
        ),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Offre introuvable',
          message: error is Failure ? error.message : null,
        ),
        data: (job) => _JobDetailBody(job: job),
      ),
    );
  }
}

class _JobDetailBody extends ConsumerWidget {
  const _JobDetailBody({required this.job});
  final OffreEmploi job;

  Color _typeColor(JobType type) {
    switch (type) {
      case JobType.emploi:
        return AppColors.info;
      case JobType.stage:
        return AppColors.primary;
      case JobType.alternance:
        return AppColors.accentDark;
      case JobType.formation:
        return AppColors.success;
      case JobType.bourse:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _typeColor(job.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  job.type.label,
                  style: TextStyle(
                    color: _typeColor(job.type),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              FavoriteButton(
                isFavorite: job.estFavori,
                background: AppColors.background,
                onTap: () async {
                  final notifier = ref.read(jobListProvider.notifier);
                  final failure = await notifier.toggleFavorite(job);
                  ref.invalidate(jobDetailProvider(job.id));
                  if (failure != null && context.mounted) {
                    context.showSnack(failure.message, isError: true);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(job.intitule, style: context.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            job.entreprise,
            style: context.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.place_outlined, label: 'Région', value: job.region),
          _InfoRow(icon: Icons.category_outlined, label: 'Domaine', value: job.domaine),
          _InfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Niveau requis',
            value: job.niveauRequis ?? 'Tous niveaux',
          ),
          if (job.dateLimite != null)
            _InfoRow(
              icon: Icons.event_busy_outlined,
              label: 'Date limite',
              value: dateFormat.format(job.dateLimite!),
              valueColor: job.expiree ? AppColors.error : null,
            ),
          const SizedBox(height: 20),
          Text('Description', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(job.description, style: context.textTheme.bodyMedium),
          const SizedBox(height: 28),
          if (job.sourceUrl != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(job.sourceUrl!),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text('Voir sur ${job.source ?? 'le site source'}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: context.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
