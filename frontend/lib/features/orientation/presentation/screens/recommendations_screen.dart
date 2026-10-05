import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/recommandation.dart';
import '../providers/recommendation_provider.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes recommandations')),
      body: recommendationsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [SkeletonCard(height: 140), SizedBox(height: 12), SkeletonCard(height: 140)],
          ),
        ),
        error: (error, _) {
          if (error is ValidationFailure) {
            return EmptyState(
              icon: Icons.assignment_late_outlined,
              title: 'Profil incomplet',
              message: error.message,
              actionLabel: 'Compléter mon profil',
              // go() : /profile est un autre branch de la StatefulShellRoute, voir
              // orientation_screen.dart pour la même correction.
              onAction: () => context.go(RoutePaths.profile),
            );
          }
          return EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Recommandations indisponibles',
            message: error is Failure ? error.message : null,
            actionLabel: 'Réessayer',
            onAction: () => ref.invalidate(recommendationsProvider),
          );
        },
        data: (recommendations) => recommendations.isEmpty
            ? const EmptyState(
                icon: Icons.auto_awesome_outlined,
                title: 'Pas encore de suggestions',
                message: 'Revenez bientôt, nos suggestions se mettent à jour régulièrement.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: recommendations.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  if (i == 0) return const _NonBindingNotice();
                  return _RecommendationCard(recommendation: recommendations[i - 1]);
                },
              ),
      ),
    );
  }
}

class _NonBindingNotice extends StatelessWidget {
  const _NonBindingNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ces suggestions sont une aide non contraignante — pas un classement '
              'définitif. Explorez, comparez, décidez selon votre propre projet.',
              style: context.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});
  final Recommandation recommendation;

  Color get _scoreColor {
    if (recommendation.scoreCorrespondance >= 85) return AppColors.success;
    if (recommendation.scoreCorrespondance >= 60) return AppColors.accentDark;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recommendation.intitule, style: context.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      [
                        recommendation.universiteNom,
                        if (recommendation.universiteRegion != null)
                          recommendation.universiteRegion!,
                      ].join(' — '),
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${recommendation.scoreCorrespondance.round()}%',
                  style: TextStyle(color: _scoreColor, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(recommendation.explicationLlm, style: context.textTheme.bodyLarge),
          if (recommendation.conditionsAdmission != null &&
              recommendation.conditionsAdmission!.seriesAcceptees.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.checklist_rounded,
              label: 'Séries acceptées',
              value: recommendation.conditionsAdmission!.seriesAcceptees.join(', '),
            ),
          ],
          if (recommendation.conditionsAdmission?.moyenneMinimale != null) ...[
            const SizedBox(height: 4),
            _InfoLine(
              icon: Icons.grade_outlined,
              label: 'Moyenne minimale',
              value: '${recommendation.conditionsAdmission!.moyenneMinimale}/20',
            ),
          ],
          if (recommendation.debouches != null && recommendation.debouches!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoLine(
              icon: Icons.trending_up_rounded,
              label: 'Débouchés',
              value: recommendation.debouches!,
            ),
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () =>
                  context.push(RoutePaths.universityDetailPath(recommendation.universiteId)),
              child: const Text('Voir la fiche université'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label : ', style: context.textTheme.labelSmall),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
