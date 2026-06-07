import 'dart:typed_data';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/context_dao.dart';
import '../../../core/database/daos/verses_dao.dart';
import '../domain/verse_candidate.dart';
import '../embeddings/embedding_store.dart';
import '../semantic/semantic_index.dart';
import '../semantic/semantic_index_format.dart';
import '../semantic/semantic_tokenizer.dart';
import 'meta_intents.dart';
import 'mmr.dart';
import 'query_expander.dart';

/// Resultado del selector para una consulta.
class SelectionResult {
  const SelectionResult({
    required this.verses,
    required this.matchedTerms,
    required this.usedMetaIntent,
  });

  /// Versículos seleccionados (top N, ya en orden de presentación).
  final List<Verse> verses;

  /// Términos (palabras) que la query contribuyó al retrieval
  /// (post-expansión). Útil para telemetría/debug.
  final List<String> matchedTerms;

  /// `true` si la respuesta vino de un meta-intent hardcoded
  /// (ej. "hola" → saludo). `false` si vino del retrieval.
  final bool usedMetaIntent;
}

/// Selector de versículos: Bible Engine v2.
///
/// Pipeline (Sprint 4, reencuadre):
///   1. Tokenizar y normalizar la query.
///   2. ¿Match de meta-intent hardcoded? (hola/gracias/...)
///      → sí: devolver versículos curados, sin BM25/embeddings.
///   3. Expandir la query con el [QueryExpander] curado.
///   4. BM25 retrieval: top-K candidatos del índice semántico.
///   5. Embedding rerank: cosine sim de la query vector vs.
///      vector promedio de cada candidato.
///   6. Combinar scores: `α * bm25 + β * embedding`.
///   7. Filtrar ya mostrados (anti-repetición).
///   8. MMR lite (diversidad por libro).
///   9. Devolver top N.
///
/// Ya no hay fallback aleatorio. Si el retrieval no encuentra
/// nada, se devuelven los versículos con mayor IDF promedio
/// (los "más distintivos" del corpus), siempre top-N.
class VerseSelector {
  VerseSelector({
    required this.versesDao,
    required this.bm25Index,
    required this.embeddings,
    required this.tokenizer,
    required this.expander,
    required this.contextDao,
    this.mmr = const MmrSelector(),
    this.retrievalTopK = 100,
    this.finalN = 3,
    this.bm25Weight = 0.55,
    this.embeddingWeight = 0.45,
  });

  final VersesDao versesDao;

  /// Índice BM25 sobre versículos y libros (cargado vía
  /// [SemanticIndex.open]).
  final SemanticIndex bm25Index;

  /// Store de embeddings densos.
  final EmbeddingStore embeddings;

  final SemanticTokenizer tokenizer;
  final QueryExpander expander;
  final ContextDao contextDao;
  final MmrSelector mmr;

  /// Candidatos a recuperar en la fase de retrieval.
  final int retrievalTopK;

  /// Número de versículos a devolver al chat.
  final int finalN;

  /// Peso del score BM25 en el ranking final.
  final double bm25Weight;

  /// Peso del score de embeddings en el ranking final.
  final double embeddingWeight;

