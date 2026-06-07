import '../../../core/database/app_database.dart';

/// Candidato a versículo en el pipeline del Bible Engine.
///
/// Representa un versículo con su puntuación de relevancia y los tags
/// que hicieron match con la consulta del usuario. Es una clase interna
/// al selector; no se persiste ni se expone directamente en la UI.
class VerseCandidate {
  const VerseCandidate({
    required this.verse,
    required this.score,
    required this.matchedTags,
  });

  /// Versículo de la base de datos.
  final Verse verse;

  /// Puntuación de relevancia (mayor es mejor). En MVP es el conteo
  /// de tags coincidentes con la consulta del usuario.
  final double score;

  /// Lista de tags que hicieron match (puede estar vacía si se
  /// obtuvo por fallback aleatorio).
  final List<String> matchedTags;

  /// Acceso rápido al número de libro (evita repetir `verse.bookNumber`).
  int get bookNumber => verse.bookNumber;

  /// Referencia canónica legible (ej. "Juan 3:16").
  String get reference => '${verse.book} ${verse.chapter}:${verse.verse}';

  @override
  String toString() =>
      'VerseCandidate($reference, score=$score, tags=$matchedTags)';
}
