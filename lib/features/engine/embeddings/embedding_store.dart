import 'dart:math' as math;
import 'dart:typed_data';

import '../semantic/semantic_index.dart' show IndexByteStore;

/// Store de embeddings densos (float32) con acceso random-access.
///
/// Layout del archivo `verse_embeddings.bin` (v1):
///
/// ```
/// HEADER (16 bytes, little-endian):
///   uint32 magic          = 0x5645424D ('MBEV' = "MEB Vectors")
///   uint32 version        = 1
///   uint32 vocabSize      (V)
///   uint32 dim            (D)
///
/// SECTION vocab : uint32[V+1]            (offsets UTF-8 a vocabData)
/// SECTION vocabData : bytes              (UTF-8 concatenado)
/// SECTION vectors : float32[V * D]       (vector por palabra)
/// SECTION docNorms : float32[N_docs]     (norma L2 por versículo, opcional)
/// SECTION docVectors : float32[N_docs * D]  (vector agregado por versículo)
/// ```
class EmbeddingStore {
  EmbeddingStore._({
    required this.vocabSize,
    required this.dim,
    required Uint32List vocabOffsets,
    required Uint8List vocabData,
    required Float32List vectors,
    Float32List? docNorms,
    Float32List? docVectors,
    this.numDocs = 0,
  })  : _vocabOffsets = vocabOffsets,
        _vocabData = vocabData,
        _vectors = vectors,
        _docNorms = docNorms,
        _docVectors = docVectors;

  final int vocabSize;
  final int dim;
  final int numDocs;
  final Uint32List _vocabOffsets;
  final Uint8List _vocabData;
  final Float32List _vectors;
  final Float32List? _docNorms;
  final Float32List? _docVectors;

  /// Magic del archivo de embeddings (4 bytes ASCII: 'V','E','M','B').
  static const int magic = 0x424D4556;

  /// Versión del formato.
  static const int version = 1;

  /// Tamaño del header (4 + 4 + 4 + 4 = 16 bytes).
  static const int headerSize = 16;

  /// Carga el store desde un [store] de bytes random-access.
  factory EmbeddingStore.open(IndexByteStore store) {
    final Uint8List headerBytes = store.read(0, headerSize);
    final ByteData hd = ByteData.sublistView(headerBytes);
    int p = 0;
    final int m = hd.getUint32(p, Endian.little);
    p += 4;
    final int v = hd.getUint32(p, Endian.little);
    p += 4;
    if (m != magic) {
      throw FormatException(
        'Magic inválido: 0x${m.toRadixString(16)}',
      );
    }
    if (v != version) {
      throw FormatException('Versión inválida: $v');
    }
    final int vocabSize = hd.getUint32(p, Endian.little);
    p += 4;
    final int dim = hd.getUint32(p, Endian.little);
    p += 4;
    // vocab section
    final int vocabStart = headerSize;
    final Uint8List vocabBytes =
        store.read(vocabStart, (vocabSize + 1) * 4);
    final Uint32List vocabOffsets = Uint32List.sublistView(vocabBytes);
    // vocabData length: stored as the first uint32 of vocabBytes
    // reinterpreted as vocabOffsets[vocabSize]. Since vocabOffsets
    // is V+1 entries, vocabOffsets[V] = total vocabData length.
    final int vocabDataLen = vocabOffsets[vocabSize];
    final int vocabDataStart = vocabStart + (vocabSize + 1) * 4;
    final Uint8List vocabData =
        store.read(vocabDataStart, vocabDataLen);
    // vectors
    final int vectorsStart = vocabDataStart + vocabDataLen;
    final Uint8List vectorsBytes =
        store.read(vectorsStart, vocabSize * dim * 4);
    final Float32List vectors = Float32List.sublistView(vectorsBytes);
    return EmbeddingStore._(
      vocabSize: vocabSize,
      dim: dim,
      vocabOffsets: vocabOffsets,
      vocabData: vocabData,
      vectors: vectors,
    );
  }

