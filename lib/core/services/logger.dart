import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// Logger central de la aplicación Oración.
///
/// En Sprint 1 solo imprime a stdout. En sprints futuros se puede
/// redirigir a archivo en `ApplicationDocumentsDirectory/logs/`.
class AppLogger {
  AppLogger._(this._logger);

  factory AppLogger.create() {
    final Logger logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: Level.debug,
    );
    return AppLogger._(logger);
  }

  final Logger _logger;

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.d('${AppConstants.loggerName} | $message',
          error: error, stackTrace: stackTrace);

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.i('${AppConstants.loggerName} | $message',
          error: error, stackTrace: stackTrace);

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.w('${AppConstants.loggerName} | $message',
          error: error, stackTrace: stackTrace);

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e('${AppConstants.loggerName} | $message',
          error: error, stackTrace: stackTrace);

  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.f('${AppConstants.loggerName} | $message',
          error: error, stackTrace: stackTrace);
}
