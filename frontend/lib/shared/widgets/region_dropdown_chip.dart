import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Les 14 régions administratives du Sénégal.
const List<String> kSenegalRegions = [
  'Dakar',
  'Thiès',
  'Saint-Louis',
  'Diourbel',
  'Ziguinchor',
  'Kaolack',
  'Tambacounda',
  'Fatick',
  'Kolda',
  'Louga',
  'Matam',
  'Kaffrine',
  'Kédougou',
  'Sédhiou',
];

/// "Sticker" Région : un clic déroule la liste des régions sous le bouton,
/// un clic à l'extérieur (ou sur une région) la referme. Remplace les
/// longues rangées de puces de régions qui débordaient de l'écran.
class RegionDropdownChip extends StatelessWidget {
  const RegionDropdownChip({
    super.key,
    required this.selected,
    required this.onSelected,
    this.regions = kSenegalRegions,
    this.allLabel = 'Tout le Sénégal',
  });

  /// Région active, ou null pour "Tout le Sénégal".
  final String? selected;

  /// Appelé avec la région choisie, ou null pour retirer le filtre.
  final ValueChanged<String?> onSelected;
  final List<String> regions;
  final String allLabel;

  PopupMenuItem<String> _item(String value, String label, {IconData? icon}) {
    final isSelected = (value.isEmpty && selected == null) || value == selected;
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon ?? Icons.place_outlined,
            size: 18,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = selected != null;
    final fg = active ? Colors.white : AppColors.primary;

    return PopupMenuButton<String>(
      tooltip: 'Choisir une région',
      onSelected: (value) => onSelected(value.isEmpty ? null : value),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260, maxHeight: 380),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _item('', allLabel, icon: Icons.public_rounded),
        const PopupMenuDivider(height: 8),
        for (final region in regions) _item(region, region),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.greenSoft,
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_rounded, size: 17, color: active ? AppColors.accent : fg),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                selected ?? 'Région',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}
