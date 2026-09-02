import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Titre de section horizontale scrollable + lien "Voir tout" (Actualités,
/// Universités d'Excellence, Logements à proximité, Entreprises Partenaires).
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    'Voir tout',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
