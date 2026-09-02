import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum StatCardTone { green, amber, blue }

/// Carte stats tricolore façon maquette (Conversations IA / Offres suivies /
/// Universités favoris) : chiffre en gras + libellé + icône.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.tone = StatCardTone.green,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final StatCardTone tone;
  final VoidCallback? onTap;

  Color get _background {
    switch (tone) {
      case StatCardTone.green:
        return AppColors.greenSoft;
      case StatCardTone.amber:
        return AppColors.amberSoft;
      case StatCardTone.blue:
        return AppColors.blueSoft;
    }
  }

  Color get _foreground {
    switch (tone) {
      case StatCardTone.green:
        return AppColors.primary;
      case StatCardTone.amber:
        return AppColors.accentDark;
      case StatCardTone.blue:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _foreground, size: 22),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: _foreground,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _foreground.withValues(alpha: 0.85),
                    ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
