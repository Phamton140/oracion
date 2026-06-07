import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'semantic_index_format.dart';

/// Resultado de una consulta semántica: top-K documentos ordenados
/// por similitud coseno descendente.
class SemanticSearchHit {
  const SemanticSearchHit({
    required this.docId,
    required this.ref,
    required this.score,
  });

  /// ID interno del documento en el índice (0..numDocs-1).
  final int docId;

  /// Referencia al versículo o libro.
  final SemanticDocRef ref;

  /// Score (cosine para embeddings, BM25 para retrieval).
  final double score;
}

/// Interfaz mínima para un store de bytes random-access.
///
/// En producción, un `RandomAccessFile` de `dart:io` envuelve
/// lectura bajo demanda desde disco (estilo mmap). En tests,
/// un `MemoryIndexStore` envuelve un `Uint8List`.
abstract class IndexByteStore {
  Uint8List read(int offset, int length);
  int get length;
}

/// Store backed por un buffer en memoria (usado en tests).
class MemoryIndexStore implements IndexByteStore {
  MemoryIndexStore(this._bytes);
  final Uint8List _bytes;

  @override
  Uint8List read(int offset, int length) {
    if (offset < 0 || length < 0 || offset + length > _bytes.length) {
      throw RangeError('read fuera de rango: '
          'offset=$offset length=$length storeSize=${_bytes.length}');
    }
    return Uint8List.sublistView(_bytes, offset, offset + length);
  }

  @override
  int get length => _bytes.length;
}

/// Store backed por un archivo de disco (lectura bajo demanda).
///
/// Usa `dart:io` `RandomAccessFile`; se importa perezosamente
/// para mantener este header libre de dependencias de I/O.
class FileIndexStore implements IndexByteStore {
  // RandomAccessFile de dart:io; tipo dynamic para no acoplar
  // este header con dart:io. La longitud se obtiene al construir.
  FileIndexStore(dynamic file)
      // ignore: avoid_dynamic_calls
      : _file = file,
        // ignore: avoid_dynamic_calls
        _length = file.lengthSync() as int;

  // ignore: avoid_dynamic_calls
  final dynamic _file;
  final int _length;

  @override
  Uint8List read(int offset, int length) {
    if (offset < 0 || length < 0 || offset + length > _length) {
      throw RangeError('read fuera de rango: '
          'offset=$offset length=$length storeSize=$_length');
    }
    // ignore: avoid_dynamic_calls
    return _file.readSync(offset, length) as Uint8List;
  }

  @override
  int get length => _length;
}

/// Índice semántico cargado vía vistas zero-copy sobre un
/// [IndexByteStore].
///
/// Almacena:
///   - `indptr` : CSR row pointers
///   - `indices`: termId por no-cero
///   - `data`   : frecuencia cruda por no-cero (BM25 calcula el
///                score en query time con IDF precomputado)
///   - `idf`    : IDF BM25 por término
///   - `meta`   : kind + refId por doc
///   - `docLengths`: longitud (en tokens) de cada doc para BM25
///   - `avgDocLength`: longitud media (un solo float, repetido)
class SemanticIndex {
  SemanticIndex._({
    required this.header,
    required Int32List indptr,
    required Int32List indices,
    required Float32List data,
    required Uint32List vocab,
    required Uint8List vocabData,
    required Uint8List meta,
    required Float32List idf,
    required Float32List docLengths,
    required this.avgDocLength,
  })  : _indptr = indptr,
        _indices = indices,
        _data = data,
        _vocab = vocab,
        _vocabData = vocabData,
        _meta = meta,
        _idf = idf,
        _docLengths = docLengths;

  final SemanticIndexHeader header;

  final Int32List _indptr;
  final Int32List _indices;
  final Float32List _data;
  final Uint32List _vocab;
  final Uint8List _vocabData;
  final Uint8List _meta;
  final Float32List _idf;
  final Float32List _docLengths;
  final double avgDocLength;

  /// Carga el índice desde un [store] de bytes random-access.
  factory SemanticIndex.open(IndexByteStore store) {
    final Uint8List headerBytes = store.read(0, SemanticIndexFormat.headerSize);
    final SemanticIndexHeader h = SemanticIndexFormat.parseHeader(headerBytes);

    final Uint8List indptrBytes =
        store.read(h.offsetIndptr, (h.numDocs + 1) * 4);
    final Uint8List indicesBytes =
        store.read(h.offsetIndices, h.numNonZeros * 4);
    final Uint8List dataBytes =
        store.read(h.offsetData, h.numNonZeros * 4);
    final Uint8List vocabBytes =
        store.read(h.offsetVocab, (h.numTerms + 1) * 4);
    final int vocabDataLen = (h.offsetIdf - h.offsetVocabData).toInt();
    final Uint8List vocabData = store.read(h.offsetVocabData, vocabDataLen);
    final Uint8List meta = store.read(h.offsetMeta, h.numDocs * 5);
    final Uint8List idfBytes = store.read(h.offsetIdf, h.numTerms * 4);
    final Uint8List docLenBytes =
        store.read(h.offsetDocNorms, h.numDocs * 4);

    // El último float de docLengths es avgDocLength (hack de
    // layout para no añadir otra sección).
    final Float32List docLens =
        Float32List.sublistView(docLenBytes);

    return SemanticIndex._(
      header: h,
      indptr: Int32List.sublistView(indptrBytes),
      indices: Int32List.sublistView(indicesBytes),
      data: Float32List.sublistView(dataBytes),
      vocab: Uint32List.sublistView(vocabBytes),
      vocabData: vocabData,
      meta: meta,
      idf: Float32List.sublistView(idfBytes),
      docLengths: Float32List.sublistView(docLenBytes),
      avgDocLength: docLens.isEmpty ? 0.0 : docLens[docLens.length - 1],
    );
  }

