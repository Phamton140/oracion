import 'package:intl/intl.dart';

/// Formateo de fechas.
extension DateTimeFormatting on DateTime {
  String get formattedShort =>
      DateFormat('d MMM y', 'es').format(this);

  String get formattedLong =>
      DateFormat("d 'de' MMMM 'de' y", 'es').format(this);

  String get formattedTime =>
      DateFormat('HH:mm', 'es').format(this);

  String get formattedDateTime =>
      DateFormat("d MMM y · HH:mm", 'es').format(this);

  /// Devuelve true si es del mismo día que [other].
  bool isSameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

/// Helpers sobre Strings.
extension StringHelpers on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get trimmed => trim();
}
