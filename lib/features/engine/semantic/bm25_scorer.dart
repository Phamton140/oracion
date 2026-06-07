import 'dart:math' as math;

/// Vector de pesos dispersos (formato COO) asociado a un documento.
///
/// Lista compacta de `(termId, weight)`. Los pesos ya están
/// normalizados con la fórmula BM25.
class SparseVector {
  const SparseVector(this.terms, this.weights);

  final List<int> terms;
  final List<double> weights;

  int get length => terms.length;
  bool get isEmpty => terms.isEmpty;

  /// Norma L2 del vector (raíz de la suma de cuadrados).
  double l2Norm() {
    if (weights.isEmpty) return 0.0;
    double s = 0.0;
    for (final double w in weights) {
      s += w * w;
    }
    return s <= 0 ? 0.0 : math.sqrt(s);
  }
}

/// Resultado de indexar un corpus completo con BM25.
class Bm25Corpus {
  const Bm25Corpus({
    required this.vocabulary,
    required this.idf,
    required this.avgDocLength,
    required this.documents,
  });

  /// Lista ordenada de términos (ID de columna = posición).
  final List<String> vocabulary;

  /// `idf[termId]` = inverse document frequency del término.
  final List<double> idf;

  /// Longitud media de documento (en tokens), necesaria para BM25.
  final double avgDocLength;

  /// Vector disperso por documento con frecuencias crudas
  /// (BM25 calcula el score en query time, no precomputa pesos).
  final List<SparseVector> documents;
}

/// Scorer BM25 (Best Matching 25) para construir el índice de
/// recuperación.
///
/// Fórmula (Robertson–Spärck Jones–BM25):
///   idf(t)   = log(1 + (N - df(t) + 0.5) / (df(t) + 0.5))
///   bm25(t, d)
///           = idf(t) * (f(t,d) * (k1 + 1))
///             / (f(t,d) + k1 * (1 - b + b * |d|/avgdl))
///
/// donde:
///   N        = número total de documentos
///   df(t)    = documentos que contienen el término t
///   f(t,d)   = frecuencia del término t en el documento d
///   |d|      = longitud del documento d (en tokens)
///   avgdl    = longitud media de documento en el corpus
///   k1, b    = hiperparámetros (clásicos: 1.5 y 0.75)
///
/// BM25 es estrictamente mejor que TF-IDF para queries cortas
/// porque normaliza por longitud de documento. En el formato
/// binario, los IDFs se precomputan; las frecuencias crudas se
/// almacenan en la sección `data` y el score se calcula en
/// query time (es la forma estándar, rápida y compacta).
class Bm25Scorer {
  const Bm25Scorer({
    this.k1 = 1.5,
    this.b = 0.75,
  });

  final double k1;
  final double b;

