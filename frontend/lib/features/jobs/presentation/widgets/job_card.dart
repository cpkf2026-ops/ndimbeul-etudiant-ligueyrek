import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../domain/entities/offre_emploi.dart';

/// Carte offre d'emploi — utilisée dans la liste, les favoris et le fil
/// "à la une" du tableau de bord.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onFavoriteTap,
  });

  final OffreEmploi job;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

  Color get _typeColor {
    switch (job.type) {
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
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      job.type.label,
                      style: TextStyle(
                        color: _typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (job.expiree) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Expirée',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onFavoriteTap != null)
                    FavoriteButton(
                      isFavorite: job.estFavori,
                      onTap: onFavoriteTap!,
                      background: AppColors.background,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(job.intitule, style: context.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                job.entreprise,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(job.region, style: context.textTheme.labelSmall),
                  const SizedBox(width: 12),
                  const Icon(Icons.workspace_premium_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.niveauRequis ?? 'Tous niveaux',
                      style: context.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
