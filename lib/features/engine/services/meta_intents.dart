/// Referencia canónica a un versículo (libro + capítulo + versículo).
/// Se usa para identificar versículos en [MetaIntent] sin atarse
/// a IDs autoincrementales de la base de datos.
class MetaVerseRef {
  const MetaVerseRef({
    required this.bookNumber,
    required this.chapter,
    required this.verse,
  });

  final int bookNumber;
  final int chapter;
  final int verse;

  @override
  String toString() => '$bookNumber:$chapter:$verse';
}

/// Overrides hardcoded para queries que NO son tópicos sino
/// "meta-comandos" muy básicos: saludos, agradecimientos,
/// despedidas, amén.
///
/// Cada override se activa cuando la query normalizada contiene
/// TODAS las palabras clave del slot. Es deliberadamente
/// pequeño y conservador: 5-10 entradas, sin lógica condicional
/// compleja, fácil de mantener y debuggear.
///
/// El resultado es una lista de referencias (book/chapter/verse)
/// que se resuelven a IDs reales al cargar la app, y se devuelven
/// tal cual, sin pasar por BM25 ni embeddings.
class MetaIntent {
  const MetaIntent({
    required this.id,
    required this.keywords,
    required this.refs,
    this.description = '',
  });

  /// Identificador legible para logs.
  final String id;

  /// Palabras clave que disparan este intent. Se matchean
  /// como intersección con la query normalizada (todas deben
  /// estar presentes).
  final List<String> keywords;

  /// Referencias a versículos (libro + cap + verse).
  final List<MetaVerseRef> refs;

  /// Descripción legible.
  final String description;
}

class MetaIntents {
  const MetaIntents._();

  /// Conjunto hardcoded de meta-intents.
  ///
  /// IMPORTANTE: estos son los ÚNICOS casos donde el sistema
  /// ignora el retrieval. Cualquier otra query va a BM25 +
  /// embeddings. Si el retrieval no encuentra nada, igual
  /// devuelve el top-3 (no aleatorio, no fallback vacío).
  static const List<MetaIntent> intents = <MetaIntent>[
    MetaIntent(
      id: 'greeting',
      keywords: <String>['hola'],
      refs: <MetaVerseRef>[
        MetaVerseRef(bookNumber: 4, chapter: 6, verse: 24),
        MetaVerseRef(bookNumber: 4, chapter: 6, verse: 25),
        MetaVerseRef(bookNumber: 19, chapter: 23, verse: 1),
      ],
      description: 'Saludo inicial',
    ),
    MetaIntent(
      id: 'good_morning',
      keywords: <String>['buenos', 'dias'],
      refs: <MetaVerseRef>[
        MetaVerseRef(bookNumber: 19, chapter: 5, verse: 3),
        MetaVerseRef(bookNumber: 19, chapter: 143, verse: 8),
        MetaVerseRef(bookNumber: 23, chapter: 50, verse: 7),
      ],
      description: 'Saludo matutino',
    ),
    MetaIntent(
      id: 'thanks',
      keywords: <String>['gracias'],
      refs: <MetaVerseRef>[
        MetaVerseRef(bookNumber: 19, chapter: 107, verse: 1),
        MetaVerseRef(bookNumber: 13, chapter: 16, verse: 34),
        MetaVerseRef(bookNumber: 19, chapter: 136, verse: 1),
      ],
      description: 'Acción de gracias',
    ),
    MetaIntent(
      id: 'amen',
      keywords: <String>['amen'],
      refs: <MetaVerseRef>[
        MetaVerseRef(bookNumber: 66, chapter: 22, verse: 20),
        MetaVerseRef(bookNumber: 66, chapter: 22, verse: 21),
        MetaVerseRef(bookNumber: 49, chapter: 1, verse: 3),
      ],
      description: 'Cierre con amén',
    ),
    MetaIntent(
      id: 'goodbye',
      keywords: <String>['adios'],
      refs: <MetaVerseRef>[
        MetaVerseRef(bookNumber: 19, chapter: 121, verse: 7),
        MetaVerseRef(bookNumber: 19, chapter: 121, verse: 8),
        MetaVerseRef(bookNumber: 19, chapter: 23, verse: 6),
      ],
      description: 'Despedida',
    ),
  ];

  /// Devuelve el primer intent que matchea la query, o null.
  /// El match es: TODAS las keywords del intent deben estar
  /// presentes en los tokens normalizados de la query.
  static MetaIntent? match(List<String> normalizedTokens) {
    if (normalizedTokens.isEmpty) return null;
    final Set<String> set = normalizedTokens.toSet();
    for (final MetaIntent intent in intents) {
      bool allPresent = true;
      for (final String k in intent.keywords) {
        if (!set.contains(k)) {
          allPresent = false;
          break;
        }
      }
      if (allPresent) return intent;
    }
    return null;
  }
}
