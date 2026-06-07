import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracion/core/database/app_database.dart';
import 'package:oracion/features/engine/embeddings/embedding_store.dart';
import 'package:oracion/features/engine/embeddings/word2vec_trainer.dart';
import 'package:oracion/features/engine/semantic/bm25_scorer.dart';
import 'package:oracion/features/engine/semantic/semantic_index.dart';
import 'package:oracion/features/engine/semantic/semantic_tokenizer.dart';
import 'package:oracion/features/engine/services/meta_intents.dart';
import 'package:oracion/features/engine/services/query_expander.dart';
import 'package:oracion/features/engine/services/verse_selector.dart';

/// Helper: inserta un versículo con id explícito.
Future<void> _insertVerse(
  AppDatabase db,
  int id, {
  required String book,
  required int bookNumber,
  required int chapter,
  required int verse,
  required String body,
}) async {
  await db.into(db.verses).insert(
        VersesCompanion.insert(
          id: Value<int>(id),
          book: book,
          bookNumber: bookNumber,
          chapter: chapter,
          verse: verse,
          body: body,
        ),
      );
}

/// Construye un SemanticIndex (BM25) en memoria a partir de un
/// corpus sintético.
SemanticIndex _buildBm25Index({
  required List<String> docs,
  required List<int> kinds,
  required List<int> refIds,
}) {
  const SemanticTokenizer tokenizer = SemanticTokenizer(
    wordNgramMin: 1,
    wordNgramMax: 1,
    charNgramMin: 0,
    charNgramMax: 0,
  );
  const Bm25Scorer scorer = Bm25Scorer();
  final List<List<String>> tokenized = <List<String>>[
    for (final String d in docs) tokenizer.tokenize(d),
  ];
  final Bm25Corpus corpus = scorer.fit(tokenizedDocs: tokenized);
  // Construir SparseVectors con frecuencias crudas.
  final Map<String, int> termId = <String, int>{
    for (int i = 0; i < corpus.vocabulary.length; i++) corpus.vocabulary[i]: i,
  };
  final List<List<int>> docTerms = <List<int>>[];
  final List<List<double>> docWeights = <List<double>>[];
  for (final List<String> toks in tokenized) {
    final Map<int, int> counts = <int, int>{};
    for (final String t in toks) {
      final int? id = termId[t];
      if (id == null) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final List<MapEntry<int, int>> entries = counts.entries.toList()
      ..sort((MapEntry<int, int> a, MapEntry<int, int> b) =>
          a.key.compareTo(b.key));
    docTerms.add(<int>[for (final MapEntry<int, int> e in entries) e.key]);
    docWeights.add(<double>[
      for (final MapEntry<int, int> e in entries) e.value.toDouble(),
    ]);
  }
  final Bm25CorpusData data = Bm25CorpusData(
    vocabulary: corpus.vocabulary,
    idf: corpus.idf,
    docKinds: kinds,
    docRefIds: refIds,
    documents: docTerms,
    docWeightsPerDoc: docWeights,
    avgDocLength: corpus.avgDocLength,
  );
  return SemanticIndex.fromCorpus(data);
}

/// Construye un EmbeddingStore trivial: cada palabra tiene un
/// vector one-hot en miniatura (palabras relacionadas comparten
/// dimensiones).
EmbeddingStore _buildToyEmbeddings({
  required List<String> allWords,
  required Map<String, List<String>> wordGroups,
}) {
  final int D = 32;
  final List<List<double>> vectors = <List<double>>[];
  for (final String w in allWords) {
    final List<double> v = List<double>.filled(D, 0.0);
    for (final MapEntry<String, List<String>> g in wordGroups.entries) {
      if (g.value.contains(w)) {
        for (int i = 0; i < g.key.length && i < D; i++) {
          v[g.key.codeUnitAt(i) % D] += 1.0;
        }
      }
    }
    vectors.add(v);
  }
  return EmbeddingStore.fromMemory(vocab: allWords, vectors: vectors);
}

void main() {
  group('VerseSelector (Sprint 4 retrieval)', () {
    late AppDatabase db;
    late VerseSelector selector;
    late int convId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());

      // 15 versículos en español: corpus toy con suficientes
      // candidatos para que la lógica anti-repetición tenga
      // alternativas cuando todos los de un turno se marquen
      // como shown.
      await _insertVerse(db, 1,
          book: 'Génesis', bookNumber: 1, chapter: 1, verse: 1, body: 'paz');
      await _insertVerse(db, 2,
          book: 'Génesis', bookNumber: 1, chapter: 1, verse: 2, body: 'oscuridad');
      await _insertVerse(db, 3,
          book: 'Juan', bookNumber: 43, chapter: 3, verse: 16, body: 'amor');
      await _insertVerse(db, 4,
          book: 'Juan', bookNumber: 43, chapter: 3, verse: 17, body: 'luz');
      await _insertVerse(db, 5,
          book: 'Salmos', bookNumber: 19, chapter: 23, verse: 1, body: 'amor paz');
      await _insertVerse(db, 6,
          book: 'Isaías', bookNumber: 23, chapter: 41, verse: 10, body: 'miedo paz');
      await _insertVerse(db, 7,
          book: 'Romanos', bookNumber: 45, chapter: 5, verse: 1, body: 'paz amor');
      await _insertVerse(db, 8,
          book: 'Filipenses', bookNumber: 50, chapter: 4, verse: 7, body: 'paz amor');
      await _insertVerse(db, 9,
          book: 'Colosenses', bookNumber: 51, chapter: 3, verse: 15, body: 'paz');
      // Más versículos con "paz" para dar holgura a MMR/BM25.
      await _insertVerse(db, 10,
          book: 'Números', bookNumber: 4, chapter: 6, verse: 24, body: 'paz');
      await _insertVerse(db, 11,
          book: 'Salmos', bookNumber: 19, chapter: 29, verse: 11, body: 'paz');
      await _insertVerse(db, 12,
          book: 'Salmos', bookNumber: 19, chapter: 34, verse: 14, body: 'paz');
      await _insertVerse(db, 13,
          book: 'Salmos', bookNumber: 19, chapter: 37, verse: 37, body: 'paz');
      await _insertVerse(db, 14,
          book: 'Isaías', bookNumber: 23, chapter: 52, verse: 7, body: 'paz');
      await _insertVerse(db, 15,
          book: 'Juan', bookNumber: 43, chapter: 14, verse: 27, body: 'paz');

      // Construir BM25 index sobre los versículos.
      final List<String> docs = <String>[
        for (int i = 1; i <= 15; i++) '${(await db.versesDao.byId(i))!.book} '
            '${(await db.versesDao.byId(i))!.body}',
      ];
      final SemanticIndex index = _buildBm25Index(
        docs: docs,
        kinds: List<int>.filled(15, 0),
        refIds: List<int>.generate(15, (int i) => i + 1),
      );

      // Embeddings toy: "paz", "amor", "miedo" comparten
      // dimensiones; "oscuridad", "luz" comparten otras.
      final List<String> allWords = <String>[
        'paz', 'oscuridad', 'amor', 'luz', 'miedo', 'genesis',
        'juan', 'salmos', 'isaias',
      ];
      // wordGroups es un mapa: groupName -> words que comparten
      // dimensiones basadas en el groupName.
      final Map<String, List<String>> wordGroups = <String, List<String>>{
        'paz_amor': <String>['paz', 'amor'],
        'miedo_oscuridad': <String>['miedo', 'oscuridad'],
        'luz_amor': <String>['luz', 'amor'],
      };
      final EmbeddingStore emb = _buildToyEmbeddings(
        allWords: allWords,
        wordGroups: wordGroups,
      );

      final QueryExpander expander = QueryExpander.forTesting(<String, List<String>>{
        'paz': <String>['amor', 'miedo'],
      });

      selector = VerseSelector(
        versesDao: db.versesDao,
        bm25Index: index,
        embeddings: emb,
        tokenizer: const SemanticTokenizer(),
        expander: expander,
        contextDao: db.contextDao,
        finalN: 3,
        bm25Weight: 0.5,
        embeddingWeight: 0.5,
      );

      convId = await db.conversationsDao.create();
    });

    tearDown(() async {
      await db.close();
    });

    test('encuentra "paz" en al menos un versículo', () async {
      final SelectionResult r = await selector.select(
        userInput: 'paz',
        conversationId: convId,
      );
      expect(r.usedMetaIntent, isFalse);
      expect(r.verses, isNotEmpty);
      // Cualquier versículo con "paz" en el cuerpo (1, 5, 6, 7,
      // 8, 9, 10, 11, 12, 13, 14, 15) es un match válido.
      final Set<int> pazVerseIds = <int>{1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
      final Set<int> ids = r.verses.map((Verse v) => v.id).toSet();
      expect(ids.intersection(pazVerseIds), isNotEmpty);
    });

    test('meta-intent: "hola" devuelve versículos curados', () async {
      // "hola" no aparece en ningún versículo del corpus toy.
      // El MetaIntents match debe activar el override.
      // El test depende de que el meta-intent encuentre los
      // versículos por referencia. Como los IDs de referencia
      // son Números 6:24 (id ~4626) y Génesis 1:1 (id=1), solo
      // Génesis 1:1 se resolverá en este corpus toy.
      final SelectionResult r = await selector.select(
        userInput: 'hola',
        conversationId: convId,
      );
      expect(r.usedMetaIntent, isTrue);
      // Al menos un versículo resuelto.
      expect(r.verses, isNotEmpty);
    });

    test('no devuelve versículos ya mostrados en la conversación',
        () async {
      final SelectionResult first = await selector.select(
        userInput: 'paz',
        conversationId: convId,
      );
      expect(first.verses, isNotEmpty);
      final Set<int> shownFirst =
          first.verses.map((Verse v) => v.id).toSet();
      // Segunda llamada con query distinta ("miedo") que matchea
      // a un set de versículos diferente.
      final SelectionResult second = await selector.select(
        userInput: 'miedo',
        conversationId: convId,
      );
      final Set<int> shownSecond =
          second.verses.map((Verse v) => v.id).toSet();
      expect(shownSecond.intersection(shownFirst), isEmpty);
    });

    test('MMR diversifica: con varios versículos, libros distintos',
        () async {
      final SelectionResult r = await selector.select(
        userInput: 'paz',
        conversationId: convId,
      );
      if (r.verses.length >= 2) {
        final Set<int> books =
            r.verses.map((Verse v) => v.bookNumber).toSet();
        expect(books.length, greaterThanOrEqualTo(2));
      }
    });

    test('siempre devuelve al menos un versículo (no fallback vacío)',
        () async {
      final SelectionResult r = await selector.select(
        userInput: 'xyzzynadieentiend esto',
        conversationId: convId,
      );
      expect(r.verses, isNotEmpty);
    });
  });

  group('Word2VecTrainer (subword embeddings)', () {
    test('entrena embeddings mínimos con corpus de prueba', () {
      final Word2VecTrainer trainer = Word2VecTrainer(
        dim: 16,
        window: 2,
        minCount: 1,
        epochs: 2,
        negativeSamples: 2,
        seed: 42,
      );
      final WordEmbedding emb = trainer.train(<List<String>>[
        <String>['debo', 'dinero', 'deuda', 'pago'],
        <String>['deuda', 'pagare', 'préstamo'],
        <String>['amor', 'misericordia', 'gracia'],
        <String>['misericordia', 'gracia', 'amor'],
      ]);
      // "debo" y "deuda" comparten subwords; su coseno debe
      // ser > 0 (no ortogonales).
      final List<double> vDebo = emb.vectorOf('debo');
      final List<double> vDeuda = emb.vectorOf('deuda');
      double dot = 0.0;
      double nd = 0.0;
      double nu = 0.0;
      for (int i = 0; i < vDebo.length; i++) {
        dot += vDebo[i] * vDeuda[i];
        nd += vDebo[i] * vDebo[i];
        nu += vDeuda[i] * vDeuda[i];
      }
      final double cos = dot / (nd <= 0 || nu <= 0 ? 1.0 : nd * nu);
      expect(cos, isNot(equals(0.0)));
    });
  });

  group('EmbeddingStore (cosine + OOV)', () {
    test('vectorOfWord devuelve null para palabras desconocidas', () {
      final EmbeddingStore store = EmbeddingStore.fromMemory(
        vocab: <String>['hola', 'mundo'],
        vectors: <List<double>>[
          <double>[1.0, 0.0],
          <double>[0.0, 1.0],
        ],
      );
      expect(store.vectorOfWord('hola'), isNotNull);
      expect(store.vectorOfWord('desconocido'), isNull);
    });

    test('cosine: vectores idénticos dan 1.0', () {
      final EmbeddingStore store = EmbeddingStore.fromMemory(
        vocab: <String>['a', 'b'],
        vectors: <List<double>>[
          <double>[1.0, 0.0, 0.0],
          <double>[0.0, 1.0, 0.0],
        ],
      );
      final Float32List va = store.vectorOfWord('a')!;
      final Float32List vb = store.vectorOfWord('b')!;
      expect(store.cosine(va, vb), closeTo(0.0, 1e-6));
      expect(store.cosine(va, va), closeTo(1.0, 1e-6));
    });
  });

  group('QueryExpander (curado)', () {
    test('expande una palabra con sus sinónimos', () {
      final QueryExpander exp = QueryExpander.forTesting(<String, List<String>>{
        'debo': <String>['deuda', 'deudor', 'pago'],
      });
      final List<String> out = exp.expand(<String>['debo']);
      expect(out, containsAll(<String>['debo', 'deuda', 'deudor', 'pago']));
    });

    test('palabra sin sinónimos devuelve la original', () {
      final QueryExpander exp = QueryExpander.forTesting(<String, List<String>>{
        'a': <String>['b'],
      });
      expect(exp.expand(<String>['xyz']), <String>['xyz']);
    });
  });

  group('MetaIntents (overrides hardcoded)', () {
    test('matchea "hola" como greeting', () {
      final MetaIntent? m = MetaIntents.match(<String>['hola']);
      expect(m, isNotNull);
      expect(m!.id, 'greeting');
    });

    test('matchea "buenos dias" como good_morning', () {
      final MetaIntent? m =
          MetaIntents.match(<String>['buenos', 'dias', 'amigo']);
      expect(m, isNotNull);
      expect(m!.id, 'good_morning');
    });

    test('no matchea una query topical', () {
      final MetaIntent? m = MetaIntents.match(<String>['debo', 'dinero']);
      expect(m, isNull);
    });
  });
}
