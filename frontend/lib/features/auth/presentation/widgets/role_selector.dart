import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/user.dart';

/// Sélecteur de statut — utilisé sur CompleteProfileScreen pour le choix
/// lycéen / étudiant / diplômé-en poste-stage (plus jamais à l'inscription,
/// qui ne demande plus le statut — voir plan "Séparation inscription /
/// complétion de profil"). Cartes empilées plutôt qu'une rangée : le
/// libellé du statut "diplômé" est trop long pour 3 pastilles côte à côte.
class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final UserRole? value;
  final ValueChanged<UserRole> onChanged;
  final List<UserRole> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vous êtes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final role in options)
          Padding(
            padding: EdgeInsets.only(bottom: role == options.last ? 0 : 10),
            child: _RoleCard(
              role: role,
              selected: role == value,
              onTap: () => onChanged(role),
            ),
          ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.selected, required this.onTap});

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                role.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