  /// Construye el vocabulario, IDFs y longitudes de documento a
  /// partir de la lista de documentos tokenizados.
  ///
  /// [minDf] descarta términos con df menor.
  /// [maxDfRatio] descarta términos con df/N mayor (stopwords).
  Bm25Corpus fit({
    required List<List<String>> tokenizedDocs,
    int minDf = 2,
    double maxDfRatio = 0.5,
  }) {
    final int N = tokenizedDocs.length;
    if (N == 0) {
      return const Bm25Corpus(
        vocabulary: <String>[],
        idf: <double>[],
        avgDocLength: 0.0,
        documents: <SparseVector>[],
      );
    }

    // 1) df por término.
    final Map<String, int> df = <String, int>{};
    for (final List<String> doc in tokenizedDocs) {
      final Set<String> unique = doc.toSet();
      for (final String t in unique) {
        df[t] = (df[t] ?? 0) + 1;
      }
    }

    // 2) Filtrar vocabulario.
    final int maxDf = (N * maxDfRatio).floor();
    final List<String> vocab = <String>[];
    final Map<String, int> termId = <String, int>{};
    df.forEach((String t, int c) {
      if (c >= minDf && c <= maxDf) {
        termId[t] = vocab.length;
        vocab.add(t);
      }
    });

    // 3) IDF BM25.
    final List<double> idf = List<double>.filled(vocab.length, 0.0);
    for (int i = 0; i < vocab.length; i++) {
      final int c = df[vocab[i]]!;
      idf[i] = math.log(1 + (N - c + 0.5) / (c + 0.5));
    }

    // 4) Longitudes y frecuencias crudas por documento.
    int totalLen = 0;
    final List<SparseVector> docs = <SparseVector>[];
    for (final List<String> tokens in tokenizedDocs) {
      totalLen += tokens.length;
      final Map<int, int> counts = <int, int>{};
      for (final String t in tokens) {
        final int? id = termId[t];
        if (id == null) continue;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      if (counts.isEmpty) {
        docs.add(const SparseVector(<int>[], <double>[]));
        continue;
      }
      final List<MapEntry<int, int>> entries = counts.entries.toList()
        ..sort((MapEntry<int, int> a, MapEntry<int, int> b) =>
            a.key.compareTo(b.key));
      final List<int> terms = <int>[];
      final List<double> freqs = <double>[];
      for (final MapEntry<int, int> e in entries) {
        terms.add(e.key);
        freqs.add(e.value.toDouble());
      }
      docs.add(SparseVector(terms, freqs));
    }
    final double avgDocLength = N == 0 ? 0.0 : totalLen / N;

    return Bm25Corpus(
      vocabulary: vocab,
      idf: idf,
      avgDocLength: avgDocLength,
      documents: docs,
    );
  }

  /// Calcula el score BM25 de un documento [docIndex] del corpus
  /// para la query dispersa ([queryTerms], [queryFreqs]).
  double scoreDoc({
    required int docIndex,
    required List<int> queryTerms,
    required List<double> queryFreqs,
    required Bm25Corpus corpus,
  }) {
    if (queryTerms.isEmpty) return 0.0;
    final SparseVector doc = corpus.documents[docIndex];
    if (doc.terms.isEmpty) return 0.0;
    final double dl = doc.terms.isEmpty
        ? 0.0
        : doc.weights.fold<double>(0.0, (double a, double b) => a + b);
    // Nota: en BM25, "doc length" se mide en tokens. Como
    // almacenamos frecuencias, las sumamos como proxy.
    final double avgdl = corpus.avgDocLength <= 0 ? 1.0 : corpus.avgDocLength;
    if (avgdl <= 0) return 0.0;

    double score = 0.0;
    int i = 0;
    int j = 0;
    while (i < queryTerms.length && j < doc.terms.length) {
      final int qt = queryTerms[i];
      final int dt = doc.terms[j];
      if (qt < dt) {
        i++;
      } else if (qt > dt) {
        j++;
      } else {
        final double f = doc.weights[j];
        final double numerator = f * (k1 + 1);
        final double denominator = f + k1 * (1 - b + b * dl / avgdl);
        score += corpus.idf[qt] * (numerator / denominator);
        i++;
        j++;
      }
    }
    return score;
  }

  /// Vectoriza una query con el vocabulario e IDF del corpus.
  /// Devuelve términos/frecuencias dispersos listos para `scoreDoc`.
  SparseVector vectorizeQuery({
    required List<String> tokens,
    required Bm25Corpus corpus,
  }) {
    if (tokens.isEmpty) return const SparseVector(<int>[], <double>[]);
    final Map<String, int> termId = <String, int>{};
    for (int i = 0; i < corpus.vocabulary.length; i++) {
      termId[corpus.vocabulary[i]] = i;
    }
    final Map<int, int> counts = <int, int>{};
    for (final String t in tokens) {
      final int? id = termId[t];
      if (id == null) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SparseVector(<int>[], <double>[]);
    final List<MapEntry<int, int>> entries = counts.entries.toList()
      ..sort((MapEntry<int, int> a, MapEntry<int, int> b) =>
          a.key.compareTo(b.key));
    final List<int> terms = <int>[];
    final List<double> freqs = <double>[];
    for (final MapEntry<int, int> e in entries) {
      terms.add(e.key);
      freqs.add(e.value.toDouble());
    }
    return SparseVector(terms, freqs);
  }
}
