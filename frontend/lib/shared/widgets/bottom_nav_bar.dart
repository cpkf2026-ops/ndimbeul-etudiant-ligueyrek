import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../features/auth/domain/entities/user.dart';

class NavDestination {
  const NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.branchIndex,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Index de la branche [StatefulShellRoute] correspondante — sert à la
  /// fois à détecter la sélection (`branchIndex == currentIndex`) et à
  /// déclencher `navigationShell.goBranch(branchIndex)`. Découplé de la
  /// position dans la liste pour permettre au sidebar (desktop/tablette)
  /// d'afficher plus d'entrées, dans un ordre différent, que le bottom nav
  /// mobile (voir `kSidebarNavDestinations` dans sidebar_nav.dart).
  final int branchIndex;
}

/// Onglets principaux mobiles (< 600px) — volontairement limités à 4 pour
/// rester lisibles dans une barre du bas ; les modules supplémentaires
/// (Universités, Emploi & Stages, Actualités, Assistant IA) restent
/// accessibles via les liens "Voir tout" des écrans existants et le bouton
/// flottant IA, et apparaissent en plus dans le sidebar desktop/tablette.
const List<NavDestination> kMainNavDestinations = [
  NavDestination(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Accueil',
    branchIndex: 0,
  ),
  NavDestination(
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    label: 'Orientation',
    branchIndex: 1,
  ),
  NavDestination(
    icon: Icons.hub_outlined,
    activeIcon: Icons.hub_rounded,
    label: 'Écosystème',
    branchIndex: 2,
  ),
  NavDestination(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profil',
    branchIndex: 3,
  ),
];

/// Onglets visibles pour [role] — masque entièrement Orientation (pas
/// seulement désactivée) pour les statuts qui n'en ont pas l'usage, voir
/// `UserRole.voitOrientation`.
List<NavDestination> mainNavDestinationsFor(UserRole? role) => [
      for (final dest in kMainNavDestinations)
        if (dest.branchIndex != 1 || (role?.voitOrientation ?? true)) dest,
    ];

/// Bottom navigation mobile (< 600px) — item actif en vert, façon maquette.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.role,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final destinations = mainNavDestinationsFor(role);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final selected = dest.branchIndex == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(dest.branchIndex),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? dest.activeIcon : dest.icon,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dest.label,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
