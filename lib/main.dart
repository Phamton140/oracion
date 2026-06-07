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
  logger.i('Oración iniciando — Sprint 4');

  // Pre-cargar el corpus bíblico, el índice semántico y los
  // embeddings en background. La app muestra un splash hasta
  // que termine.
  try {
    await container.read(assetLoaderProvider.future);
    logger.i('Corpus bíblico listo.');
  } catch (e, st) {
    logger.e('Error cargando el corpus bíblico', e, st);
  }
  try {
    await container.read(semanticIndexProvider.future);
    logger.i('Índice semántico listo.');
  } catch (e, st) {
    logger.e('Error cargando el índice semántico', e, st);
  }
  try {
    await container.read(embeddingStoreProvider.future);
    logger.i('Embeddings listos.');
  } catch (e, st) {
    logger.e('Error cargando los embeddings', e, st);
  }
  try {
    await container.read(queryExpanderProvider.future);
    logger.i('Query expander listo.');
  } catch (e, st) {
    logger.e('Error cargando el query expander', e, st);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const OracionApp(),
    ),
  );
}
