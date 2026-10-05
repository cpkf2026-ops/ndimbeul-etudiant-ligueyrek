import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_logo_button.dart';
import '../../../../shared/widgets/welcome_snackbar.dart';

class _AdminDestination {
  const _AdminDestination(this.icon, this.label, this.path);
  final IconData icon;
  final String label;
  final String path;
}

const _kAdminDestinations = [
  _AdminDestination(
    Icons.dashboard_outlined,
    'Tableau de bord',
    RoutePaths.admin,
  ),
  _AdminDestination(
    Icons.people_alt_outlined,
    'Utilisateurs',
    RoutePaths.adminUsers,
  ),
  _AdminDestination(
    Icons.cloud_sync_outlined,
    'Sources IA',
    RoutePaths.adminSources,
  ),
  _AdminDestination(
    Icons.newspaper_outlined,
    'Actualités',
    RoutePaths.adminNews,
  ),
];

/// Navigation persistante et distincte du shell élève, réservée aux écrans
/// du back-office (`admin/`). Purement présentationnel — les routes admin
/// restent des `GoRoute` poussées indépendantes, ce widget ajoute juste une
/// sidebar (tablette/desktop) ou un `Drawer` (mobile) autour de leur
/// `Scaffold` existant, avec ses propres destinations (jamais celles du
/// menu élève Accueil/Orientation/Écosystème/Profil).
class AdminShellChrome extends ConsumerWidget {
  const AdminShellChrome({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    // Chaque route admin est un `GoRoute` poussé indépendant, donc une
    // nouvelle instance d'`AdminShellChrome` est créée à chaque navigation
    // — `consumeJustLoggedIn()` se réinitialise après le premier appel,
    // donc le message ne s'affiche bien qu'une fois malgré ces remounts.
    if (user != null && ref.read(authProvider.notifier).consumeJustLoggedIn()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) showWelcomeSnackBar(context, user);
      });
    }

    if (context.isMobile) {
      return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(AppConstants.appName),
        ),
        drawer: Drawer(child: _AdminNavList(currentIndex: currentIndex)),
        body: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: Material(
              color: AppColors.surface,
              child: _AdminNavList(currentIndex: currentIndex),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AdminNavList extends ConsumerWidget {
  const _AdminNavList({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Row(
            children: [
              AppLogoButton(size: 32),
              SizedBox(width: 10),
              Text(
                AppConstants.appName,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),
        for (final entry in _kAdminDestinations.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: entry.$1 == currentIndex
                  ? AppColors.greenSoft
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.go(entry.$2.path),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        entry.$2.icon,
                        size: 20,
                        color: entry.$1 == currentIndex
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.$2.label,
                        style: TextStyle(
                          fontWeight: entry.$1 == currentIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: entry.$1 == currentIndex
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nomComplet ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      user?.role?.label ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Déconnexion',
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () async {
                  // Accueil d'abord : évite que la fenêtre "Connexion requise"
                  // ne s'ouvre sur la page courante une fois déconnecté.
                  context.go(RoutePaths.dashboard);
                  await ref.read(authProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
