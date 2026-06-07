import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/di/providers.dart';

/// Snapshot inmutable de los settings que afectan al `MaterialApp`.
///
/// Se reconstruye cada vez que la tabla `settings` cambia, propagando
/// el cambio de tema y tamaño de letra al `MaterialApp.router` de forma
/// reactiva (vía Riverpod).
@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.fontScale,
    this.bibleTranslation,
    this.assetsVersion,
  });

  final ThemeMode themeMode;
  final double fontScale;
  final String? bibleTranslation;
  final String? assetsVersion;

  static const AppSettings defaults = AppSettings(
    themeMode: ThemeMode.system,
    fontScale: 1.0,
  );

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    String? bibleTranslation,
    String? assetsVersion,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      bibleTranslation: bibleTranslation ?? this.bibleTranslation,
      assetsVersion: assetsVersion ?? this.assetsVersion,
    );
  }

  static ThemeMode parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static double parseFontScale(String? raw) {
    if (raw == null) return 1.0;
    return double.tryParse(raw) ?? 1.0;
  }
}

/// Stream reactivo del snapshot de settings persistidos en la DB.
///
/// Usa `select(...).watch()` de Drift para emitir un nuevo `AppSettings`
/// cada vez que cambia cualquier fila de la tabla `settings`. Es la
/// única fuente de verdad: lo que se guarde en la DB aparece de
/// inmediato en el `MaterialApp.router`.
final StreamProvider<AppSettings> appSettingsProvider =
    StreamProvider<AppSettings>((Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return db.select(db.settings).watch().map(
        (List<Setting> rows) => _toAppSettings(rows),
      );
});

AppSettings _toAppSettings(List<Setting> rows) {
  if (rows.isEmpty) return AppSettings.defaults;
  final Map<String, String> map = <String, String>{
    for (final Setting s in rows) s.key: s.value,
  };
  return AppSettings(
    themeMode: AppSettings.parseThemeMode(map[AppConstants.settingThemeMode]),
    fontScale: AppSettings.parseFontScale(map[AppConstants.settingFontScale]),
    bibleTranslation: map['bible_translation'],
    assetsVersion: map[AppConstants.settingAssetsVersion],
  );
}
