import 'dart:math' as math;

/// Entrenador de embeddings subword (estilo fastText) para
/// corpus bíblico.
///
/// Algoritmo: skip-gram con negative sampling, donde cada palabra
/// se representa como la suma de sus n-gramas de caracteres. Esto
/// resuelve el problema OOV (palabras no vistas en entrenamiento)
/// y captura morfología: "debo" / "deuda" / "deudor" comparten
/// subwords y por tanto tienen vectores cercanos.
///
/// Salida: vectores densos `float32[vocabSize × dim]` que se
/// persisten en `assets/data/verse_embeddings.bin`.
///
/// NOTA: este trainer corre en `tool/build_semantic_index.dart`
/// (build-time). NO se ejecuta en runtime de la app.
class Word2VecTrainer {
  Word2VecTrainer({
    this.dim = 100,
    this.window = 5,
    this.minCount = 5,
    this.negativeSamples = 5,
    this.epochs = 3,
    this.subwordMin = 3,
    this.subwordMax = 6,
    this.learningRate = 0.05,
    this.seed = 42,
  });

  final int dim;
  final int window;
  final int minCount;
  final int negativeSamples;
  final int epochs;
  final int subwordMin;
  final int subwordMax;
  final double learningRate;
  final int seed;

  /// Entrena el modelo y devuelve un [WordEmbedding] listo para
  /// persistir.
  WordEmbedding train(List<List<String>> tokenizedDocs) {
    final math.Random rng = math.Random(seed);

    // 1) Vocabulario principal (palabras enteras) por frecuencia.
    final Map<String, int> wordCounts = <String, int>{};
    for (final List<String> doc in tokenizedDocs) {
      for (final String w in doc) {
        wordCounts[w] = (wordCounts[w] ?? 0) + 1;
      }
    }
    final List<String> vocab = <String>[
      for (final MapEntry<String, int> e in wordCounts.entries)
        if (e.value >= minCount) e.key,
    ]..sort();
    final Map<String, int> wordId = <String, int>{
      for (int i = 0; i < vocab.length; i++) vocab[i]: i,
    };
    final int V = vocab.length;

    // 2) Vocabulario de subwords + bucket hashing.
    final Map<String, int> subwordCounts = <String, int>{};
    for (final String w in vocab) {
      for (final String sw in _subwords(w)) {
        subwordCounts[sw] = (subwordCounts[sw] ?? 0) + 1;
      }
    }
    final List<String> subwords = subwordCounts.keys.toList()..sort();
    final Map<String, int> subwordId = <String, int>{
      for (int i = 0; i < subwords.length; i++) subwords[i]: i,
    };
    final int S = subwords.length;

    // 3) Inicializar embeddings: para cada palabra, lista de
    //    subword IDs.
    final List<List<int>> wordToSubwords = <List<int>>[
      for (final String w in vocab)
        <int>[for (final String sw in _subwords(w)) subwordId[sw]!],
    ];

    // 4) Distribución de muestreo negativo: unif(0.75).
    final List<double> negDist = _unigram075(
      <String, int>{
        for (int i = 0; i < vocab.length; i++) vocab[i]: wordCounts[vocab[i]]!,
      },
      vocab,
    );

    // 5) Embeddings: input (subwords) y output (palabras).
    //    Vector de palabra = promedio de sus subwords.
    final List<List<double>> inputVectors = <List<double>>[
      for (int i = 0; i < S; i++) _randVec(rng),
    ];
    final List<List<double>> outputVectors = <List<double>>[
      for (int i = 0; i < V; i++) List<double>.filled(dim, 0.0),
    ];

    // 6) Entrenamiento: skip-gram con negative sampling.
    for (int epoch = 0; epoch < epochs; epoch++) {
      double totalLoss = 0.0;
      int pairs = 0;
      for (final List<String> doc in tokenizedDocs) {
        for (int center = 0; center < doc.length; center++) {
          final int? cId = wordId[doc[center]];
          if (cId == null) continue;
          final int dynamicWindow =
              1 + rng.nextInt(window);
          for (int offset = -dynamicWindow;
              offset <= dynamicWindow;
              offset++) {
            if (offset == 0) continue;
            final int ctx = center + offset;
            if (ctx < 0 || ctx >= doc.length) continue;
            final int? pId = wordId[doc[ctx]];
            if (pId == null) continue;
            // Positive update.
            totalLoss += _skipgramStep(
              centerId: cId,
              contextId: pId,
              isPositive: true,
              inputVectors: inputVectors,
              outputVectors: outputVectors,
              centerSubwords: wordToSubwords[cId],
              rng: rng,
              negDist: negDist,
            );
            // Negative samples.
            for (int n = 0; n < negativeSamples; n++) {
              final int negId = _negSample(negDist, rng);
              if (negId == pId) continue;
              totalLoss += _skipgramStep(
                centerId: cId,
                contextId: negId,
                isPositive: false,
                inputVectors: inputVectors,
                outputVectors: outputVectors,
                centerSubwords: wordToSubwords[cId],
                rng: rng,
                negDist: negDist,
              );
            }
            pairs++;
          }
        }
      }
      // ignore: avoid_print
      print('  epoch ${epoch + 1}/$epochs: '
          'loss=${(totalLoss / pairs).toStringAsFixed(4)}');
    }

    return WordEmbedding(
      vocab: vocab,
      subwords: subwords,
      wordToSubwords: wordToSubwords,
      inputVectors: inputVectors,
      dim: dim,
    );
  }

