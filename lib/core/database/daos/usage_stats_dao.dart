import 'package:drift/drift.dart';

import '../app_database.dart';

part 'usage_stats_dao.g.dart';

/// DAO para la tabla `usage_stats` (contadores locales).
///
/// Las estadísticas son exclusivamente locales y nunca se envían
/// a ningún servidor.
@DriftAccessor(tables: <Type>[UsageStats])
class UsageStatsDao extends DatabaseAccessor<AppDatabase>
    with _$UsageStatsDaoMixin {
  UsageStatsDao(super.db);

  /// Lee la fila única de estadísticas.
  Future<UsageStat> get() async {
    final row = await (select(usageStats)..limit(1)).getSingleOrNull();
    if (row != null) return row;
    // Si no existe (caso muy raro, debería haber sido seedeada por Drift),
    // la creamos.
    return (await into(usageStats).insertReturning(
      UsageStatsCompanion.insert(updatedAt: DateTime.now()),
    ));
  }

  Future<UsageStat> _getOrCreate() async {
    final existing = await (select(usageStats)..limit(1)).getSingleOrNull();
    if (existing != null) return existing;
    return (await into(usageStats).insertReturning(
      UsageStatsCompanion.insert(updatedAt: DateTime.now()),
    ));
  }

  Future<void> incrementConversations({int by = 1}) async {
    final s = await _getOrCreate();
    await (update(usageStats)..where(($UsageStatsTable u) => u.id.equals(s.id)))
        .write(UsageStatsCompanion(
      conversationsCreated: Value<int>(s.conversationsCreated + by),
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
  }

  Future<void> incrementSearches({int by = 1}) async {
    final s = await _getOrCreate();
    await (update(usageStats)..where(($UsageStatsTable u) => u.id.equals(s.id)))
        .write(UsageStatsCompanion(
      searchesPerformed: Value<int>(s.searchesPerformed + by),
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
  }

  Future<void> incrementFavorites({int by = 1}) async {
    final s = await _getOrCreate();
    await (update(usageStats)..where(($UsageStatsTable u) => u.id.equals(s.id)))
        .write(UsageStatsCompanion(
      favoritesSaved: Value<int>(s.favoritesSaved + by),
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
  }

  Future<void> incrementShared({int by = 1}) async {
    final s = await _getOrCreate();
    await (update(usageStats)..where(($UsageStatsTable u) => u.id.equals(s.id)))
        .write(UsageStatsCompanion(
      versesShared: Value<int>(s.versesShared + by),
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
  }
}
