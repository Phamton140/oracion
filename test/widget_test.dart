import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oracion/app.dart';

void main() {
  testWidgets('App arranca y muestra la pestaña Orar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OracionApp(),
      ),
    );

    // Allow first frame
    await tester.pump();

    // Verifica que se muestra el título de la pestaña inicial.
    expect(find.text('Orar'), findsWidgets);
  });
}
