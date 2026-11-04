import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// En-tête de page "hero" — dégradé vert profond, motif de cercles décoratifs,
/// titre droit/italique doré (même grammaire visuelle que la bannière de
/// l'accueil). [bottom] accueille typiquement une barre de recherche ou un
/// sélecteur d'onglets, [actions] des boutons ronds translucides.
class GradientPageHeader extends StatelessWidget {
  const GradientPageHeader({
    super.key,
    required this.eyebrow,
    required this.straightTitle,
    required this.accentTitle,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.leading,
    this.imageFond,
  });

  final String eyebrow;
  final String straightTitle;
  final String accentTitle;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? bottom;
  final Widget? leading;

  /// Image (asset) en fond, comme la bannière de l'accueil, recouverte d'un voile vert
  /// pour que le texte reste lisible. Sans image : dégradé et cercles décoratifs.
  final String? imageFond;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;
    final topInset = MediaQuery.paddingOf(context).top;

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
            if (imageFond != null) ...[
              Positioned.fill(
                child: Image.asset(
                  imageFond!,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
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
            ] else ...[
              const Positioned(top: -60, right: -40, child: _Halo(size: 200, alpha: 0.07)),
              const Positioned(bottom: -70, left: -50, child: _Halo(size: 170, alpha: 0.05)),
              Positioned(
                top: topInset + 30,
                right: 36,
                child: const _Halo(size: 44, alpha: 0.9, color: AppColors.accent, ring: true),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, topInset + 14, horizontal, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (leading != null) ...[leading!, const SizedBox(width: 8)],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        child: Text(
                          eyebrow.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 10.5,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      for (final action in actions) ...[const SizedBox(width: 8), action],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTypography.heroTitle(
                    straight: straightTitle,
                    accent: accentTitle,
                    fontSize: 25,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (bottom != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    bottom!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton rond translucide pour les actions de [GradientPageHeader].
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.18))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );

    return Tooltip(
      message: tooltip ?? '',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          if (badgeCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({
    required this.size,
    required this.alpha,
    this.color = Colors.white,
    this.ring = false,
  });

  final double size;
  final double alpha;
  final Color color;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ring ? null : color.withValues(alpha: alpha),
          border: ring ? Border.all(color: color.withValues(alpha: 0.35), width: 6) : null,
        ),
      ),
    );
  }
}
