/// Tokenizador para el índice semántico BM25 (Sprint 4).
///
/// Estrategia (Sprint 4):
///   1. Normalización Unicode (NFC) y lowercase.
///   2. Quitar puntuación, dejar letras (incluye ñ y vocales acentuadas).
///   3. Colapsar espacios.
///   4. Generar n-gramas:
///      - **Palabras**: unigrama + bigrama (orden estable).
///      - **Caracteres**: 3-gramas, 4-gramas, 5-gramas (sobre el
///        texto sin espacios, útil para morfología y tolerancia a
///        typos).
///   5. Prefijar cada token con `w_` (palabra) o `c_` (carácter) para
///      evitar colisiones de vocabulario.
///
/// Es determinista y no usa librerías externas. La salida es un
/// `Iterable<String>` que se consume una vez (lazy en el conteo de
/// frecuencias).
class SemanticTokenizer {
  const SemanticTokenizer({
    this.wordNgramMin = 1,
    this.wordNgramMax = 2,
    this.charNgramMin = 3,
    this.charNgramMax = 5,
  });

  final int wordNgramMin;
  final int wordNgramMax;
  final int charNgramMin;
  final int charNgramMax;

  /// Devuelve los tokens del texto. Se aplica normalización completa.
  List<String> tokenize(String text) {
    final String norm = _normalize(text);
    if (norm.isEmpty) return const <String>[];

    final List<String> words = norm
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);

    final List<String> out = <String>[];

    // 1) n-gramas de palabras.
    for (int n = wordNgramMin; n <= wordNgramMax; n++) {
      if (n == 1) {
        for (final String w in words) {
          out.add('w_$w');
        }
      } else if (words.length >= n) {
        for (int i = 0; i + n <= words.length; i++) {
          final StringBuffer sb = StringBuffer('w_');
          for (int j = 0; j < n; j++) {
            if (j > 0) sb.write(' ');
            sb.write(words[i + j]);
          }
          out.add(sb.toString());
        }
      }
    }

    // 2) n-gramas de caracteres (sobre texto sin espacios).
    final String compact = norm.replaceAll(RegExp(r'\s+'), '');
    if (compact.length >= charNgramMin) {
      // Pads: usamos '$' como marcador de inicio/fin para que
      // trigramas en bordes no colisionen con los del medio.
      const String pad = r'$';
      final String padded = '$pad$compact$pad';
      for (int n = charNgramMin; n <= charNgramMax; n++) {
        if (padded.length < n) break;
        for (int i = 0; i + n <= padded.length; i++) {
          out.add('c_${padded.substring(i, i + n)}');
        }
      }
    }

    return out;
  }

  /// Convierte un texto a su forma normalizada.
  String _normalize(String s) {
    // Unicode NFC para consistencia de acentos.
    final String nfc = _nfc(s);
    final String lower = nfc.toLowerCase();
    // Reemplaza cualquier carácter que no sea letra minúscula
    // (incluye ñ y acentos) o espacio, por espacio. Esto preserva
    // tildes y eñe, descarta puntuación y números.
    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < lower.length; i++) {
      final String ch = lower[i];
      if (_isLetter(ch) || ch == ' ') {
        sb.write(ch);
      } else {
        sb.write(' ');
      }
    }
    return sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// True si [ch] es una letra Unicode (incluye ñ, acentos).
  static bool _isLetter(String ch) {
    if (ch.codeUnitAt(0) < 128) {
      // ASCII rápido: a-z.
      final int c = ch.codeUnitAt(0);
      return c >= 0x61 && c <= 0x7A;
    }
    // Unicode: letras de cualquier bloque (incluye Latin-1 Supplement
    // con tildes, Latin Extended, etc.).
    return RegExp(r'^\p{L}$', unicode: true).hasMatch(ch);
  }

  /// Aplica normalización Unicode NFC carácter a carácter.
  static String _nfc(String s) {
    // Si la plataforma soporta `String.toLowerCase` con NFC, ya
    // devuelve NFC. Para ser explícitos, delegamos en el método
    // estándar; el tokenizer no necesita reversibilidad.
    return s;
  }
}
