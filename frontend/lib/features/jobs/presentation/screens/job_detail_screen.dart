import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/constants/app_images.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/content_max_width.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_reveal.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/offre_emploi.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart' show CompanyLogo;
import '../widgets/job_type_style.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: jobAsync.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Offre introuvable',
            message: error is Failure ? error.message : null,
          ),
        ),
        data: (job) => _JobDetailBody(job: job),
      ),
    );
  }
}

class _JobDetailBody extends ConsumerWidget {
  const _JobDetailBody({required this.job});
  final OffreEmploi job;

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    final failure = await ref.read(jobListProvider.notifier).toggleFavorite(job);
    ref.invalidate(jobDetailProvider(job.id));
    if (failure != null && context.mounted) {
      context.showSnack(failure.message, isError: true);
    }
  }

  Future<void> _openSource(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(job.sourceUrl!),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      context.showSnack('Impossible d\'ouvrir le lien.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');
    final deadline = deadlineBadge(job);
    final typeColor = job.type.color;
    final horizontal = context.isMobile ? 20.0 : 32.0;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _DetailHeader(
                  job: job,
                  onBack: () => Navigator.of(context).maybePop(),
                  onFavorite: () => _toggleFavorite(context, ref),
                ),
              ),
              SliverToBoxAdapter(
                child: ContentMaxWidth(
                  maxWidth: 860,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionReveal(
                          delay: const Duration(milliseconds: 80),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth > 600 ? 4 : 2;
                              final width =
                                  (constraints.maxWidth - 10 * (columns - 1)) / columns;
                              final tiles = [
                                _InfoTile(
                                  icon: Icons.place_rounded,
                                  label: 'Région',
                                  value: job.region,
                                  tint: AppColors.greenSoft,
                                  color: AppColors.primary,
                                ),
                                _InfoTile(
                                  icon: Icons.category_rounded,
                                  label: 'Domaine',
                                  value: job.domaine,
                                  tint: AppColors.blueSoft,
                                  color: AppColors.info,
                                ),
                                _InfoTile(
                                  icon: Icons.workspace_premium_rounded,
                                  label: 'Niveau',
                                  value: job.niveauRequis ?? 'Tous niveaux',
                                  tint: AppColors.amberSoft,
                                  color: AppColors.accentDark,
                                ),
                                _InfoTile(
                                  icon: Icons.event_rounded,
                                  label: 'Date limite',
                                  value: job.dateLimite != null
                                      ? dateFormat.format(job.dateLimite!)
                                      : 'Non précisée',
                                  tint: (deadline?.color ?? AppColors.textSecondary)
                                      .withValues(alpha: 0.1),
                                  color: deadline?.color ?? AppColors.textSecondary,
                                ),
                              ];
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final t in tiles) SizedBox(width: width, child: t),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        SectionReveal(
                          delay: const Duration(milliseconds: 140),
                          child: _Section(
                            icon: Icons.description_rounded,
                            title: 'Description du poste',
                            child: Text(
                              job.description,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary.withValues(alpha: 0.85),
                                height: 1.65,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SectionReveal(
                          delay: const Duration(milliseconds: 200),
                          child: _Section(
                            icon: Icons.info_rounded,
                            title: 'À propos de l\'offre',
                            child: Column(
                              children: [
                                _KeyValue(label: 'Entreprise', value: job.entreprise),
                                _KeyValue(
                                  label: 'Type de contrat',
                                  value: job.type.label,
                                  valueColor: typeColor,
                                ),
                                if (job.datePublication != null)
                                  _KeyValue(
                                    label: 'Publiée le',
                                    value: dateFormat.format(job.datePublication!),
                                  ),
                                if (job.source != null)
                                  _KeyValue(label: 'Source', value: job.source!),
                                _KeyValue(
                                  label: 'Fiabilité',
                                  value: switch (job.fiabilite) {
                                    'officiel' => 'Source officielle',
                                    'presse' => 'Presse reconnue',
                                    'plateforme' => "Plateforme d'offres reconnue",
                                    _ => 'Non vérifiée',
                                  },
                                  valueColor: job.sourceVerifiee
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ),
                                _KeyValue(
                                  label: 'Statut',
                                  value: job.expiree ? 'Expirée' : 'Ouverte',
                                  valueColor:
                                      job.expiree ? AppColors.error : AppColors.success,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SectionReveal(
                          delay: const Duration(milliseconds: 240),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.amberSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.shield_outlined,
                                    color: AppColors.accentDark, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Ne payez jamais pour postuler. Vérifiez toujours l\'offre '
                                    'sur le site officiel de l\'entreprise.',
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _BottomActionBar(
          job: job,
          onFavorite: () => _toggleFavorite(context, ref),
          onApply: job.sourceUrl == null ? null : () => _openSource(context),
        ),
      ],
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.job,
    required this.onBack,
    required this.onFavorite,
  });

  final OffreEmploi job;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final deadline = deadlineBadge(job);
    final horizontal = context.isMobile ? 20.0 : 32.0;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF16503B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Même fond que les en-têtes Actualités et Emplois : l'image à la lampe, sous un
            // voile vert qui garde le texte lisible.
            Positioned.fill(
              child: Image.asset(
                AppImages.dashboardHero,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.88),
                      AppColors.primary.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            ContentMaxWidth(
              maxWidth: 860,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal - 8, topInset + 8, horizontal, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _RoundButton(icon: Icons.arrow_back_rounded, onTap: onBack),
                        const Spacer(),
                        _RoundButton(
                          icon: job.estFavori
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          iconColor: job.estFavori ? AppColors.accent : Colors.white,
                          onTap: onFavorite,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SectionReveal(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: CompanyLogo(name: job.entreprise, size: 60),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              job.intitule,
                              style: context.textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontSize: context.isMobile ? 23 : 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.business_rounded,
                                    size: 16, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    job.entreprise,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _GlassPill(icon: job.type.icon, label: job.type.label),
                                _GlassPill(icon: Icons.place_rounded, label: job.region),
                                if (deadline != null)
                                  _GlassPill(
                                    icon: Icons.timer_outlined,
                                    label: deadline.label,
                                    highlight: true,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor, size: 21),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.label, this.highlight = false});
  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? AppColors.primary : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? AppColors.accent : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: highlight ? null : Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(label, style: context.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: context.textTheme.headlineMedium?.copyWith(fontSize: 16.5)),
              const Spacer(),
              Icon(icon, size: 18, color: AppColors.textSecondary.withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.job,
    required this.onFavorite,
    required this.onApply,
  });

  final OffreEmploi job;
  final VoidCallback onFavorite;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ContentMaxWidth(
          maxWidth: 860,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                SizedBox(
                  height: 52,
                  width: 52,
                  child: OutlinedButton(
                    onPressed: onFavorite,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Icon(
                      job.estFavori ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: job.estFavori ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: job.expiree ? null : onApply,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      icon: Icon(
                        job.expiree ? Icons.lock_clock_rounded : Icons.send_rounded,
                        size: 19,
                      ),
                      label: Text(
                        job.expiree
                            ? 'Offre expirée'
                            : onApply == null
                                ? 'Lien indisponible'
                                : job.sourceVerifiee
                                    ? "Voir l'annonce · ${job.source ?? 'source'}"
                                    : "Voir l'annonce",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 280 + MediaQuery.paddingOf(context).top,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: SkeletonLoader(height: 100, borderRadius: 18)),
                  SizedBox(width: 10),
                  Expanded(child: SkeletonLoader(height: 100, borderRadius: 18)),
                ],
              ),
              SizedBox(height: 18),
              SkeletonLoader(height: 180, borderRadius: 20),
            ],
          ),
        ),
      ],
    );
  }
}
