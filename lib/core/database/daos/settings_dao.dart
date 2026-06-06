import 'package:drift/drift.dart';

import '../app_database.dart';

part 'settings_dao.g.dart';

/// DAO para la tabla `settings` (key-value).
@DriftAccessor(tables: <Type>[Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Lee un setting por clave. Retorna `null` si no existe.
  Future<String?> getValue(String key) async {
    final row = await (select(settings)
          ..where(($SettingsTable s) => s.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return row?.value;
  }

  /// Inserta o reemplaza un setting (upsert).
  Future<void> setValue(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }

  /// Lee todos los settings como Map.
  Future<Map<String, String>> allAsMap() async {
    final rows = await select(settings).get();
    return <String, String>{for (final s in rows) s.key: s.value};
  }

  /// Stream reactivo de un setting.
  Stream<String?> watchValue(String key) {
    return (select(settings)..where(($SettingsTable s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }
}
