/// Constantes relacionadas con la Biblia y el motor bíblico.
class BibleConstants {
  const BibleConstants._();

  /// Número de libros en la Biblia completa.
  static const int totalBooks = 66;

  /// Número aproximado de versículos en RV1909.
  /// (Valor real: 31.102. Se mantiene como constante para uso
  /// en layouts y benchmarks sin necesidad de consultar la DB.)
  static const int approximateVerseCount = 31102;

  /// Dimensión de los embeddings semánticos.
  /// Coincide con paraphrase-multilingual-MiniLM-L12-v2.
  static const int embeddingDimension = 384;

  /// Tamaño del Top-K inicial en el Bible Engine.
  /// Se recuperan K candidatos antes del re-ranking final.
  static const int topKCandidates = 50;

  /// Tamaño de la lista negra de versículos por conversación.
  /// Limita la longitud de `ConversationContext.shownVerseIdsJson`.
  static const int conversationShownVerseLimit = 20;

  /// Magic header del archivo `embeddings.bin`.
  /// 4 bytes: 'O','R','E','M'.
  static const int embeddingsMagic = 0x4D45524F;

  /// Versión del formato del archivo `embeddings.bin`.
  static const int embeddingsFormatVersion = 1;

  /// Decisión arquitectónica: en Sprint 4 los embeddings se cargarán
  /// vía `mmap` o una estrategia equivalente para facilitar
  /// escalabilidad futura. En Sprint 1 esta es solo documentación;
  /// la implementación concreta llegará cuando se construya el
  /// `SemanticSearchService`.
  static const String embeddingsLoadingStrategy =
      'mmap o equivalente (decidido para Sprint 4)';

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
