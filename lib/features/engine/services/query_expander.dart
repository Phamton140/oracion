import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Expansor de queries para el motor de retrieval.
///
/// A diferencia del lexicon anterior (que mapeaba a tags), este
/// expansor añade sinónimos curados a la query del usuario. La
/// query expandida se pasa a BM25 + embeddings.
///
/// Ejemplo:
///   Input:  "debo dinero"
///   Output: "debo deuda deudor deber prestar pago dinero
///            moneda plata rico pobreza"
///
/// El diccionario es pequeño (~300-500 entradas) y se centra en
/// los temas más comunes de la Biblia (amor, miedo, dinero,
/// enfermedad, muerte, perdón, oración, etc.).
class QueryExpander {
  QueryExpander._(this._synonyms);

  final Map<String, List<String>> _synonyms;

  static QueryExpander? _instance;
  static bool _loading = false;

  /// Carga el diccionario de sinónimos curado desde assets.
  static Future<QueryExpander> load({String assetPath = 'assets/data/query_synonyms.json'}) async {
    if (_instance != null) return _instance!;
    if (_loading) {
      while (_instance == null) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return _instance!;
    }
    _loading = true;
    try {
      final String raw = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, List<String>> syn = <String, List<String>>{};
      json.forEach((String key, dynamic value) {
        if (value is List) {
          syn[key] = value.whereType<String>().toList();
        }
      });
      _instance = QueryExpander._(syn);
      return _instance!;
    } finally {
      _loading = false;
    }
  }

  /// Construye un expander en memoria (para tests).
  static QueryExpander forTesting(Map<String, List<String>> synonyms) {
    return QueryExpander._(
      <String, List<String>>{
        for (final MapEntry<String, List<String>> e in synonyms.entries)
          e.key: <String>[...e.value],
      },
    );
  }

  /// Resetea la instancia singleton (para tests).
  static void reset() {
    _instance = null;
  }

  /// Expande una query devolviendo la unión de los términos de la
  /// query original más los sinónimos de cada palabra.
  ///
  /// `originalTokens` se devuelve primero (peso mayor) y los
  /// sinónimos se añaden al final.
  List<String> expand(List<String> originalTokens) {
    if (originalTokens.isEmpty) return const <String>[];
    final List<String> out = <String>[...originalTokens];
    for (final String t in originalTokens) {
      final String norm = t.toLowerCase();
      final List<String>? syns = _synonyms[norm];
      if (syns != null) {
        for (final String s in syns) {
          if (!out.contains(s)) out.add(s);
        }
      }
    }
    return out;
  }

  /// Tamaño del diccionario (entradas).
  int get size => _synonyms.length;

  /// Vocabulario completo del diccionario.
  Set<String> get vocabulary => _synonyms.keys.toSet();
}
