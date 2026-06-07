/// Constantes relacionadas con la Biblia y el motor bíblico.
class BibleConstants {
  const BibleConstants._();

  /// Número de libros en la Biblia completa.
  static const int totalBooks = 66;

  /// Número aproximado de versículos en RV1909.
  /// (Valor real: 31.102. Se mantiene como constante para uso
  /// en layouts y benchmarks sin necesidad de consultar la DB.)
  static const int approximateVerseCount = 31102;

  /// Tamaño del Top-K inicial en el Bible Engine.
  /// Se recuperan K candidatos antes del re-ranking final.
  static const int topKCandidates = 50;

  /// Tamaño de la lista negra de versículos por conversación.
  /// Limita la longitud de `ConversationContext.shownVerseIdsJson`.
  static const int conversationShownVerseLimit = 20;

  // ---------------------------------------------------------------------------
  // Sprint 4: índice BM25 + embeddings subword (no TF-IDF, no dense NN)
  // ---------------------------------------------------------------------------

  /// Asset path del índice semántico binario.
  static const String semanticIndexAssetPath =
      'assets/data/semantic_index.bin';

  /// Magic header del archivo `semantic_index.bin` (4 bytes ASCII).
  /// "O" "R" "S" "I" = ORación Semantic Index.
  static const int semanticIndexMagic = 0x4953524F;

  /// Versión del formato binario del índice semántico.
  static const int semanticIndexFormatVersion = 1;

  /// Tamaño fijo del header del índice semántico en bytes.
  /// 4 (magic) + 4 (version) + 5*4 (uint32) + 6*8 (uint64) = 72.
  static const int semanticIndexHeaderSize = 72;

  /// Constante `kind` de un documento del índice: versículo.
  static const int docKindVerse = 0;

  /// Constante `kind` de un documento del índice: libro.
  static const int docKindBook = 1;

  /// Tamaño de un `MetaEntry` del índice semántico en bytes.
  /// uint8 kind + uint32 refId = 5 bytes.
  static const int docMetaEntrySize = 5;

  /// Frecuencia mínima de documento para que un término entre al
  /// vocabulario. Términos que aparecen en menos de N documentos
  /// son descartados (ruido tipográfico y hapax).
  static const int minDocumentFrequency = 2;

  /// Frecuencia máxima de documento (relativa al corpus) para que
  /// un término no se considere stopword. Si un término aparece en
  /// más del N% de los documentos, se descarta.
  static const double maxDocumentFrequencyRatio = 0.5;

  /// Etiquetas semánticas curadas (subset MVP).
  /// Lista cerrada; el lexicon de sinónimos mapea palabras del
  /// usuario a estas etiquetas.
  static const List<String> knownTags = <String>[
    'fear',
    'anxiety',
    'sadness',
    'joy',
    'gratitude',
    'loneliness',
    'anger',
    'hope',
    'faith',
    'repentance',
    'doubt',
    'love',
    'forgiveness',
    'peace',
    'sickness',
    'death',
    'family',
    'work',
    'money',
    'future',
    'past',
    'guidance',
    'protection',
    'wisdom',
    'patience',
    'humility',
    'strength',
    'purpose',
    'identity',
  ];
}