  /// Construye el store en memoria (uso principal: tests y CLI).
  factory EmbeddingStore.fromMemory({
    required List<String> vocab,
    required List<List<double>> vectors,
    List<List<double>>? docVectors,
  }) {
    if (vectors.length != vocab.length) {
      throw ArgumentError('vectors.length != vocab.length');
    }
    final int V = vocab.length;
    final int D = vectors.isEmpty ? 0 : vectors.first.length;

    final List<int> offsets = <int>[];
    final BytesBuilder bb = BytesBuilder();
    for (final String w in vocab) {
      offsets.add(bb.length);
      bb.add(_utf8Encode(w));
    }
    offsets.add(bb.length);
    final Uint8List vocabData = bb.toBytes();
    final Uint32List vocabOffsets = Uint32List.fromList(offsets);

    final Float32List flat = Float32List(V * D);
    for (int i = 0; i < V; i++) {
      for (int j = 0; j < D; j++) {
        flat[i * D + j] = vectors[i][j];
      }
    }

    Float32List? docNorms;
    Float32List? docVecs;
    int numDocs = 0;
    if (docVectors != null) {
      numDocs = docVectors.length;
      docVecs = Float32List(numDocs * D);
      docNorms = Float32List(numDocs);
      for (int i = 0; i < numDocs; i++) {
        double normSq = 0.0;
        for (int j = 0; j < D; j++) {
          final double x = docVectors[i][j];
          docVecs[i * D + j] = x;
          normSq += x * x;
        }
        docNorms[i] = normSq <= 0 ? 0.0 : math.sqrt(normSq);
      }
    }

    return EmbeddingStore._(
      vocabSize: V,
      dim: D,
      vocabOffsets: vocabOffsets,
      vocabData: vocabData,
      vectors: flat,
      docNorms: docNorms,
      docVectors: docVecs,
      numDocs: numDocs,
    );
  }

  /// Vocabulario del modelo.
  List<String> get vocabulary {
    final List<String> out =
        List<String>.filled(vocabSize, '', growable: false);
    for (int i = 0; i < vocabSize; i++) {
      out[i] = _termAt(i);
    }
    return out;
  }

  /// Mapa término → ID (lazy).
  Map<String, int> get wordIdMap {
    final Map<String, int> m = <String, int>{};
    for (int i = 0; i < vocabSize; i++) {
      m[_termAt(i)] = i;
    }
    return m;
  }

  String _termAt(int id) {
    final int start = _vocabOffsets[id];
    final int end = _vocabOffsets[id + 1];
    return _utf8Decode(
      Uint8List.sublistView(_vocabData, start, end),
    );
  }

  /// Vector de la palabra [word] (vista como `Float32List`).
  /// Devuelve null si la palabra no está en el vocab.
  Float32List? vectorOfWord(String word) {
    final Map<String, int> m = wordIdMap;
    final int? id = m[word];
    if (id == null) return null;
    return Float32List.sublistView(
      _vectors,
      id * dim,
      (id + 1) * dim,
    );
  }

  /// Vector promedio de un documento (lista de palabras).
  /// Para OOV devuelve vector de ceros.
  Float32List vectorOfDoc(List<String> words) {
    final Float32List acc = Float32List(dim);
    int count = 0;
    final Map<String, int> m = wordIdMap;
    for (final String w in words) {
      final int? id = m[w];
      if (id == null) continue;
      final int base = id * dim;
      for (int j = 0; j < dim; j++) {
        acc[j] += _vectors[base + j];
      }
      count++;
    }
    if (count == 0) return acc;
    for (int j = 0; j < dim; j++) {
      acc[j] /= count;
    }
    return acc;
  }

