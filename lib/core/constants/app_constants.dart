/// Constantes globales de la aplicación Oración.
///
/// IMPORTANTE: el principio "Oración no responde al usuario,
/// Oración encuentra y presenta pasajes bíblicos relevantes" se
/// aplica en todo el código. Cualquier función que produzca texto
/// visible para el usuario debe tomar su contenido de la base de
/// datos local de versículos, nunca de un modelo generativo.
class AppConstants {
  const AppConstants._();

  /// Nombre del paquete (Android).
  static const String packageName = 'com.oracion.oracion';

  /// Locale soportado en MVP.
  static const String supportedLocaleCode = 'es';

  /// Traducción bíblica por defecto.
  static const String defaultTranslation = 'RV1909';

  /// Versión del esquema de la base local.
  static const int dbSchemaVersion = 1;

  /// Versión de los assets binarios empaquetados (versículos, tags,
  /// embeddings, sinonimos). Se incrementa cuando se publica un
  /// corpus bíblico nuevo. Lo gestiona el `AssetLoader` leyendo
  /// el `bible_assets.manifest.json` en el APK.
  static const int assetsVersion = 1;

  /// Identificador del logger.
  static const String loggerName = 'oracion';

  /// Claves estándar de la tabla `settings`.
  static const String settingThemeMode = 'theme_mode';
  static const String settingFontScale = 'font_scale';
  static const String settingAssetsVersion = 'assets_version';
  static const String settingLastBackupAt = 'last_backup_at';

  /// Límite de versículos recordados en la sesión actual (en RAM).
  /// Más allá de este número, los antiguos se eliminan del set
  /// en memoria para evitar crecimiento ilimitado.
  static const int sessionRecentVersesLimit = 50;
}

/// Principio fundamental de Oración (documentación de referencia).
///
/// "Oración no responde al usuario.
/// Oración encuentra y presenta pasajes bíblicos relevantes.
/// Toda respuesta visible para el usuario proviene de la Biblia."
abstract class ProjectPrinciples {
  const ProjectPrinciples._();

  /// La IA nunca genera respuestas.
  static const String aiNeverGeneratesResponses =
      'La IA nunca genera respuestas.';

  /// La IA nunca actúa como Dios.
  static const String aiNeverActsAsGod =
      'La IA nunca actúa como Dios.';

  /// La IA nunca produce texto libre para responder.
  static const String aiNeverProducesFreeText =
      'La IA nunca produce texto libre para responder al usuario.';

  /// La IA solo ayuda a encontrar pasajes.
  static const String aiOnlyHelpsFindPassages =
      'La IA solo ayuda a encontrar pasajes relevantes.';

  /// La respuesta final siempre proviene de la Biblia.
  static const String finalAnswerFromBible =
      'La respuesta final siempre proviene de la Biblia.';
}
