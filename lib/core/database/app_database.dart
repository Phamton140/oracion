import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/context_dao.dart';
import 'daos/conversations_dao.dart';
import 'daos/favorites_dao.dart';
import 'daos/messages_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/usage_stats_dao.dart';
import 'daos/verses_dao.dart';

part 'app_database.g.dart';

// ============================================================================
// TABLAS
// ============================================================================

@DataClassName('Verse')
class Verses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get book => text()();
  IntColumn get bookNumber => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get body => text()();
  TextColumn get translation =>
      text().withDefault(const Constant<String>('RV1909'))();
}

@DataClassName('VerseTag')
class VerseTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get verseId => integer().references(Verses, #id)();
  TextColumn get tag => text()();
  RealColumn get weight => real().withDefault(const Constant<double>(1.0))();
}

@DataClassName('Conversation')
class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get title => text().nullable()();
}

@DataClassName('Message')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId =>
      integer().references(Conversations, #id)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  IntColumn get verseId =>
      integer().nullable().references(Verses, #id)();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('ConversationContextEntry')
class ConversationContexts extends Table {
  IntColumn get conversationId =>
      integer().references(Conversations, #id)();
  TextColumn get dominantEmotion => text().nullable()();
  TextColumn get dominantIntent => text().nullable()();
  TextColumn get topicTagsJson => text().nullable()();
  TextColumn get shownVerseIdsJson => text().nullable()();
  BlobColumn get centroid => blob().nullable()();
  IntColumn get turnCount => integer().withDefault(const Constant<int>(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{conversationId};
}

@DataClassName('Favorite')
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get verseId => integer().references(Verses, #id)();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get note => text().nullable()();
}

@DataClassName('Setting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@DataClassName('UsageStat')
class UsageStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationsCreated =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get searchesPerformed =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get favoritesSaved =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get versesShared =>
      integer().withDefault(const Constant<int>(0))();
  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================================
// BASE DE DATOS
// ============================================================================

@DriftDatabase(
  tables: <Type>[
    Verses,
    VerseTags,
    Conversations,
    Messages,
    ConversationContexts,
    Favorites,
    Settings,
    UsageStats,
  ],
  daos: <Type>[
    VersesDao,
    ConversationsDao,
    MessagesDao,
    ContextDao,
    FavoritesDao,
    SettingsDao,
    UsageStatsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Por ahora no hay migraciones entre versiones.
          // En futuras versiones se añadirán pasos aquí.
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedInitialData() async {
    // Inserta la fila única de UsageStats con valores en cero.
    await into(usageStats).insert(
      UsageStatsCompanion.insert(
        updatedAt: DateTime.now(),
      ),
    );

    // Inserta settings por defecto. El setting `assets_version` se
    // actualiza posteriormente desde el `AssetLoader` después del
    // primer seed del corpus bíblico.
    await batch((Batch b) {
      b.insert(
        settings,
        SettingsCompanion.insert(
          key: 'theme_mode',
          value: 'system',
        ),
      );
      b.insert(
        settings,
        SettingsCompanion.insert(
          key: 'font_scale',
          value: '1.0',
        ),
      );
    });
  }

  /// Cierra la conexión. Llamar desde el dispose del provider.
  @override
  Future<void> close() async {
    await super.close();
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'oracion_db');
}
