import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracion/core/database/app_database.dart';
import 'package:oracion/core/database/daos/messages_dao.dart';
import 'package:oracion/core/services/lexicon_service.dart';
import 'package:oracion/core/services/logger.dart';
import 'package:oracion/features/chat/data/chat_repository.dart';
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

Future<void> _insertTag(AppDatabase db, int verseId, String tag) async {
  await db.into(db.verseTags).insert(
        VerseTagsCompanion.insert(verseId: verseId, tag: tag),
      );
}

void main() {
  group('ChatRepository', () {
    late AppDatabase db;
    late ChatRepository repo;
    late AppLogger logger;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      logger = AppLogger.create();

      // Corpus mínimo: 3 versículos con tag "paz" + 3 sin tags.
      // Los 3 sin tags alimentan el fallback cuando todos los
      // "paz" ya se mostraron.
      await _insertVerse(db, 1,
          book: 'Génesis', bookNumber: 1, chapter: 1, verse: 1, body: 'v1');
      await _insertVerse(db, 2,
          book: 'Salmos', bookNumber: 19, chapter: 23, verse: 1, body: 'v2');
      await _insertVerse(db, 3,
          book: 'Isaías', bookNumber: 23, chapter: 41, verse: 10, body: 'v3');
      await _insertVerse(db, 4,
          book: 'Mateo', bookNumber: 40, chapter: 5, verse: 9, body: 'v4');
      await _insertVerse(db, 5,
          book: 'Marcos', bookNumber: 41, chapter: 4, verse: 39, body: 'v5');
      await _insertVerse(db, 6,
          book: 'Lucas', bookNumber: 42, chapter: 6, verse: 38, body: 'v6');
      await _insertTag(db, 1, 'paz');
      await _insertTag(db, 2, 'paz');
      await _insertTag(db, 3, 'paz');

      final LexiconService lexicon = LexiconService.forTesting(
        <String, List<String>>{'paz': <String>['paz']},
      );
      final VerseSelector selector = VerseSelector(
        versesDao: db.versesDao,
        lexicon: lexicon,
        contextDao: db.contextDao,
        finalN: 3,
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

    test('persiste el mensaje del usuario con role=user', () async {
      final int convId = await db.conversationsDao.create();
      await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );

      final List<Message> msgs =
          await db.messagesDao.listByConversation(convId).then(
                (List<MessageWithVerse> l) => l
                    .map((MessageWithVerse mv) => mv.message)
                    .toList(),
              );
      // Primero user, luego 3 bible (en orden cronológico).
      expect(msgs, hasLength(4));
      expect(msgs.first.role, MessageRole.user);
      expect(msgs.first.content, 'paz');
      expect(msgs.skip(1).every((Message m) => m.role == MessageRole.bible),
          isTrue);
    });

    test('persiste cada versículo con role=bible y verseId', () async {
      final int convId = await db.conversationsDao.create();
      final ChatTurnResult result = await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );

      expect(result.result.verses, hasLength(3));

      final List<MessageWithVerse> msgs =
          await db.messagesDao.listByConversation(convId);
      // Saltamos el user, los 3 siguientes son bible.
      final List<MessageWithVerse> bibleMsgs =
          msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.bible).toList();
      expect(bibleMsgs, hasLength(3));
      for (final MessageWithVerse mv in bibleMsgs) {
        expect(mv.message.verseId, isNotNull);
        expect(mv.verse, isNotNull);
        expect(mv.verse!.book, isNotEmpty);
        expect(mv.verse!.body, isNotEmpty);
      }
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
      expect(after.searchesPerformed - searchesBefore, result.result.verses.length);
    });

    test('toca la conversación (updatedAt cambia)', () async {
      final int convId = await db.conversationsDao.create();
      final Conversation? before = await db.conversationsDao.byId(convId);
      // Drift almacena DateTime como segundos UNIX, así que
      // dormimos >1s para garantizar un timestamp estrictamente
      // posterior en el siguiente touch().
      await Future<void>.delayed(const Duration(milliseconds: 1100));

      await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      final Conversation? after = await db.conversationsDao.byId(convId);
      expect(after!.updatedAt.isAfter(before!.updatedAt), isTrue);
    });

    test('múltiples mensajes en la misma conversación persisten todo',
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
      // Turno 1 (match): 1 user + 3 bible.
      // Turno 2 (fallback, todas las 'paz' ya mostradas):
      // 1 user + 3 bible + 1 system.
      // Total: 9.
      expect(msgs, hasLength(9));
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.user),
        hasLength(2),
      );
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.bible),
        hasLength(6),
      );
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.system),
        hasLength(1),
      );
    });

    test('anti-repetición: 2 mensajes seguidos no muestran los mismos versículos',
        () async {
      final int convId = await db.conversationsDao.create();
      final ChatTurnResult r1 = await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      final ChatTurnResult r2 = await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      final Set<int> ids1 = r1.result.verses.map((Verse v) => v.id).toSet();
      final Set<int> ids2 = r2.result.verses.map((Verse v) => v.id).toSet();
      expect(ids1.intersection(ids2), isEmpty);
    });

    test('no inserta mensaje de sistema cuando el engine hace match',
        () async {
      final int convId = await db.conversationsDao.create();
      await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );

      final List<MessageWithVerse> msgs =
          await db.messagesDao.listByConversation(convId);
      expect(
        msgs.where((MessageWithVerse mv) => mv.message.role == MessageRole.system),
        isEmpty,
      );
    });

    test('inserta mensaje de sistema al caer en fallback por agotamiento',
        () async {
      final int convId = await db.conversationsDao.create();
      // Turno 1: match (verses 1, 2, 3).
      await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      // Turno 2: ya no quedan "paz" por mostrar → fallback.
      final ChatTurnResult r2 = await repo.processUserMessage(
        userInput: 'paz',
        conversationId: convId,
      );
      expect(r2.result.usedFallback, isTrue);

      final List<MessageWithVerse> msgs =
          await db.messagesDao.listByConversation(convId);
      final List<MessageWithVerse> systemMsgs = msgs
          .where((MessageWithVerse mv) => mv.message.role == MessageRole.system)
          .toList();
      expect(systemMsgs, hasLength(1));
      // El texto menciona "paz" porque sí hubo match en lexicon.
      expect(systemMsgs.first.message.content, contains('paz'));
    });

    test('inserta mensaje de sistema en fallback por input sin tags',
        () async {
      final int convId = await db.conversationsDao.create();
      await repo.processUserMessage(
        userInput: 'xyzsinlex',
        conversationId: convId,
      );

      final List<MessageWithVerse> msgs =
          await db.messagesDao.listByConversation(convId);
      final List<MessageWithVerse> systemMsgs = msgs
          .where((MessageWithVerse mv) => mv.message.role == MessageRole.system)
          .toList();
      expect(systemMsgs, hasLength(1));
      // El texto NO menciona tags (lista vacía).
      expect(systemMsgs.first.message.content, contains('No reconocí'));
    });
  });
}
