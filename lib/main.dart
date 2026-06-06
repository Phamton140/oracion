import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fijar orientación a portrait (móvil)
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Estilo de barra de estado
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final ProviderContainer container = ProviderContainer();

  final logger = container.read(loggerProvider);
  logger.i('Oración iniciando — Sprint 2');

  // Pre-cargar el corpus bíblico en background. La app muestra un
  // splash hasta que termine.
  try {
    await container.read(assetLoaderProvider.future);
    logger.i('Corpus bíblico listo.');
  } catch (e, st) {
    logger.e('Error cargando el corpus bíblico', e, st);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const OracionApp(),
    ),
  );
}
