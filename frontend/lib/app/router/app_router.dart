import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_required_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/orientation/presentation/screens/orientation_screen.dart';
import '../../features/orientation/presentation/screens/recommendations_screen.dart';
import '../../features/orientation/presentation/screens/simulation_screen.dart';
import '../../features/universities/presentation/screens/university_compare_screen.dart';
import '../../features/universities/presentation/screens/university_detail_screen.dart';
import '../../features/universities/presentation/screens/university_list_screen.dart';
import '../../features/ai_assistant/presentation/screens/chat_history_screen.dart';
import '../../features/ai_assistant/presentation/screens/chat_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/jobs/presentation/screens/job_favorites_screen.dart';
import '../../features/jobs/presentation/screens/job_list_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/admin/presentation/screens/admin_ajout_contenu_screen.dart';
import '../../features/admin/presentation/screens/admin_ajout_etablissement_screen.dart';
import '../../features/admin/presentation/screens/admin_home_screen.dart';
import '../../features/admin/presentation/screens/admin_news_screen.dart';
import '../../features/admin/presentation/screens/admin_sources_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../shell/main_shell.dart';
import '../splash/splash_screen.dart';
import '../theme/page_transitions.dart';
import 'route_paths.dart';

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final _refreshNotifierProvider = Provider<_GoRouterRefreshNotifier>((ref) {
  final notifier = _GoRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Cible "from" sûre (chemin interne uniquement) transmise par la fenêtre
/// Connexion requise, pour renvoyer l'utilisateur là où il voulait aller.
String? _safeFrom(GoRouterState state) {
  final from = state.uri.queryParameters['from'];
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  return from;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_refreshNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // L'écran d'accueil (10s) s'affiche toujours en premier, quel que soit
      // l'état de connexion — il déclenche lui-même la navigation ensuite
      // (voir SplashScreen), qui retombe alors dans la logique ci-dessous.
      if (loc == RoutePaths.splash) return null;

      final authState = ref.read(authProvider);
      const publicRoutes = [
        RoutePaths.login,
        RoutePaths.register,
        RoutePaths.forgotPassword,
      ];
      final isPublic = publicRoutes.contains(loc);

      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAdmin = user?.role?.isAdmin ?? false;
      // Comptes admin jamais soumis à l'étape de complétion de profil (ils
      // n'ont pas de statut lycéen/étudiant/diplômé à choisir) — voir
      // EnsureProfileComplete côté backend, même exemption.
      final needsProfileCompletion =
          isLoggedIn && !isAdmin && !user.profilComplete;

      // Mode visiteur : l'accueil est ouvert à tous, mais toute autre
      // fonctionnalité ouvre la fenêtre "Connexion requise" par-dessus
      // l'accueil (en mémorisant la destination demandée).
      if (!isLoggedIn) {
        if (isPublic ||
            loc == RoutePaths.dashboard ||
            loc == RoutePaths.authRequired) {
          return null;
        }
        if (loc == RoutePaths.completeProfile) return RoutePaths.login;
        return Uri(
          path: RoutePaths.authRequired,
          queryParameters: {'from': state.uri.toString()},
        ).toString();
      }

      // Connecté entre-temps : la fenêtre n'a plus lieu d'être.
      if (loc == RoutePaths.authRequired) {
        return _safeFrom(state) ?? RoutePaths.dashboard;
      }

      if (isLoggedIn &&
          needsProfileCompletion &&
          loc != RoutePaths.completeProfile) {
        return RoutePaths.completeProfile;
      }
      if (isLoggedIn &&
          !needsProfileCompletion &&
          loc == RoutePaths.completeProfile) {
        return isAdmin ? RoutePaths.admin : RoutePaths.dashboard;
      }
      if (isLoggedIn && isPublic && !needsProfileCompletion) {
        return _safeFrom(state) ??
            (isAdmin ? RoutePaths.admin : RoutePaths.dashboard);
      }

      if (loc.startsWith(RoutePaths.admin) && !isAdmin) {
        return RoutePaths.dashboard;
      }
      // Module Orientation réservé aux lycéens/étudiants (voir
      // UserRole.voitOrientation et la nav filtrée dans bottom_nav_bar.dart
      // / sidebar_nav.dart) — un accès direct par URL est aussi bloqué ici.
      if (loc.startsWith(RoutePaths.orientation) &&
          !(user.role?.voitOrientation ?? true)) {
        return RoutePaths.dashboard;
      }
      // Module Emploi & Stages non concerné pour les lycéens (voir
      // UserRole.voitEmplois) — accès direct par URL bloqué aussi.
      if (loc.startsWith(RoutePaths.jobs) &&
          !(user.role?.voitEmplois ?? true)) {
        return RoutePaths.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) =>
            RegisterScreen(prefilledEmail: state.extra as String?),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  // Fenêtre transparente au-dessus de l'accueil (navigator
                  // racine) : l'accueil reste visible derrière.
                  GoRoute(
                    path: 'connexion-requise',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      opaque: false,
                      barrierDismissible: true,
                      barrierColor: Colors.black.withValues(alpha: 0.55),
                      transitionDuration: const Duration(milliseconds: 420),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 220,
                      ),
                      child: AuthRequiredScreen(from: _safeFrom(state)),
                      // Dévoilement en cercle depuis l'élément touché.
                      transitionsBuilder: (context, animation, _, child) =>
                          CircleRevealTransition(animation: animation, child: child),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.orientation,
                builder: (context, state) => const OrientationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          // Branches 4-7 : modules supplémentaires promus dans le sidebar
          // desktop/tablette (voir kSidebarNavDestinations) — restent dans
          // l'IndexedStack pour garder le chrome de navigation visible en
          // les parcourant, au lieu de routes top-level qui le faisaient
          // disparaître entièrement.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.universities,
                builder: (context, state) => const UniversityListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.jobs,
                builder: (context, state) => const JobListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.news,
                builder: (context, state) => const NewsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.chat,
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
        ],
      ),

      // Orientation
      GoRoute(
        path: RoutePaths.orientationRecommendations,
        builder: (context, state) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.orientationSimulation,
        builder: (context, state) => const SimulationScreen(),
      ),

      // Universities (sous-routes — le détail/comparateur restent en dehors
      // du shell, la liste racine est désormais une branche ci-dessus)
      GoRoute(
        path: RoutePaths.universitiesCompare,
        builder: (context, state) => const UniversityCompareScreen(),
      ),
      GoRoute(
        path: RoutePaths.universityDetail,
        builder: (context, state) =>
            UniversityDetailScreen(universityId: state.pathParameters['id']!),
      ),

      // AI assistant (historique — sous-route hors shell)
      GoRoute(
        path: RoutePaths.chatHistory,
        builder: (context, state) => const ChatHistoryScreen(),
      ),

      // Jobs (sous-routes — détail/favoris restent hors shell)
      GoRoute(
        path: RoutePaths.jobsFavorites,
        builder: (context, state) => const JobFavoritesScreen(),
      ),
      GoRoute(
        path: RoutePaths.jobDetail,
        builder: (context, state) =>
            JobDetailScreen(jobId: state.pathParameters['id']!),
      ),

      // Admin
      GoRoute(
        path: RoutePaths.admin,
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminSources,
        builder: (context, state) => const AdminSourcesScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminNews,
        builder: (context, state) => const AdminNewsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAjoutEtablissement,
        builder: (context, state) => const AdminAjoutEtablissementScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAjoutActualite,
        builder: (context, state) => const AdminAjoutContenuScreen(genre: 'actualite'),
      ),
      GoRoute(
        path: RoutePaths.adminAjoutOffre,
        builder: (context, state) => const AdminAjoutContenuScreen(genre: 'offre'),
      ),
    ],
  );
});
