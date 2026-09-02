import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ndimbeul_etudiant/app/app.dart';

void main() {
  testWidgets('App boots and shows the login screen when logged out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsWidgets);
  });
}
