import 'dart:math' as math;

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracion/core/database/app_database.dart';
import 'package:oracion/core/database/daos/messages_dao.dart';
import 'package:oracion/core/services/logger.dart';
import 'package:oracion/features/chat/data/chat_repository.dart';
import 'package:oracion/features/engine/embeddings/embedding_store.dart';
import 'package:oracion/features/engine/semantic/semantic_index.dart';
import 'package:oracion/features/engine/semantic/semantic_tokenizer.dart';
import 'package:oracion/features/engine/services/query_expander.dart';
import 'package:oracion/features/engine/services/verse_selector.dart';

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

SemanticIndex _buildIndex({
  required List<String> docs,
  required List<int> refIds,
}) {
  const SemanticTokenizer tokenizer = SemanticTokenizer(
    wordNgramMin: 1,
    wordNgramMax: 1,
  );
  final List<List<String>> tokenized = <List<String>>[
    for (final String d in docs) tokenizer.tokenize(d),
  ];
  final Map<String, int> df = <String, int>{};
  for (final List<String> doc in tokenized) {
    for (final String t in doc.toSet()) {
      df[t] = (df[t] ?? 0) + 1;
    }
  }
  final List<String> vocab = df.keys.toList()..sort();
  final Map<String, int> termId = <String, int>{
    for (int i = 0; i < vocab.length; i++) vocab[i]: i,
  };
  final int N = tokenized.length;
  final List<double> idf = <double>[
    for (final String t in vocab)
      math.log(1 + (N - df[t]! + 0.5) / (df[t]! + 0.5)),
  ];
  final List<List<int>> docTerms = <List<int>>[];
  final List<List<double>> docWeights = <List<double>>[];
  int totalLen = 0;
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
    totalLen += toks.length;
  }
  return SemanticIndex.fromCorpus(Bm25CorpusData(
    vocabulary: vocab,
    idf: idf,
    docKinds: <int>[for (int i = 0; i < N; i++) 0],
    docRefIds: refIds,
    documents: docTerms,
    docWeightsPerDoc: docWeights,
    avgDocLength: N == 0 ? 0.0 : totalLen / N,
  ));
}

EmbeddingStore _buildEmbeddings() {
  return EmbeddingStore.fromMemory(
    vocab: <String>['paz', 'amor', 'miedo', 'hola', 'gracias', 'amen'],
    vectors: <List<double>>[
      <double>[1.0, 0.5, 0.0],
      <double>[0.5, 1.0, 0.0],
      <double>[0.0, 0.0, 1.0],
      <double>[0.1, 0.1, 0.1],
      <double>[0.1, 0.1, 0.1],
      <double>[0.1, 0.1, 0.1],
    ],
  );
}

void main() {
  group('ChatRepository (Sprint 4 sin fallback)', () {
    late AppDatabase db;
    late ChatRepository repo;
    late AppLogger logger;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      logger = AppLogger.create();

      await _insertVerse(db, 1,
          book: 'Génesis', bookNumber: 1, chapter: 1, verse: 1, body: 'paz');
      await _insertVerse(db, 2,
          book: 'Salmos', bookNumber: 19, chapter: 23, verse: 1, body: 'paz');
      await _insertVerse(db, 3,
          book: 'Isaías', bookNumber: 23, chapter: 41, verse: 10, body: 'paz');
      await _insertVerse(db, 4,
          book: 'Mateo', bookNumber: 40, chapter: 5, verse: 9, body: 'amor');
      await _insertVerse(db, 5,
          book: 'Marcos', bookNumber: 41, chapter: 4, verse: 39, body: 'miedo');
      await _insertVerse(db, 6,
          book: 'Lucas', bookNumber: 42, chapter: 6, verse: 38, body: 'gracia');

      final SemanticIndex index = _buildIndex(
        docs: <String>[
          'Génesis paz',
          'Salmos paz',
          'Isaías paz',
          'Mateo amor',
          'Marcos miedo',
          'Lucas gracia',
        ],
        refIds: <int>[1, 2, 3, 4, 5, 6],
      );

      final VerseSelector selector = VerseSelector(
        versesDao: db.versesDao,
        bm25Index: index,
        embeddings: _buildEmbeddings(),
        tokenizer: const SemanticTokenizer(),
        expander: QueryExpander.forTesting(<String, List<String>>{
          'paz': <String>['amor', 'miedo'],
        }),
        contextDao: db.contextDao,
        finalN: 3,
        bm25Weight: 0.6,
        embeddingWeight: 0.4,
      );

      repo = ChatRepository(
        conversationsDao: db.conversationsDao,
        messagesDao: db.messagesDao,
        selector: selector,
        usageStatsDao: db.usageStatsDao,
        logger: logger,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('crea conversación nueva si conversationId es null', () async {
      final ChatTurnResult result = await repo.processUserMessage(
        userInput: 'paz',
      );

      expect(result.conversationId, isNotNull);
      final Conversation? conv =
          await db.conversationsDao.byId(result.conversationId);
      expect(conv, isNotNull);
    });

    test('reusa conversationId si se pasa', () async {
      final int convId = await db.conversationsDao.create();
      final ChatTurnResult result = await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      expect(result.conversationId, convId);
    });

    test('persiste user + bible, sin system (reencuadre)', () async {
      final int convId = await db.conversationsDao.create();
      final ChatTurnResult r = await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );

      final List<Message> msgs =
          await db.messagesDao.listByConversation(convId).then(
                (List<MessageWithVerse> l) => l
                    .map((MessageWithVerse mv) => mv.message)
                    .toList(),
              );
      // 1 user + N bible (N = #verses devueltos), sin system.
      expect(msgs, hasLength(1 + r.result.verses.length));
      expect(msgs.first.role, MessageRole.user);
      expect(
        msgs.where((Message m) => m.role == MessageRole.system),
        isEmpty,
      );
    });

    test('NO inserta system message ni con query sin sentido',
        () async {
      final int convId = await db.conversationsDao.create();
      await repo.processUserMessage(
        userInput: 'xyzzynadieentiende',
        conversationId: convId,
      );

      final List<MessageWithVerse> msgs =
          await db.messagesDao.listByConversation(convId);
      // El user message sí se persiste.
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.user),
        hasLength(1),
      );
      // El system message nunca.
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.system),
        isEmpty,
      );
      // Pero siempre hay al menos un bible.
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.bible),
        hasLength(greaterThanOrEqualTo(1)),
      );
    });

    test('incrementa usage_stats.searchesPerformed por #verses', () async {
      final UsageStat before = await db.usageStatsDao.get();
      final int searchesBefore = before.searchesPerformed;

      final int convId = await db.conversationsDao.create();
      final ChatTurnResult result = await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );

      final UsageStat after = await db.usageStatsDao.get();
      expect(after.searchesPerformed - searchesBefore,
          result.result.verses.length);
    });

    test('toca la conversación (updatedAt cambia)', () async {
      final int convId = await db.conversationsDao.create();
      final Conversation? before = await db.conversationsDao.byId(convId);
      await Future<void>.delayed(const Duration(milliseconds: 1100));

      await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      final Conversation? after = await db.conversationsDao.byId(convId);
      expect(after!.updatedAt.isAfter(before!.updatedAt), isTrue);
    });

    test('múltiples turnos persisten 2 user + N bible sin system',
        () async {
      final int convId = await db.conversationsDao.create();
      await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );

      final List<MessageWithVerse> msgs =
          await db.messagesDao.listByConversation(convId);
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.user),
        hasLength(2),
      );
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.system),
        isEmpty,
      );
    });
  });
}