  List<String> _subwords(String word) {
    final List<String> out = <String>[];
    // Padding con < y > para marcar inicio/fin (estilo fastText).
    final String padded = '<$word>';
    if (padded.length < subwordMin) {
      out.add(padded);
      return out;
    }
    for (int n = subwordMin; n <= subwordMax; n++) {
      if (n > padded.length) break;
      for (int i = 0; i + n <= padded.length; i++) {
        out.add(padded.substring(i, i + n));
      }
    }
    return out;
  }

  List<double> _randVec(math.Random rng) {
    final List<double> v = List<double>.filled(dim, 0.0);
    for (int i = 0; i < dim; i++) {
      v[i] = (rng.nextDouble() - 0.5) / dim;
    }
    return v;
  }

  List<double> _unigram075(
    Map<String, int> counts,
    List<String> vocab,
  ) {
    final List<double> dist = List<double>.filled(vocab.length, 0.0);
    double total = 0.0;
    for (final String w in vocab) {
      final double p = math.pow(counts[w]!, 0.75).toDouble();
      dist[vocab.indexOf(w)] = p;
      total += p;
    }
    for (int i = 0; i < dist.length; i++) {
      dist[i] /= total;
    }
    return dist;
  }

  int _negSample(List<double> dist, math.Random rng) {
    final double r = rng.nextDouble();
    double acc = 0.0;
    for (int i = 0; i < dist.length; i++) {
      acc += dist[i];
      if (r < acc) return i;
    }
    return dist.length - 1;
  }

  double _skipgramStep({
    required int centerId,
    required int contextId,
    required bool isPositive,
    required List<List<double>> inputVectors,
    required List<List<double>> outputVectors,
    required List<int> centerSubwords,
    required math.Random rng,
    required List<double> negDist,
  }) {
    // h = promedio de los subword vectors del center
    final List<double> h = List<double>.filled(dim, 0.0);
    for (final int sid in centerSubwords) {
      final List<double> s = inputVectors[sid];
      for (int i = 0; i < dim; i++) {
        h[i] += s[i];
      }
    }
    if (centerSubwords.isNotEmpty) {
      for (int i = 0; i < dim; i++) {
        h[i] /= centerSubwords.length;
      }
    }

    // score = dot(h, output[context])
    final List<double> oc = outputVectors[contextId];
    double dot = 0.0;
    for (int i = 0; i < dim; i++) {
      dot += h[i] * oc[i];
    }
    final double sigmoid =
        1.0 / (1.0 + math.exp(-dot.clamp(-10.0, 10.0)));
    final double label = isPositive ? 1.0 : 0.0;
    final double grad = (sigmoid - label) * learningRate;

    // Actualizar output[context] con gradiente.
    for (int i = 0; i < dim; i++) {
      oc[i] -= grad * h[i];
    }
    // Actualizar input subwords con gradiente.
    for (final int sid in centerSubwords) {
      final List<double> s = inputVectors[sid];
      for (int i = 0; i < dim; i++) {
        s[i] -= grad * oc[i] / centerSubwords.length;
      }
    }

    // Cross-entropy loss.
    final double loss = isPositive
        ? -math.log(sigmoid <= 1e-10 ? 1e-10 : sigmoid)
        : -math.log((1 - sigmoid) <= 1e-10 ? 1e-10 : (1 - sigmoid));
    return loss;
  }
}

