import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'logger.dart';

/// Servicio que carga `assets/data/synonyms_es.json` y mapea palabras
/// (o frases) de la consulta del usuario a tag IDs que existen en
/// la tabla `verse_tags`.
///
/// Uso en MVP (Sprint 2):
///   final tags = lexicon.tokensToTags(userInput);
///   final verseIds = await versesDao.idsByAnyTag(tags);
class LexiconService {
  LexiconService._(this._synonyms);

  final Map<String, List<String>> _synonyms;

  static LexiconService? _instance;
  static bool _loading = false;

  /// Carga el lexicon de forma asíncrona. Es seguro llamar múltiples veces.
  static Future<LexiconService> load(AppLogger logger) async {
    if (_instance != null) return _instance!;
    if (_loading) {
      // Polling simple (debería usarse un Completer en producción).
      while (_instance == null) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return _instance!;
    }
    _loading = true;
    try {
      final String raw = await rootBundle.loadString(
        'assets/data/synonyms_es.json',
      );
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;
      final syn = <String, List<String>>{};
      for (final MapEntry<String, dynamic> e in json.entries) {
        if (e.key.startsWith('_') || e.key == 'version') continue;
        final v = e.value;
        if (v is List) {
          syn[e.key] = v.whereType<String>().toList();
        }
      }
      _instance = LexiconService._(syn);
      logger.i('Lexicon cargado: ${syn.length} entradas.');
      return _instance!;
    } finally {
      _loading = false;
    }
  }

  /// Reinicia la instancia (para tests).
  static void reset() {
    _instance = null;
  }

  /// Tokeniza la consulta y devuelve los tag IDs resultantes.
  ///
  /// Algoritmo (MVP):
  /// 1. Normaliza: lowercase, strip acentos, colapsa espacios.
  /// 2. Divide en palabras.
  /// 3. Construye n-gramas de 1 y 2 palabras.
  /// 4. Busca cada n-grama en el lexicon. Si hay match, agrega los tags.
  /// 5. Devuelve la unión de tags (con duplicados eliminados, orden estable).
  List<String> tokensToTags(String input) {
    if (input.trim().isEmpty) return <String>[];
    final norm = _normalize(input);
    final words = norm.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final Set<String> result = <String>{};
    // Unigramas
    for (final w in words) {
      final tags = _synonyms[w];
      if (tags != null) result.addAll(tags);
    }
    //Bigramas
    for (int i = 0; i + 1 < words.length; i++) {
      final bigram = '${words[i]} ${words[i + 1]}';
      final tags = _synonyms[bigram];
      if (tags != null) result.addAll(tags);
    }
    return result.toList(growable: false);
  }

  /// Devuelve las palabras/frases que tienen entrada en el lexicon.
  /// Útil para highlighting o explicación de la búsqueda.
  List<String> matchedTokens(String input) {
    if (input.trim().isEmpty) return <String>[];
    final norm = _normalize(input);
    final words = norm.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final List<String> matched = <String>[];
    for (int i = 0; i + 1 < words.length; i++) {
      final bigram = '${words[i]} ${words[i + 1]}';
      if (_synonyms.containsKey(bigram)) matched.add(bigram);
    }
    for (final w in words) {
      if (_synonyms.containsKey(w)) matched.add(w);
    }
    return matched;
  }

  /// Tamaño del lexicon (entradas).
  int get size => _synonyms.length;

  String _normalize(String s) {
    // Quita acentos, baja a minúsculas, colapsa espacios.
    final lower = s.toLowerCase();
    final stripped = _stripAccents(lower);
    return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _stripAccents(String s) {
    final Map<String, String> map = <String, String>{
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
      'ä': 'a', 'ë': 'e', 'ï': 'i', 'ö': 'o', 'ü': 'u',
      'â': 'a', 'ê': 'e', 'î': 'i', 'ô': 'o', 'û': 'u',
      'ñ': 'n', 'ç': 'c',
    };
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      buf.write(map[ch] ?? ch);
    }
    return buf.toString();
  }
}
