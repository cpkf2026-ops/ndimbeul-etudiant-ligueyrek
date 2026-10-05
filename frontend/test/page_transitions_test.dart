import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ndimbeul_etudiant/app/theme/app_theme.dart';
import 'package:ndimbeul_etudiant/app/theme/page_transitions.dart';

/// Vérifie que les transitions de page jouent réellement : vague (ClipPath)
/// à l'ouverture d'une route, glissement + trait doré au changement d'onglet.
void main() {
  GoRouter buildRouter() => GoRouter(
        initialLocation: '/a',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) => Scaffold(
              body: BranchSwitchAnimator(index: shell.currentIndex, child: shell),
            ),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/a',
                  builder: (context, state) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => context.push('/detail'),
                          child: const Text('ouvrir detail'),
                        ),
                        TextButton(
                          onPressed: () => context.go('/b'),
                          child: const Text('onglet b'),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: '/b', builder: (context, state) => const Text('page b')),
              ]),
            ],
          ),
          GoRoute(path: '/detail', builder: (context, state) => const Text('page detail')),
        ],
      );

  Widget app(GoRouter router) => MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => TapTrackerScope(child: child!),
      );

  testWidgets('ouvrir une page joue la vague', (tester) async {
    await tester.pumpWidget(app(buildRouter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ouvrir detail'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(TapTracker.lastPosition, isNotNull);
    expect(find.byType(ClipPath), findsWidgets, reason: 'la vague doit être en cours');

    await tester.pumpAndSettle();
    expect(find.text('page detail'), findsOneWidget);
  });

  testWidgets("changer d'onglet joue le glissement", (tester) async {
    await tester.pumpWidget(app(buildRouter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('onglet b'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final opacities = tester
        .widgetList<Opacity>(find.descendant(
          of: find.byType(BranchSwitchAnimator),
          matching: find.byType(Opacity),
        ))
        .map((o) => o.opacity);
    expect(opacities.any((o) => o > 0 && o < 1), isTrue,
        reason: 'le contenu doit être en train d’apparaître');

    await tester.pumpAndSettle();
    expect(find.text('page b'), findsOneWidget);
  });
}