/// Modelo de embeddings entrenado: vocabularios + subwords +
/// vectores de subword. El vector de una palabra se computa en
/// demanda como el promedio de los vectores de sus subwords.
class WordEmbedding {
  WordEmbedding({
    required this.vocab,
    required this.subwords,
    required this.wordToSubwords,
    required this.inputVectors,
    required this.dim,
  });

  final List<String> vocab;
  final List<String> subwords;
  final List<List<int>> wordToSubwords;
  final List<List<double>> inputVectors;
  final int dim;

  final Map<String, int> _wordId = <String, int>{};
  final Map<String, int> _subwordId = <String, int>{};

  /// Devuelve el ID de una palabra, o -1 si OOV.
  int wordId(String word) => _wordId[word] ?? _lookupWord(word);

  int _lookupWord(String word) {
    _ensureMaps();
    return _wordId[word] ?? -1;
  }

  void _ensureMaps() {
    if (_wordId.isEmpty) {
      for (int i = 0; i < vocab.length; i++) {
        _wordId[vocab[i]] = i;
      }
    }
    if (_subwordId.isEmpty) {
      for (int i = 0; i < subwords.length; i++) {
        _subwordId[subwords[i]] = i;
      }
    }
  }

  /// Vector de una palabra (promedio de subwords). Devuelve
  /// vector de ceros si no se puede computar.
  List<double> vectorOf(String word) {
    _ensureMaps();
    if (_wordId.containsKey(word)) {
      return _averageSubwords(wordToSubwords[_wordId[word]!]);
    }
    // OOV: descomponer en subwords y promediar.
    final List<int> swIds = <int>[];
    final String padded = '<$word>';
    for (int n = 3; n <= 6; n++) {
      if (n > padded.length) break;
      for (int i = 0; i + n <= padded.length; i++) {
        final int? id = _subwordId[padded.substring(i, i + n)];
        if (id != null) swIds.add(id);
      }
    }
    if (swIds.isEmpty) return List<double>.filled(dim, 0.0);
    return _averageSubwords(swIds);
  }

  /// Vector de un documento: promedio de los vectores de sus
  /// palabras.
  List<double> vectorOfDoc(List<String> words) {
    if (words.isEmpty) return List<double>.filled(dim, 0.0);
    final List<double> acc = List<double>.filled(dim, 0.0);
    int count = 0;
    for (final String w in words) {
      final List<double> v = vectorOf(w);
      if (_isZero(v)) continue;
      for (int i = 0; i < dim; i++) {
        acc[i] += v[i];
      }
      count++;
    }
    if (count == 0) return List<double>.filled(dim, 0.0);
    for (int i = 0; i < dim; i++) {
      acc[i] /= count;
    }
    return acc;
  }

  List<double> _averageSubwords(List<int> ids) {
    if (ids.isEmpty) return List<double>.filled(dim, 0.0);
    final List<double> acc = List<double>.filled(dim, 0.0);
    for (final int id in ids) {
      final List<double> v = inputVectors[id];
      for (int i = 0; i < dim; i++) {
        acc[i] += v[i];
      }
    }
    for (int i = 0; i < dim; i++) {
      acc[i] /= ids.length;
    }
    return acc;
  }

  bool _isZero(List<double> v) {
    for (final double x in v) {
      if (x.abs() > 1e-9) return false;
    }
    return true;
  }
}
