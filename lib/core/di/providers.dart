import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../routing/app_router.dart';
import '../services/asset_loader.dart';
import '../services/bible_metadata_service.dart';
import '../services/lexicon_service.dart';
import '../services/logger.dart';

/// Logger global de la aplicación.
final Provider<AppLogger> loggerProvider = Provider<AppLogger>((Ref ref) {
  return AppLogger.create();
});

/// Instancia única de la base de datos.
///
/// Se cierra automáticamente cuando el `ProviderContainer` se
/// destruye al cerrar la app.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppLogger logger = ref.watch(loggerProvider);
  final AppDatabase db = AppDatabase();

  logger.i('AppDatabase inicializada');

  ref.onDispose(() async {
    logger.i('Cerrando AppDatabase');
    await db.close();
  });

  return db;
});

/// AssetLoader: gestiona la carga del corpus bíblico desde el APK
/// al drift DB en el primer arranque (o cuando cambia la versión).
final FutureProvider<AssetLoader> assetLoaderProvider =
    FutureProvider<AssetLoader>((Ref ref) async {
  final AppLogger logger = ref.watch(loggerProvider);
  final AppDatabase db = ref.watch(appDatabaseProvider);
  final AssetLoader loader = AssetLoader(database: db, logger: logger);
  await loader.ensureBibleSeeded();
  return loader;
});

/// Estado de carga inicial de los assets bíblicos.
final StateNotifierProvider<AssetLoadStatusNotifier, AssetLoadStatus>
    assetLoadStatusProvider =
    StateNotifierProvider<AssetLoadStatusNotifier, AssetLoadStatus>(
        (Ref ref) {
  return AssetLoadStatusNotifier();
});

class AssetLoadStatus {
  const AssetLoadStatus({this.loading = true, this.error, this.seeded = false});
  final bool loading;
  final Object? error;
  final bool seeded;

  AssetLoadStatus copyWith({bool? loading, Object? error, bool? seeded}) {
    return AssetLoadStatus(
      loading: loading ?? this.loading,
      error: error,
      seeded: seeded ?? this.seeded,
    );
  }
}

class AssetLoadStatusNotifier extends StateNotifier<AssetLoadStatus> {
  AssetLoadStatusNotifier() : super(const AssetLoadStatus());

  void markSeeded() {
    state = state.copyWith(loading: false, seeded: true, error: null);
  }

  void markError(Object e) {
    state = state.copyWith(loading: false, seeded: false, error: e);
  }
}

/// Lexicon de sinónimos español -> tag IDs.
final FutureProvider<LexiconService> lexiconProvider =
    FutureProvider<LexiconService>((Ref ref) async {
  final AppLogger logger = ref.watch(loggerProvider);
  return LexiconService.load(logger);
});

/// Servicio de metadata de la Biblia (libros, alias, conteos).
final Provider<BibleMetadataService> bibleMetadataProvider =
    Provider<BibleMetadataService>((Ref ref) {
  final AppLogger logger = ref.watch(loggerProvider);
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return BibleMetadataService(versesDao: db.versesDao, logger: logger);
});

/// Configuración del router de la app.
///
/// Provider separado para mantener la inicialización de GoRouter
/// testeable y para permitir invalidación al cambiar configuración.
final Provider<GoRouterConfig> appRouterProvider =
    Provider<GoRouterConfig>((Ref ref) {
  return GoRouterConfig.create();
});