  /// Construye un índice en memoria a partir de un corpus ya
  /// vectorizado (uso principal: tests y CLI de build).
  factory SemanticIndex.fromCorpus(Bm25CorpusData data) {
    final int N = data.documents.length;
    final int T = data.vocabulary.length;

    final List<int> indptr = <int>[0];
    final List<int> indices = <int>[];
    final List<double> values = <double>[];
    final List<double> docLengths = <double>[];

    for (int d = 0; d < N; d++) {
      final List<int> docTerms = data.documents[d];
      final List<double> docWeights = data.docWeightsPerDoc[d];
      double totalLen = 0.0;
      for (int i = 0; i < docTerms.length; i++) {
        indices.add(docTerms[i]);
        final double w = docWeights[i];
        values.add(w);
        totalLen += w;
      }
      docLengths.add(totalLen);
      indptr.add(indices.length);
    }

    final int Z = indices.length;
    final Int32List indptrList = Int32List.fromList(indptr);
    final Int32List indicesList = Int32List.fromList(indices);
    final Float32List dataList = Float32List.fromList(values);
    final Float32List idfList = Float32List.fromList(data.idf);
    final Float32List docLengthsList = Float32List.fromList(docLengths);

    // Vocabulario: vocab[T+1] = offsets dentro de vocabData.
    final List<int> vocabOffsets = <int>[];
    final BytesBuilder bb = BytesBuilder();
    for (final String t in data.vocabulary) {
      vocabOffsets.add(bb.length);
      bb.add(utf8.encode(t));
    }
    vocabOffsets.add(bb.length);
    final Uint8List vocabData = bb.toBytes();
    final Uint32List vocabList = Uint32List.fromList(vocabOffsets);

    // Meta: por cada doc, 1 byte kind + 4 bytes refId.
    final ByteData metaBd = ByteData(N * 5);
    for (int i = 0; i < N; i++) {
      metaBd.setUint8(i * 5, data.docKinds[i]);
      metaBd.setUint32(i * 5 + 1, data.docRefIds[i], Endian.little);
    }
    final Uint8List meta = metaBd.buffer.asUint8List();

    return SemanticIndex._(
      header: SemanticIndexHeader(
        numDocs: N,
        numTerms: T,
        numNonZeros: Z,
        offsetIndptr: 0,
        offsetIndices: 0,
        offsetData: 0,
        offsetVocab: 0,
        offsetVocabData: 0,
        offsetMeta: 0,
        offsetIdf: 0,
        offsetDocNorms: 0,
      ),
      indptr: indptrList,
      indices: indicesList,
      data: dataList,
      vocab: vocabList,
      vocabData: vocabData,
      meta: meta,
      idf: idfList,
      docLengths: docLengthsList,
      avgDocLength: data.avgDocLength,
    );
  }

  /// Número de documentos en el índice.
  int get numDocs => header.numDocs;

  /// Número de términos en el vocabulario.
  int get numTerms => header.numTerms;

  /// Total de no-ceros en el índice.
  int get numNonZeros => header.numNonZeros;

  /// Vista zero-copy al `indptr` (CSR row pointers).
  Int32List get indptrView => _indptr;

  /// Vista zero-copy al array de índices de término.
  Int32List get indicesView => _indices;

  /// Vista zero-copy al array de frecuencias crudas.
  Float32List get dataView => _data;

  /// Vista zero-copy a la longitud de cada documento.
  Float32List get docLengthsView => _docLengths;

  /// Vista zero-copy al IDF por término.
  Float32List get idfView => _idf;

  /// Devuelve el vocabulario completo.
  List<String> get vocabulary {
    final List<String> out =
        List<String>.filled(numTerms, '', growable: false);
    for (int i = 0; i < numTerms; i++) {
      out[i] = _termAt(i);
    }
    return out;
  }

