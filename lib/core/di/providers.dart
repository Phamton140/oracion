import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chat/data/chat_repository.dart';
import '../../features/engine/embeddings/embedding_store.dart';
import '../../features/engine/semantic/semantic_index.dart';
import '../../features/engine/semantic/semantic_tokenizer.dart';
import '../../features/engine/services/query_expander.dart';
import '../../features/engine/services/verse_selector.dart';
import '../../features/favorites/data/favorites_repository.dart';
import '../../features/settings/data/data_portability_repository.dart';
import '../database/app_database.dart';
import '../routing/app_router.dart';
import '../services/asset_loader.dart';
import '../services/bible_metadata_service.dart';
import '../services/logger.dart';

// Re-export de IndexByteStore para que consumidores externos
// (tests, build script) puedan usarlos sin importar la ruta
// profunda.
export '../../features/engine/semantic/semantic_index.dart'
    show IndexByteStore, MemoryIndexStore, SemanticIndex;

/// Logger global de la aplicación.
final Provider<AppLogger> loggerProvider = Provider<AppLogger>((Ref ref) {
  return AppLogger.create();
});

/// Instancia única de la base de datos.
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

final FutureProvider<AssetLoader> assetLoaderProvider =
    FutureProvider<AssetLoader>((Ref ref) async {
  final AppLogger logger = ref.watch(loggerProvider);
  final AppDatabase db = ref.watch(appDatabaseProvider);
  final AssetLoader loader = AssetLoader(database: db, logger: logger);
  await loader.ensureBibleSeeded();
  return loader;
});

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

/// Tokenizer semántico.
final Provider<SemanticTokenizer> semanticTokenizerProvider =
    Provider<SemanticTokenizer>((Ref ref) {
  return const SemanticTokenizer();
});

/// QueryExpander curado (cargado desde assets/data/query_synonyms.json).
final FutureProvider<QueryExpander> queryExpanderProvider =
    FutureProvider<QueryExpander>((Ref ref) async {
  return QueryExpander.load();
});

/// Índice BM25 cargado desde assets/data/semantic_index.bin
/// (estilo mmap: usa RandomAccessFile con vistas zero-copy).
final FutureProvider<SemanticIndex> semanticIndexProvider =
    FutureProvider<SemanticIndex>((Ref ref) async {
  final AppLogger logger = ref.watch(loggerProvider);
  final ByteData data = await rootBundle.load('assets/data/semantic_index.bin');
  final Uint8List bytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  logger.i('SemanticIndex: ${bytes.lengthInBytes} bytes cargados.');
  return SemanticIndex.open(MemoryIndexStore(bytes));
});

/// Embeddings densos (Word2Vec subword) cargados desde
/// assets/data/verse_embeddings.bin.
final FutureProvider<EmbeddingStore> embeddingStoreProvider =
    FutureProvider<EmbeddingStore>((Ref ref) async {
  final AppLogger logger = ref.watch(loggerProvider);
  final ByteData data =
      await rootBundle.load('assets/data/verse_embeddings.bin');
  final Uint8List bytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  logger.i('EmbeddingStore: ${bytes.lengthInBytes} bytes cargados.');
  return EmbeddingStore.open(MemoryIndexStore(bytes));
});

/// Bible Engine v2: VerseSelector (BM25 + embeddings + MMR).
final FutureProvider<VerseSelector> verseSelectorProvider =
    FutureProvider<VerseSelector>((Ref ref) async {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  final SemanticIndex index = await ref.watch(semanticIndexProvider.future);
  final EmbeddingStore embeddings =
      await ref.watch(embeddingStoreProvider.future);
  final SemanticTokenizer tokenizer = ref.watch(semanticTokenizerProvider);
  final QueryExpander expander = await ref.watch(queryExpanderProvider.future);
  return VerseSelector(
    versesDao: db.versesDao,
    bm25Index: index,
    embeddings: embeddings,
    tokenizer: tokenizer,
    expander: expander,
    contextDao: db.contextDao,
  );
});

/// Chat repository.
final Provider<ChatRepository> chatRepositoryProvider =
    Provider<ChatRepository>((Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  final AppLogger logger = ref.watch(loggerProvider);
  final VerseSelector selector =
      ref.watch(verseSelectorProvider).requireValue;
  return ChatRepository(
    conversationsDao: db.conversationsDao,
    messagesDao: db.messagesDao,
    selector: selector,
    usageStatsDao: db.usageStatsDao,
    logger: logger,
  );
});

/// Metadata bíblica (libros, alias, conteos).
final Provider<BibleMetadataService> bibleMetadataProvider =
    Provider<BibleMetadataService>((Ref ref) {
  final AppLogger logger = ref.watch(loggerProvider);
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return BibleMetadataService(versesDao: db.versesDao, logger: logger);
});

/// Favoritos.
final Provider<FavoritesRepository> favoritesRepositoryProvider =
    Provider<FavoritesRepository>((Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  final AppLogger logger = ref.watch(loggerProvider);
  return FavoritesRepository(
    favoritesDao: db.favoritesDao,
    usageStatsDao: db.usageStatsDao,
    logger: logger,
  );
});

/// Portabilidad (export/import).
final Provider<DataPortabilityRepository> dataPortabilityRepositoryProvider =
    Provider<DataPortabilityRepository>((Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  final AppLogger logger = ref.watch(loggerProvider);
  return DataPortabilityRepository(database: db, logger: logger);
});

/// Configuración del router.
final Provider<GoRouterConfig> appRouterProvider =
    Provider<GoRouterConfig>((Ref ref) {
  return GoRouterConfig.create();
});
