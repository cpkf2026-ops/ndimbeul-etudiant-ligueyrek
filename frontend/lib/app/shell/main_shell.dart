import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/ai_floating_button.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/sidebar_nav.dart';
import '../../shared/widgets/welcome_snackbar.dart';
import '../router/route_paths.dart';

/// Shell principal — bascule bottom nav (mobile, 4 onglets) / sidebar
/// (tablette-desktop, 8 entrées) et héberge le bouton flottant assistant IA.
/// Les 8 branches (Accueil, Orientation, Écosystème, Profil, Universités,
/// Emploi & Stages, Actualités, Assistant IA) vivent toutes dans le même
/// [StatefulShellRoute.indexedStack] — seul le nombre d'entrées affichées
/// diffère selon la largeur d'écran (voir kMainNavDestinations vs
/// kSidebarNavDestinations dans shared/widgets).
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    // Le flag est déjà vrai avant même le premier `build` de ce shell (posé
    // par `login()` puis consommé ici) — un `ref.listen` ne le verrait
    // jamais car la transition d'état a eu lieu pendant que LoginScreen,
    // pas MainShell, était monté. `consumeJustLoggedIn()` se réinitialise
    // tout seul, donc l'appeler à chaque `build` reste bien un coup unique.
    if (user != null && ref.read(authProvider.notifier).consumeJustLoggedIn()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) showWelcomeSnackBar(context, user);
      });
    }

    void onTap(int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );

    if (context.isDesktop || context.isTablet) {
      return Scaffold(
        body: Row(
          children: [
            SidebarNav(
              currentIndex: navigationShell.currentIndex,
              onTap: onTap,
              compact: context.isTablet,
              userName: user?.nomComplet ?? 'Invité',
              userSubtitle: user?.role?.label ?? '',
              role: user?.role,
              onLogout: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(RoutePaths.login);
              },
            ),
            Expanded(child: navigationShell),
          ],
        ),
        floatingActionButton: const AiFloatingButton(),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: onTap,
        role: user?.role,
      ),
      floatingActionButton: const AiFloatingButton(),
    );
  }
}