  /// Devuelve el IDF (float32) por término.
  List<double> get idfList {
    final List<double> out =
        List<double>.filled(numTerms, 0.0, growable: false);
    for (int i = 0; i < numTerms; i++) {
      out[i] = _idf[i];
    }
    return out;
  }

  String _termAt(int termId) {
    final int start = _vocab[termId];
    final int end = _vocab[termId + 1];
    return utf8.decode(
      Uint8List.sublistView(_vocabData, start, end),
      allowMalformed: true,
    );
  }

  /// Devuelve la referencia (kind + refId) del documento [docId].
  SemanticDocRef refOf(int docId) {
    if (docId < 0 || docId >= numDocs) {
      throw RangeError('docId fuera de rango: $docId');
    }
    final int offset = docId * 5;
    final ByteData bd = ByteData.sublistView(_meta, offset, offset + 5);
    final int kind = bd.getUint8(0);
    final int refId = bd.getUint32(1, Endian.little);
    if (kind == 0) return SemanticDocRef.verse(refId);
    return SemanticDocRef.book(refId);
  }

  /// Calcula el score BM25 de un documento para la query.
  double bm25Score({
    required int docId,
    required List<int> queryTerms,
    required double k1,
    required double b,
  }) {
    if (queryTerms.isEmpty) return 0.0;
    final int start = _indptr[docId];
    final int end = _indptr[docId + 1];
    if (start == end) return 0.0;
    final double dl = _docLengths[docId];
    final double avgdl = avgDocLength <= 0 ? 1.0 : avgDocLength;

    double score = 0.0;
    int i = 0;
    int j = start;
    while (i < queryTerms.length && j < end) {
      final int qt = queryTerms[i];
      final int dt = _indices[j];
      if (qt < dt) {
        i++;
      } else if (qt > dt) {
        j++;
      } else {
        final double f = _data[j];
        final double numerator = f * (k1 + 1);
        final double denominator = f + k1 * (1 - b + b * dl / avgdl);
        score += _idf[qt] * (numerator / denominator);
        i++;
        j++;
      }
    }
    return score;
  }

  /// Busca los [topK] documentos con mayor score BM25.
  List<SemanticSearchHit> bm25Search({
    required List<int> queryTerms,
    int topK = 50,
    Set<int>? excludeDocIds,
    double k1 = 1.5,
    double b = 0.75,
  }) {
    if (queryTerms.isEmpty || topK <= 0) return const <SemanticSearchHit>[];

    final List<_HeapEntry> heap = <_HeapEntry>[];
    for (int d = 0; d < numDocs; d++) {
      if (excludeDocIds != null && excludeDocIds.contains(d)) continue;
      final double score = bm25Score(
        docId: d,
        queryTerms: queryTerms,
        k1: k1,
        b: b,
      );
      if (score <= 0) continue;
      if (heap.length < topK) {
        _heapPush(heap, _HeapEntry(d, score));
      } else if (score > heap.first.score) {
        _heapReplaceRoot(heap, _HeapEntry(d, score));
      }
    }

    heap.sort((_HeapEntry a, _HeapEntry b) => b.score.compareTo(a.score));
    return heap
        .map((_HeapEntry e) => SemanticSearchHit(
              docId: e.docId,
              ref: refOf(e.docId),
              score: e.score,
            ))
        .toList(growable: false);
  }
}

class _HeapEntry {
  const _HeapEntry(this.docId, this.score);
  final int docId;
  final double score;
}

void _heapPush(List<_HeapEntry> heap, _HeapEntry e) {
  heap.add(e);
  int i = heap.length - 1;
  while (i > 0) {
    final int p = (i - 1) >> 1;
    if (heap[p].score <= heap[i].score) break;
    final _HeapEntry tmp = heap[p];
    heap[p] = heap[i];
    heap[i] = tmp;
    i = p;
  }
}

void _heapReplaceRoot(List<_HeapEntry> heap, _HeapEntry e) {
  heap[0] = e;
  int i = 0;
  final int n = heap.length;
  while (true) {
    final int l = 2 * i + 1;
    final int r = 2 * i + 2;
    int smallest = i;
    if (l < n && heap[l].score < heap[smallest].score) smallest = l;
    if (r < n && heap[r].score < heap[smallest].score) smallest = r;
    if (smallest == i) break;
    final _HeapEntry tmp = heap[smallest];
    heap[smallest] = heap[i];
    heap[i] = tmp;
    i = smallest;
  }
}

/// Estructura temporal para construir un [SemanticIndex] en memoria.
class Bm25CorpusData {
  Bm25CorpusData({
    required this.vocabulary,
    required this.idf,
    required this.docKinds,
    required this.docRefIds,
    required this.documents,
    required this.docWeightsPerDoc,
    required this.avgDocLength,
  });

  final List<String> vocabulary;
  final List<double> idf;
  final List<int> docKinds;
  final List<int> docRefIds;
  final List<List<int>> documents;
  final List<List<double>> docWeightsPerDoc;
  final double avgDocLength;
}
