import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_logo_button.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../profile/domain/entities/profil_academique.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Hub Orientation — accessible depuis l'onglet 2 de la navigation
/// principale : complétude du profil, accès aux recommandations et à la
/// simulation de parcours.
class OrientationScreen extends ConsumerWidget {
  const OrientationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: AppLogoButton(size: 32),
        ),
        title: const Text('Orientation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Trouvez votre voie,',
            style: context.textTheme.displayMedium,
          ),
          Text(
            'à votre rythme.',
            style: context.textTheme.displayMedium?.copyWith(
              color: AppColors.accentDark,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ces suggestions sont une aide à la décision, pas un classement '
            'définitif — le choix final vous appartient toujours.',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          profileAsync.when(
            loading: () => const SkeletonLoader(height: 90),
            error: (error, _) => const SizedBox.shrink(),
            data: (profil) => switch (profil) {
              ProfilAcademiqueLyceen(:final profil) => _ProfileCompletionCard(completude: profil.completude),
              ProfilAcademiqueEtudiant() => const SizedBox.shrink(),
            },
          ),
          const SizedBox(height: 24),
          _OrientationCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Mes recommandations',
            subtitle: 'Formations suggérées selon votre profil, avec score de correspondance',
            color: AppColors.greenSoft,
            onTap: () => context.push(RoutePaths.orientationRecommendations),
          ),
          const SizedBox(height: 12),
          _OrientationCard(
            icon: Icons.timeline_rounded,
            title: 'Simulation de parcours',
            subtitle: 'Visualisez un parcours Licence → Master → Doctorat',
            color: AppColors.blueSoft,
            onTap: () => context.push(RoutePaths.orientationSimulation),
          ),
          const SizedBox(height: 12),
          _OrientationCard(
            icon: Icons.person_outline_rounded,
            title: 'Compléter mon profil',
            subtitle: 'Série, moyenne, passions, préférences — pour des suggestions plus précises',
            color: AppColors.amberSoft,
            onTap: () => context.push(RoutePaths.profile),
          ),
          const SizedBox(height: 12),
          _OrientationCard(
            icon: Icons.school_outlined,
            title: 'Explorer toutes les universités',
            subtitle: 'Catalogue complet, filtres par région, type et domaine',
            color: AppColors.greenSoft,
            onTap: () => context.push(RoutePaths.universities),
          ),
        ],
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  const _ProfileCompletionCard({required this.completude});
  final int completude;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil complété à $completude%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: completude / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrientationCard extends StatelessWidget {
  const _OrientationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
