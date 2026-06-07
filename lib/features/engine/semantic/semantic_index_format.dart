import 'dart:typed_data';

import '../../../core/constants/bible_constants.dart';

/// Especificación del formato binario del índice semántico v1.
///
/// Layout del archivo `semantic_index.bin`:
///
/// ```
/// HEADER (88 bytes, little-endian):
///   uint32  magic            = BibleConstants.semanticIndexMagic
///   uint32  version          = 1
///   uint32  numDocs          (N)
///   uint32  numTerms         (T)
///   uint32  numNonZeros      (Z)
///   uint64  offsetIndptr
///   uint64  offsetIndices
///   uint64  offsetData
///   uint64  offsetVocab
///   uint64  offsetVocabData
///   uint64  offsetMeta
///   uint64  offsetIdf        (float32[numTerms])
///   uint64  offsetDocLengths (float32[numDocs+1], el último es avgDocLength)
///
/// SECTION indptr  : int32[N+1]           (CSR row pointers)
/// SECTION indices : int32[Z]             (termId por no-cero)
/// SECTION data    : float32[Z]           (frecuencia cruda BM25 por no-cero)
/// SECTION vocab   : uint32[T+1]          (offsets a vocabData)
/// SECTION vocabData : bytes              (UTF-8 concatenado)
/// SECTION meta    : byte[5*N]            (kind+refId por doc)
/// SECTION idf     : float32[T]           (IDF BM25 por término)
/// SECTION docLengths : float32[N+1]      (longitud por doc; último = avgDocLength)
///
/// Todas las secciones se alinean a 8 bytes. La cabecera es de
/// tamaño fijo para que un lector random-access pueda mapear la
/// estructura sin parsear el cuerpo.
class SemanticIndexFormat {
  const SemanticIndexFormat._();

  /// Magic + version + 3 uint32 + 8 uint64 = 4+4+12+64 = 84 bytes.
  /// Ajustado a 88 para alineación 8 (padding al final).
  static const int headerSize = 88;

  /// Devuelve el offset alineado a 8 bytes posterior a [offset].
  static int align8(int offset) => (offset + 7) & ~0x7;

  /// Serializa el header a un buffer de bytes.
  static Uint8List encodeHeader({
    required int numDocs,
    required int numTerms,
    required int numNonZeros,
    required int offsetIndptr,
    required int offsetIndices,
    required int offsetData,
    required int offsetVocab,
    required int offsetVocabData,
    required int offsetMeta,
    required int offsetIdf,
    required int offsetDocNorms,
  }) {
    final ByteData bd = ByteData(headerSize);
    int p = 0;
    bd.setUint32(p, BibleConstants.semanticIndexMagic, Endian.little);
    p += 4;
    bd.setUint32(p, BibleConstants.semanticIndexFormatVersion, Endian.little);
    p += 4;
    bd.setUint32(p, numDocs, Endian.little);
    p += 4;
    bd.setUint32(p, numTerms, Endian.little);
    p += 4;
    bd.setUint32(p, numNonZeros, Endian.little);
    p += 4;
    bd.setUint64(p, offsetIndptr, Endian.little);
    p += 8;
    bd.setUint64(p, offsetIndices, Endian.little);
    p += 8;
    bd.setUint64(p, offsetData, Endian.little);
    p += 8;
    bd.setUint64(p, offsetVocab, Endian.little);
    p += 8;
    bd.setUint64(p, offsetVocabData, Endian.little);
    p += 8;
    bd.setUint64(p, offsetMeta, Endian.little);
    p += 8;
    bd.setUint64(p, offsetIdf, Endian.little);
    p += 8;
    bd.setUint64(p, offsetDocNorms, Endian.little);
    p += 8;
    return bd.buffer.asUint8List();
  }

  /// Parsea un header desde un buffer de bytes.
  static SemanticIndexHeader parseHeader(Uint8List bytes) {
    if (bytes.length < headerSize) {
      throw const FormatException(
        'Header del índice semántico demasiado pequeño.',
      );
    }
    final ByteData bd = ByteData.sublistView(bytes);
    int p = 0;
    final int magic = bd.getUint32(p, Endian.little);
    p += 4;
    final int version = bd.getUint32(p, Endian.little);
    p += 4;
    if (magic != BibleConstants.semanticIndexMagic) {
      throw FormatException(
        'Magic inválido: esperado 0x'
        '${BibleConstants.semanticIndexMagic.toRadixString(16)}'
        ', recibido 0x${magic.toRadixString(16)}',
      );
    }
    if (version != BibleConstants.semanticIndexFormatVersion) {
      throw FormatException(
        'Versión no soportada: $version (esperado '
        '${BibleConstants.semanticIndexFormatVersion})',
      );
    }
    final int numDocs = bd.getUint32(p, Endian.little);
    p += 4;
    final int numTerms = bd.getUint32(p, Endian.little);
    p += 4;
    final int numNonZeros = bd.getUint32(p, Endian.little);
    p += 4;
    final int offIndptr = bd.getUint64(p, Endian.little);
    p += 8;
    final int offIndices = bd.getUint64(p, Endian.little);
    p += 8;
    final int offData = bd.getUint64(p, Endian.little);
    p += 8;
    final int offVocab = bd.getUint64(p, Endian.little);
    p += 8;
    final int offVocabData = bd.getUint64(p, Endian.little);
    p += 8;
    final int offMeta = bd.getUint64(p, Endian.little);
    p += 8;
    final int offIdf = bd.getUint64(p, Endian.little);
    p += 8;
    final int offDocNorms = bd.getUint64(p, Endian.little);
    return SemanticIndexHeader(
      numDocs: numDocs,
      numTerms: numTerms,
      numNonZeros: numNonZeros,
      offsetIndptr: offIndptr,
      offsetIndices: offIndices,
      offsetData: offData,
      offsetVocab: offVocab,
      offsetVocabData: offVocabData,
      offsetMeta: offMeta,
      offsetIdf: offIdf,
      offsetDocNorms: offDocNorms,
    );
  }
}

/// Header parseado del índice semántico.
class SemanticIndexHeader {
  const SemanticIndexHeader({
    required this.numDocs,
    required this.numTerms,
    required this.numNonZeros,
    required this.offsetIndptr,
    required this.offsetIndices,
    required this.offsetData,
    required this.offsetVocab,
    required this.offsetVocabData,
    required this.offsetMeta,
    required this.offsetIdf,
    required this.offsetDocNorms,
  });

  final int numDocs;
  final int numTerms;
  final int numNonZeros;
  final int offsetIndptr;
  final int offsetIndices;
  final int offsetData;
  final int offsetVocab;
  final int offsetVocabData;
  final int offsetMeta;
  final int offsetIdf;
  final int offsetDocNorms;
}

/// Tipo de documento del índice semántico.
enum SemanticDocKind {
  /// Versículo: `refId` = `verse.id`.
  verse,

  /// Libro bíblico: `refId` = `verses.bookNumber`.
  book,
}

/// Identifica a qué entidad apunta un documento del índice.
class SemanticDocRef {
  const SemanticDocRef._(this.kind, this.refId);

  factory SemanticDocRef.verse(int verseId) =>
      SemanticDocRef._(SemanticDocKind.verse, verseId);
  factory SemanticDocRef.book(int bookNumber) =>
      SemanticDocRef._(SemanticDocKind.book, bookNumber);

  final SemanticDocKind kind;
  final int refId;

  @override
  String toString() => 'SemanticDocRef(${kind.name}, $refId)';
}
