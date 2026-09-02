import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Bannière IA plein-largeur — fond vert dégradé, titre hero (contraste
/// droit/italique), bouton pilule doré "Ouvrir le chat IA".
class AiBanner extends StatelessWidget {
  const AiBanner({
    super.key,
    required this.straightTitle,
    required this.accentTitle,
    required this.subtitle,
    required this.onOpenChat,
    this.ctaLabel = 'Ouvrir le chat IA',
  });

  final String straightTitle;
  final String accentTitle;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTypography.heroTitle(
            straight: straightTitle,
            accent: accentTitle,
            fontSize: 22,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onOpenChat,
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}