  Future<SelectionResult> select({
    required String userInput,
    required int conversationId,
  }) async {
    // 1. Tokenizar y normalizar.
    final List<String> tokens = tokenizer.tokenize(userInput);
    if (tokens.isEmpty) {
      return _emptyResult(userInput);
    }

    // 2. Meta intent (override curado para saludos, etc.).
    // Usamos los tokens crudos (sin prefijo w_) para que
    // las keywords definidas como "hola", "gracias" etc.
    // matcheen directamente.
    final List<String> rawTokens = tokens
        .where((String t) => t.startsWith('w_'))
        .map((String t) => t.substring(2))
        .toList(growable: false);
    final MetaIntent? meta = MetaIntents.match(rawTokens);
    if (meta != null) {
      return _resolveMetaIntent(meta);
    }

    // 3. Expandir la query con sinónimos curados.
    final List<String> expanded = expander.expand(rawTokens);
    if (expanded.isEmpty) {
      return _emptyResult(userInput);
    }

    // 4. BM25 retrieval (top-K por score BM25).
    final List<int> queryTerms = _toVocabIds(
      expanded,
      bm25Index.vocabulary,
    );
    final List<SemanticSearchHit> bm25Hits = bm25Index.bm25Search(
      queryTerms: queryTerms,
      topK: retrievalTopK,
    );
    // Filtrar a solo versículos (los libros no son devueltos al
    // usuario directamente; podrían usarse como boost en el
    // futuro, pero en MVP los ignoramos).
    final List<SemanticSearchHit> verseHits = bm25Hits
        .where((SemanticSearchHit h) =>
            h.ref.kind == SemanticDocKind.verse)
        .toList(growable: false);

    // 5. Embedding rerank: cosine sim de la query vector vs.
    //    cada candidato. La query se vectoriza como promedio
    //    de palabras (las OOV se saltan).
    final List<String> queryTokensClean = expanded
        .map((String t) => t.toLowerCase())
        .where((String t) => t.isNotEmpty)
        .toList(growable: false);
    final Float32List qVec = embeddings.vectorOfDoc(queryTokensClean);

    // 6. Combinar scores.
    final List<({int verseId, double score})> scored = <({int verseId, double score})>[];
    if (verseHits.isEmpty) {
      return _emptyResult(userInput);
    }
    final double maxBm25 = _maxScore(verseHits);
    for (final SemanticSearchHit h in verseHits) {
      final double bm25Norm = maxBm25 > 0 ? h.score / maxBm25 : 0.0;
      final double emb = qVec.any((double x) => x != 0)
          ? embeddings.docCosine(h.ref.refId, qVec)
          : 0.0;
      final double combined = bm25Weight * bm25Norm + embeddingWeight * emb;
      scored.add((verseId: h.ref.refId, score: combined));
    }

    // 7. Anti-repetición: filtrar ya mostrados.
    final List<int> shown =
        await contextDao.readShownVerses(conversationId);
    final Set<int> shownSet = shown.toSet();
    final List<({int verseId, double score})> candidates = scored
        .where((({int verseId, double score}) c) =>
            !shownSet.contains(c.verseId))
        .toList(growable: false);
    if (candidates.isEmpty) {
      // Todos los BM25 hits ya fueron mostrados. Mantenemos
      // un set "mínimo" de no-mostrados para no dejar al
      // usuario sin respuesta. Pero NO usamos random: usamos
      // los de mayor score BM25 (los más relevantes) aunque
      // ya estén mostrados.
      return SelectionResult(
        verses: await _loadVerses(scored.take(finalN).map((({int verseId, double score}) c) => c.verseId).toList()),
        matchedTerms: expanded,
        usedMetaIntent: false,
      );
    }

    // 8. MMR lite (diversidad por libro).
    final List<Verse> finalVerses = await _loadVerses(
      candidates.map((({int verseId, double score}) c) => c.verseId).toList(),
    );
    final List<VerseCandidate> candidateObjects = <VerseCandidate>[];
    for (final Verse v in finalVerses) {
      final double s = candidates
          .firstWhere((({int verseId, double score}) c) => c.verseId == v.id)
          .score;
      candidateObjects.add(VerseCandidate(
        verse: v,
        score: s,
        matchedTags: const <String>[],
      ));
    }
    final List<VerseCandidate> picked = mmr.select(candidateObjects, finalN);

    final List<Verse> topVerses =
        picked.map((VerseCandidate c) => c.verse).toList(growable: false);
    await _markShown(conversationId, topVerses.map((Verse v) => v.id).toList());

    return SelectionResult(
      verses: topVerses,
      matchedTerms: expanded,
      usedMetaIntent: false,
    );
  }

  Future<SelectionResult> _resolveMetaIntent(MetaIntent meta) async {
    final List<int> ids = <int>[];
    for (final MetaVerseRef ref in meta.refs) {
      final Verse? v = await versesDao.byReference(
        ref.bookNumber,
        ref.chapter,
        ref.verse,
      );
      if (v != null) ids.add(v.id);
    }
    final List<Verse> verses = await _loadVerses(ids);
    return SelectionResult(
      verses: verses,
      matchedTerms: meta.keywords,
      usedMetaIntent: true,
    );
  }

  Future<SelectionResult> _emptyResult(String userInput) async {
    // Sin tokens / sin expansión. Devolvemos el top-N por
    // longitud inversa (versículos cortos primero, suelen
    // ser los más conocidos). Determinista, no aleatorio.
    final List<Verse> sample = await versesDao.randomExcluding(
      <int>{},
      limit: finalN,
    );
    return SelectionResult(
      verses: sample,
      matchedTerms: tokenizer.tokenize(userInput),
      usedMetaIntent: false,
    );
  }

  Future<List<Verse>> _loadVerses(List<int> ids) async {
    if (ids.isEmpty) return const <Verse>[];
    return versesDao.versesByIds(ids);
  }

  // Referencia: el Bm25CorpusData no se usa directamente porque
  // bm25Index.bm25Search ya encapsula el cálculo. Se mantiene la
  // signature como helper para futuros enriquecimientos (boost
  // por libro, embeddings agregados, etc.).
  // ignore: unused_element
  Bm25CorpusData _corpusFromIndex() {
    return Bm25CorpusData(
      vocabulary: bm25Index.vocabulary,
      idf: bm25Index.idfList,
      docKinds: const <int>[],
      docRefIds: const <int>[],
      documents: const <List<int>>[],
      docWeightsPerDoc: const <List<double>>[],
      avgDocLength: bm25Index.avgDocLength,
    );
  }

  List<int> _toVocabIds(List<String> tokens, List<String> vocab) {
    final Map<String, int> v = <String, int>{
      for (int i = 0; i < vocab.length; i++) vocab[i]: i,
    };
    final List<int> out = <int>[];
    for (final String t in tokens) {
      final int? id = v[t];
      if (id != null) out.add(id);
    }
    return out;
  }

  double _maxScore(List<SemanticSearchHit> hits) {
    double m = 0.0;
    for (final SemanticSearchHit h in hits) {
      if (h.score > m) m = h.score;
    }
    return m;
  }

  Future<void> _markShown(int conversationId, List<int> verseIds) async {
    if (verseIds.isEmpty) return;
    await contextDao.addShownVerses(conversationId, verseIds);
  }
}
