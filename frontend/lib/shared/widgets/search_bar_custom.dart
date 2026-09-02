import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Barre de recherche façon "overlay sur image hero" — icône loupe,
/// coins arrondis, ombre douce.
class SearchBarCustom extends StatelessWidget {
  const SearchBarCustom({
    super.key,
    this.hint = 'Rechercher...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (onFilterTap != null)
            IconButton(
              onPressed: onFilterTap,
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}