  /// Cosine similarity entre dos vectores densos.
  double cosine(Float32List a, Float32List b) {
    if (a.length != b.length) {
      throw ArgumentError('length mismatch: ${a.length} vs ${b.length}');
    }
    double dot = 0.0;
    double na = 0.0;
    double nb = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na <= 0 || nb <= 0) return 0.0;
    return dot / (math.sqrt(na) * math.sqrt(nb));
  }

  /// Vector denso de un versículo pre-agregado (si está disponible).
  Float32List? docVector(int docIndex) {
    if (_docVectors == null) return null;
    if (docIndex < 0 || docIndex >= numDocs) return null;
    return Float32List.sublistView(
      _docVectors,
      docIndex * dim,
      (docIndex + 1) * dim,
    );
  }

  /// Cosine similarity entre un versículo pre-agregado y un
  /// vector query.
  double docCosine(int docIndex, Float32List q) {
    final Float32List? dv = docVector(docIndex);
    if (dv == null) return 0.0;
    return cosine(dv, q);
  }

  /// Serializa el store a bytes para persistir en `assets/`.
  Uint8List toBytes() {
    final int vocabSectionLen = (vocabSize + 1) * 4;
    final int vocabDataLen = _vocabData.length;
    final int vectorsLen = vocabSize * dim * 4;
    final int docSectionLen = (numDocs > 0) ? (numDocs * 4 + numDocs * dim * 4) : 0;
    final int totalLen = headerSize + vocabSectionLen + vocabDataLen + vectorsLen + docSectionLen;
    final ByteData out = ByteData(totalLen);
    int p = 0;
    out.setUint32(p, magic, Endian.little);
    p += 4;
    out.setUint32(p, version, Endian.little);
    p += 4;
    out.setUint32(p, vocabSize, Endian.little);
    p += 4;
    out.setUint32(p, dim, Endian.little);
    p += 4;
    // Vocab offsets.
    for (int i = 0; i <= vocabSize; i++) {
      out.setUint32(p, _vocabOffsets[i], Endian.little);
      p += 4;
    }
    // Vocab data.
    for (int i = 0; i < vocabDataLen; i++) {
      out.setUint8(p, _vocabData[i]);
      p++;
    }
    // Vectors.
    for (int i = 0; i < _vectors.length; i++) {
      out.setFloat32(p, _vectors[i], Endian.little);
      p += 4;
    }
    // Doc norms + doc vectors.
    final Float32List? docNormsLocal = _docNorms;
    final Float32List? docVectorsLocal = _docVectors;
    if (docNormsLocal != null && docVectorsLocal != null) {
      for (int i = 0; i < numDocs; i++) {
        out.setFloat32(p, docNormsLocal[i], Endian.little);
        p += 4;
      }
      for (int i = 0; i < docVectorsLocal.length; i++) {
        out.setFloat32(p, docVectorsLocal[i], Endian.little);
        p += 4;
      }
    }
    return out.buffer.asUint8List();
  }
}

/// Interfaz mínima (compatible con `semantic_index.dart`).

List<int> _utf8Encode(String s) {
  final List<int> out = <int>[];
  for (int i = 0; i < s.length; i++) {
    final int cu = s.codeUnitAt(i);
    if (cu < 0x80) {
      out.add(cu);
    } else if (cu < 0x800) {
      out.add(0xC0 | (cu >> 6));
      out.add(0x80 | (cu & 0x3F));
    } else if (cu < 0x10000) {
      out.add(0xE0 | (cu >> 12));
      out.add(0x80 | ((cu >> 6) & 0x3F));
      out.add(0x80 | (cu & 0x3F));
    } else {
      out.add(0xF0 | (cu >> 18));
      out.add(0x80 | ((cu >> 12) & 0x3F));
      out.add(0x80 | ((cu >> 6) & 0x3F));
      out.add(0x80 | (cu & 0x3F));
    }
  }
  return out;
}

String _utf8Decode(List<int> bytes) {
  final StringBuffer sb = StringBuffer();
  int i = 0;
  while (i < bytes.length) {
    final int b = bytes[i] & 0xFF;
    int cp;
    int extra;
    if (b < 0x80) {
      cp = b;
      extra = 0;
    } else if ((b & 0xE0) == 0xC0) {
      cp = b & 0x1F;
      extra = 1;
    } else if ((b & 0xF0) == 0xE0) {
      cp = b & 0x0F;
      extra = 2;
    } else {
      cp = b & 0x07;
      extra = 3;
    }
    i++;
    for (int k = 0; k < extra; k++) {
      if (i >= bytes.length) return sb.toString();
      cp = (cp << 6) | (bytes[i] & 0x3F);
      i++;
    }
    sb.writeCharCode(cp);
  }
  return sb.toString();
}
