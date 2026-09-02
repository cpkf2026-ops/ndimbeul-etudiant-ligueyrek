import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'app_logo_button.dart';
import 'bottom_nav_bar.dart';

/// Navigation complète du sidebar desktop/tablette — les 4 onglets
/// principaux du bottom nav mobile, plus les modules fonctionnels
/// supplémentaires (Universités, Emploi & Stages, Actualités, Assistant IA)
/// qui n'ont pas leur place dans une barre du bas à 4 icônes mais méritent
/// un accès direct et persistant sur les formats plus larges. Chaque entrée
/// pointe vers sa propre branche de la [StatefulShellRoute] (voir
/// `app_router.dart`) — le sidebar reste donc visible et l'entrée active
/// correctement surlignée en naviguant vers ces modules.
const List<NavDestination> kSidebarNavDestinations = [
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
    icon: Icons.school_outlined,
    activeIcon: Icons.school_rounded,
    label: 'Universités',
    branchIndex: 4,
  ),
  NavDestination(
    icon: Icons.work_outline_rounded,
    activeIcon: Icons.work_rounded,
    label: 'Emploi & Stages',
    branchIndex: 5,
  ),
  NavDestination(
    icon: Icons.article_outlined,
    activeIcon: Icons.article_rounded,
    label: 'Actualités',
    branchIndex: 6,
  ),
  NavDestination(
    icon: Icons.smart_toy_outlined,
    activeIcon: Icons.smart_toy_rounded,
    label: 'Assistant IA',
    branchIndex: 7,
  ),
  NavDestination(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profil',
    branchIndex: 3,
  ),
];

/// Sidebar web/desktop (>= 1024px) — logo, navigation verticale, bloc
/// profil utilisateur + déconnexion en bas, façon maquette Figma. Sur
/// tablette (600-1023px), passe en mode [compact] : rail étroit, icônes
/// seules avec tooltips — la version pleine largeur (260px) laisserait
/// trop peu de place au contenu à ces largeurs intermédiaires.
class SidebarNav extends StatelessWidget {
  const SidebarNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userName,
    required this.userSubtitle,
    required this.onLogout,
    this.compact = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String userName;
  final String userSubtitle;
  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactSidebarNav(
        currentIndex: currentIndex,
        onTap: onTap,
        onLogout: onLogout,
      );
    }

    return Container(
      width: 260,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              children: [
                const AppLogoButton(size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: kSidebarNavDestinations.length,
              itemBuilder: (context, index) {
                final dest = kSidebarNavDestinations[index];
                final selected = dest.branchIndex == currentIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: selected
                        ? AppColors.greenSoft
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onTap(dest.branchIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? dest.activeIcon : dest.icon,
                              size: 20,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              dest.label,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.greenSoft,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userSubtitle,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Déconnexion',
                  onPressed: onLogout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rail compact (tablette, 600-1023px) — logo, icônes seules avec tooltips,
/// avatar + déconnexion en bas. ~76px de large contre 260px en plein format.
class _CompactSidebarNav extends StatelessWidget {
  const _CompactSidebarNav({
    required this.currentIndex,
    required this.onTap,
    required this.onLogout,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const AppLogoButton(size: 36),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: kSidebarNavDestinations.length,
              itemBuilder: (context, index) {
                final dest = kSidebarNavDestinations[index];
                final selected = dest.branchIndex == currentIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Tooltip(
                    message: dest.label,
                    child: Material(
                      color: selected
                          ? AppColors.greenSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onTap(dest.branchIndex),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Icon(
                            selected ? dest.activeIcon : dest.icon,
                            size: 22,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Tooltip(
              message: 'Déconnexion',
              child: IconButton(
                onPressed: onLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
