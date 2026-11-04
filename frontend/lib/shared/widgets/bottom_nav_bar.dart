import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../features/auth/domain/entities/user.dart';
import 'sidebar_nav.dart';

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

/// Onglets mobiles (< 600px) : EXACTEMENT les mêmes modules que le sidebar du PC
/// (même liste, mêmes règles par statut — voir sidebarNavDestinationsFor), avec des
/// libellés courts qui tiennent sur un téléphone. Liste conservée pour référence de
/// l'ordre ; la source de vérité est le sidebar.
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
    icon: Icons.school_outlined,
    activeIcon: Icons.school_rounded,
    label: 'Universités',
    branchIndex: 3,
  ),
  NavDestination(
    icon: Icons.work_outline_rounded,
    activeIcon: Icons.work_rounded,
    label: 'Emploi',
    branchIndex: 4,
  ),
  NavDestination(
    icon: Icons.newspaper_outlined,
    activeIcon: Icons.newspaper_rounded,
    label: 'Actualités',
    branchIndex: 5,
  ),
  NavDestination(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profil',
    branchIndex: 2,
  ),
];

/// Au-delà de ce nombre d'entrées, les dernières passent dans un bouton « Plus »
/// (rien n'est retiré : tout reste accessible comme sur le PC).
const int kMaxOngletsMobile = 6;

/// Libellés courts pour le téléphone (le sidebar du PC garde les libellés longs).
const Map<String, String> _libellesCourts = {
  'Emploi & Stages': 'Emploi',
  'Assistant IA': 'Assistant',
};

/// Entrées mobiles pour [role] : la MÊME liste que le sidebar du PC.
List<NavDestination> mainNavDestinationsFor(UserRole? role) => [
      for (final dest in sidebarNavDestinationsFor(role))
        NavDestination(
          icon: dest.icon,
          activeIcon: dest.activeIcon,
          label: _libellesCourts[dest.label] ?? dest.label,
          branchIndex: dest.branchIndex,
        ),
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

  /// Feuille listant les entrées qui ne tiennent pas dans la barre.
  void _ouvrirPlus(BuildContext context, List<NavDestination> autres) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final dest in autres)
              ListTile(
                leading: Icon(
                  dest.branchIndex == currentIndex ? dest.activeIcon : dest.icon,
                  color: dest.branchIndex == currentIndex ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(dest.label),
                selected: dest.branchIndex == currentIndex,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onTap(dest.branchIndex);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toutes = mainNavDestinationsFor(role);
    // Trop d'entrées pour la barre : les premières + un bouton « Plus » pour le reste.
    final debordement = toutes.length > kMaxOngletsMobile;
    final autres = debordement ? toutes.sublist(kMaxOngletsMobile - 1) : <NavDestination>[];
    final destinations = [
      ...(debordement ? toutes.sublist(0, kMaxOngletsMobile - 1) : toutes),
      if (debordement)
        NavDestination(
          icon: Icons.more_horiz_rounded,
          activeIcon: Icons.more_horiz_rounded,
          label: 'Plus',
          // Sélectionné quand la page courante est l'une des entrées du menu « Plus ».
          branchIndex: autres.any((d) => d.branchIndex == currentIndex) ? currentIndex : -1,
        ),
    ];
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
                  onTap: () => debordement && index == destinations.length - 1
                      ? _ouvrirPlus(context, autres)
                      : onTap(dest.branchIndex),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              fontSize: 11,
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
