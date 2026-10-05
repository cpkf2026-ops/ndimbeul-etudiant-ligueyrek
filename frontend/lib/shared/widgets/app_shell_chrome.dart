import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_paths.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'sidebar_nav.dart';
import '../extensions/context_extensions.dart';

const _kShellBranchPaths = [
  RoutePaths.dashboard,
  RoutePaths.orientation,
  RoutePaths.profile,
];

/// Enveloppe les écrans poussés hors du shell principal (jobs, universités,
/// actualités, chat, admin...) pour qu'ils gardent une navigation visible
/// sur tablette/desktop, au lieu de perdre toute la sidebar dès qu'on
/// quitte les 4 onglets principaux.
///
/// Purement présentationnel — ne touche pas au routing go_router : la
/// sidebar est affichée avec `currentIndex: -1` (aucun onglet actif, ce qui
/// est correct puisqu'on est sur une page de détail/secondaire) et navigue
/// via `context.go` plutôt que `navigationShell.goBranch`.
class AppShellChrome extends ConsumerWidget {
  const AppShellChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isMobile) return child;

    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      body: Row(
        children: [
          SidebarNav(
            currentIndex: -1,
            onTap: (index) => context.go(_kShellBranchPaths[index]),
            compact: context.isTablet,
            userName: user?.nomComplet ?? 'Invité',
            userSubtitle: user?.role?.label ?? 'Mode visiteur',
            role: user?.role,
            isGuest: user == null,
            onLogout: () async {
              if (user == null) {
                context.go(RoutePaths.login);
                return;
              }
              // Accueil d'abord : évite que la fenêtre "Connexion requise"
              // ne s'ouvre sur la page courante une fois déconnecté.
              context.go(RoutePaths.dashboard);
              await ref.read(authProvider.notifier).logout();
            },
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
