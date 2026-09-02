import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/orientation/presentation/screens/orientation_screen.dart';
import '../../features/orientation/presentation/screens/recommendations_screen.dart';
import '../../features/orientation/presentation/screens/simulation_screen.dart';
import '../../features/universities/presentation/screens/ecosysteme_screen.dart';
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
import '../../features/admin/presentation/screens/admin_home_screen.dart';
import '../../features/admin/presentation/screens/admin_news_screen.dart';
import '../../features/admin/presentation/screens/admin_sources_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../shell/main_shell.dart';
import '../splash/splash_screen.dart';
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

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_refreshNotifierProvider);

  return GoRouter(
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

      if (!isLoggedIn && !isPublic) return RoutePaths.login;
      if (isLoggedIn && isPublic) {
        return (user?.role.isAdmin ?? false) ? RoutePaths.admin : RoutePaths.dashboard;
      }

      if (loc.startsWith(RoutePaths.admin) && !(user?.role.isAdmin ?? false)) {
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardScreen(),
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
                path: RoutePaths.ecosysteme,
                builder: (context, state) => const EcosystemeScreen(),
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
        builder: (context, state) => UniversityDetailScreen(
          universityId: state.pathParameters['id']!,
        ),
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
    ],
  );
});
