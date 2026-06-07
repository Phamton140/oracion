import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oracion/app.dart';
import 'package:oracion/core/database/app_database.dart';
import 'package:oracion/core/di/providers.dart';
import 'package:oracion/features/settings/data/app_settings.dart';

void main() {
  testWidgets('App arranca y muestra la pestaña Orar', (WidgetTester tester) async {
    // Para evitar la apertura real de sqlite3 (que programa un
    // Timer de 0ms en fake-async) y para que el árbol de widgets
    // no quede a la espera de un timer pendiente, anulamos los
    // providers que disparan trabajo async contra la DB.
    final AppDatabase testDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(testDb.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(testDb),
          // Devolvemos defaults síncronamente para no abrir streams
          // de Drift durante el smoke test.
          appSettingsProvider.overrideWith(
            (Ref ref) =>
                Stream<AppSettings>.value(AppSettings.defaults),
          ),
        ],
        child: const OracionApp(),
      ),
    );

    await tester.pump();

    // Verifica que se muestra el título de la pestaña inicial.
    expect(find.text('Orar'), findsWidgets);
  });
}
