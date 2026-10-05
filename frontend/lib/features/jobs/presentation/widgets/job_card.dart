import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/etablissement_avatar.dart' show couleurDepuisNom;
import '../../../../shared/widgets/favorite_button.dart';
import '../../domain/entities/offre_emploi.dart';
import 'job_type_style.dart';

final _dateFormat = DateFormat('d MMM', 'fr_FR');

/// Carte offre d'emploi — utilisée dans la liste, les favoris et le fil
/// "à la une" du tableau de bord. Logo à initiales, tags d'info, pied de
/// carte avec type + échéance.
class JobCard extends StatefulWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onFavoriteTap,
  });

  final OffreEmploi job;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final typeColor = job.type.color;
    final deadline = deadlineBadge(job);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? typeColor.withValues(alpha: 0.35) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: _hovered ? 0.10 : 0.04),
              blurRadius: _hovered ? 24 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Opacity(
              opacity: job.expiree ? 0.6 : 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CompanyLogo(name: job.entreprise, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.intitule,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontSize: 15.5,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      job.entreprise,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (job.sourceVerifiee) ...[
                                    const SizedBox(width: 6),
                                    Tooltip(
                                      message: job.sourceOfficielle
                                          ? 'Source officielle vérifiée'
                                          : 'Source vérifiée par la veille IA',
                                      child: Icon(
                                        job.sourceOfficielle
                                            ? Icons.account_balance_rounded
                                            : Icons.verified_rounded,
                                        size: 14,
                                        color: job.sourceOfficielle
                                            ? AppColors.info
                                            : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (widget.onFavoriteTap != null)
                          FavoriteButton(
                            isFavorite: job.estFavori,
                            onTap: widget.onFavoriteTap!,
                            size: 19,
                            background: Colors.transparent,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Tag(icon: Icons.place_rounded, label: job.region),
                        _Tag(
                          icon: Icons.workspace_premium_rounded,
                          label: job.niveauRequis ?? 'Tous niveaux',
                        ),
                        if (job.domaine.isNotEmpty)
                          _Tag(icon: Icons.category_rounded, label: job.domaine),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: AppColors.divider),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(job.type.icon, size: 13, color: typeColor),
                                const SizedBox(width: 5),
                                Text(
                                  job.type.label,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (job.datePublication != null || job.dateIndexation != null)
                            Flexible(
                              child: Text(
                                [
                                  'Publiée le ${_dateFormat.format((job.datePublication ?? job.dateIndexation)!)}',
                                  if (job.sourceVerifiee && job.source != null) job.source!,
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.labelSmall,
                              ),
                            ),
                          const Spacer(),
                          if (deadline != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: deadline.color.withValues(alpha: 0.4),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined, size: 12, color: deadline.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    deadline.label,
                                    style: TextStyle(
                                      color: deadline.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo d'entreprise à initiales sur fond dérivé du nom (stable).
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({super.key, required this.name, this.size = 48});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final couleur = couleurDepuisNom(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [couleur, couleur.withValues(alpha: 0.72)],
        ),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        initialesEntreprise(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
