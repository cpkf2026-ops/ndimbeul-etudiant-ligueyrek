import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/entities/user.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_shell_chrome.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qualityAsync = ref.watch(qualityMetricsProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    return AdminShellChrome(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Tableau de bord')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Qualité de la plateforme',
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            qualityAsync.when(
              loading: () => const SkeletonCard(height: 140),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Métriques indisponibles',
                message: error is Failure ? error.message : null,
              ),
              data: (metrics) {
                final laravel = metrics.metriquesLaravel;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricChip(
                      label: 'Sources actives',
                      value: '${laravel?.sourcesActives ?? '—'}',
                      tone: AppColors.greenSoft,
                    ),
                    _MetricChip(
                      label: 'Sources en erreur',
                      value: '${laravel?.sourcesEnErreur ?? '—'}',
                      tone: AppColors.amberSoft,
                    ),
                    _MetricChip(
                      label: 'Offres actives',
                      value: '${laravel?.offresActives ?? '—'}',
                      tone: AppColors.blueSoft,
                    ),
                    if (metrics.iaMetric('cache_hit_rate') != null)
                      _MetricChip(
                        label: 'Cache hit rate (IA)',
                        value:
                            '${((metrics.iaMetric('cache_hit_rate') ?? 0) * 100).round()}%',
                        tone: AppColors.greenSoft,
                      ),
                    if (metrics.iaMetric('couverture_rag') != null)
                      _MetricChip(
                        label: 'Couverture RAG',
                        value:
                            '${((metrics.iaMetric('couverture_rag') ?? 0) * 100).round()}%',
                        tone: AppColors.blueSoft,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Comptes inscrits', style: context.textTheme.headlineMedium),
            const SizedBox(height: 12),
            usersAsync.when(
              loading: () => const SkeletonCard(height: 80),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Utilisateurs indisponibles',
                message: error is Failure ? error.message : null,
              ),
              data: (users) {
                final parRole = <UserRole, int>{};
                for (final u in users) {
                  parRole[u.role] = (parRole[u.role] ?? 0) + 1;
                }
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricChip(
                      label: 'Total inscrits',
                      value: '${users.length}',
                      tone: AppColors.greenSoft,
                    ),
                    for (final role in UserRole.values)
                      if (parRole[role] != null)
                        _MetricChip(
                          label: role.label,
                          value: '${parRole[role]}',
                          tone: AppColors.blueSoft,
                        ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Gestion', style: context.textTheme.headlineMedium),
            const SizedBox(height: 12),
            _AdminMenuTile(
              icon: Icons.cloud_sync_outlined,
              title: 'Sources de données IA',
              subtitle: 'Veille, imports PDF, statut de crawl',
              onTap: () => context.push(RoutePaths.adminSources),
            ),
            _AdminMenuTile(
              icon: Icons.people_alt_outlined,
              title: 'Utilisateurs',
              subtitle: 'Rôles, suspension, réactivation',
              onTap: () => context.push(RoutePaths.adminUsers),
            ),
            _AdminMenuTile(
              icon: Icons.newspaper_outlined,
              title: 'Actualités',
              subtitle: 'Consultation des publications',
              onTap: () => context.push(RoutePaths.adminNews),
            ),
            const SizedBox(height: 12),
            // Ajout assisté par l'IA : recherche web / lecture du lien -> relecture -> publication.
            _AdminMenuTile(
              icon: Icons.school_outlined,
              title: 'Ajouter un établissement',
              subtitle: "Tapez le nom : l'IA cherche site, présentation, lieu, statut et logo",
              onTap: () => context.push(RoutePaths.adminAjoutEtablissement),
            ),
            _AdminMenuTile(
              icon: Icons.post_add_rounded,
              title: 'Ajouter une actualité',
              subtitle: "Collez le lien de l'article : l'IA prépare titre, résumé, image",
              onTap: () => context.push(RoutePaths.adminAjoutActualite),
            ),
            _AdminMenuTile(
              icon: Icons.work_outline_rounded,
              title: 'Ajouter un emploi / stage',
              subtitle: "Collez le lien de l'offre : l'IA prépare intitulé, organisme, date limite",
              onTap: () => context.push(RoutePaths.adminAjoutOffre),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.tone,
  });
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(label, style: context.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: context.textTheme.titleMedium),
        subtitle: Text(subtitle, style: context.textTheme.labelSmall),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
