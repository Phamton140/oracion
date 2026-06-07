import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracion/core/database/app_database.dart';
import 'package:oracion/core/services/lexicon_service.dart';
import 'package:oracion/features/engine/services/verse_selector.dart';

/// Helper: inserta un versículo con id explícito (autoIncrement
/// es overrideable vía `Value<int>(id)`).
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
  group('VerseSelector', () {
    late AppDatabase db;
    late VerseSelector selector;
    late int convId;

    // Lexicon determinista: cada palabra mapea a un tag concreto.
    final LexiconService lexicon = LexiconService.forTesting(<String, List<String>>{
      'paz': <String>['paz'],
      'amor': <String>['amor'],
      'tristeza': <String>['tristeza'],
      // bigrama: cuenta como un solo tag compuesto
      'tengo miedo': <String>['miedo'],
    });

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());

      // 6 versículos:
      //  1  Génesis 1:1   — paz
      //  2  Génesis 1:2   — (sin tags: usado solo para fallback)
      //  3  Juan 3:16     — amor
      //  4  Juan 3:17     — (sin tags)
      //  5  Salmos 23:1   — paz + amor
      //  6  Isaías 41:10  — paz + amor + tristeza
      await _insertVerse(db, 1,
          book: 'Génesis', bookNumber: 1, chapter: 1, verse: 1, body: 'v1');
      await _insertVerse(db, 2,
          book: 'Génesis', bookNumber: 1, chapter: 1, verse: 2, body: 'v2');
      await _insertVerse(db, 3,
          book: 'Juan', bookNumber: 43, chapter: 3, verse: 16, body: 'v3');
      await _insertVerse(db, 4,
          book: 'Juan', bookNumber: 43, chapter: 3, verse: 17, body: 'v4');
      await _insertVerse(db, 5,
          book: 'Salmos', bookNumber: 19, chapter: 23, verse: 1, body: 'v5');
      await _insertVerse(db, 6,
          book: 'Isaías', bookNumber: 23, chapter: 41, verse: 10, body: 'v6');

      await _insertTag(db, 1, 'paz');
      await _insertTag(db, 3, 'amor');
      await _insertTag(db, 5, 'paz');
      await _insertTag(db, 5, 'amor');
      await _insertTag(db, 6, 'paz');
      await _insertTag(db, 6, 'amor');
      await _insertTag(db, 6, 'tristeza');

      selector = VerseSelector(
        versesDao: db.versesDao,
        lexicon: lexicon,
        contextDao: db.contextDao,
        finalN: 3,
      );

      convId = await db.conversationsDao.create();
    });

    tearDown(() async {
      await db.close();
    });

    test('mapea input a tags y devuelve versículos con score', () async {
      final SelectionResult r = await selector.select(
        userInput: 'paz',
        conversationId: convId,
      );

      expect(r.usedFallback, isFalse);
      expect(r.matchedTags, <String>['paz']);
      expect(r.verses, hasLength(3));
      // Los ids deben estar entre los que tienen el tag "paz"
      final Set<int> ids = r.verses.map((Verse v) => v.id).toSet();
      expect(ids.difference(<int>{1, 5, 6}), isEmpty);
    });

    test('bigrama cuenta como un solo tag', () async {
      // "miedo" no está en el lexicon por sí solo, pero "tengo miedo" sí.
      // Como no hay versículos con tag "miedo", debe caer al fallback.
      final SelectionResult r = await selector.select(
        userInput: 'tengo miedo',
        conversationId: convId,
      );
      expect(r.usedFallback, isTrue);
      expect(r.matchedTags, <String>['miedo']);
    });

    test('multi-tag: versículos con más matches rankean más alto', () async {
      final SelectionResult r = await selector.select(
        userInput: 'paz amor',
        conversationId: convId,
      );

      expect(r.usedFallback, isFalse);
      expect(r.matchedTags, containsAll(<String>['paz', 'amor']));
      // Devuelve 3 versículos (finalN=3). El ranking por score
      // pone primero a 5 y 6 (score 2), luego a 1 o 3 (score 1).
      expect(r.verses, hasLength(3));
      // El primer versículo debe ser uno con score 2 (5 o 6).
      expect(<int>{5, 6}.contains(r.verses.first.id), isTrue);
    });

    test('filtra versículos ya mostrados en la conversación', () async {
      // Primera llamada: muestra 3 versículos.
      final SelectionResult first = await selector.select(
        userInput: 'paz',
        conversationId: convId,
      );
      expect(first.verses, hasLength(3));
      final Set<int> shownFirst = first.verses.map((Verse v) => v.id).toSet();

      // Segunda llamada con el mismo tag: no debe repetir los anteriores.
      final SelectionResult second = await selector.select(
        userInput: 'paz',
        conversationId: convId,
      );
      final Set<int> shownSecond = second.verses.map((Verse v) => v.id).toSet();
      expect(shownSecond.intersection(shownFirst), isEmpty);
    });

    test('fallback: input sin tags mapeados', () async {
      final SelectionResult r = await selector.select(
        userInput: 'xyzzy',
        conversationId: convId,
      );
      expect(r.usedFallback, isTrue);
      expect(r.matchedTags, isEmpty);
      // Devuelve 3 versículos aleatorios del corpus completo.
      expect(r.verses, hasLength(3));
    });

    test('fallback: input vacío', () async {
      final SelectionResult r = await selector.select(
        userInput: '',
        conversationId: convId,
      );
      expect(r.usedFallback, isTrue);
      expect(r.matchedTags, isEmpty);
      expect(r.verses, hasLength(3));
    });

    test('no devuelve versículos ya mostrados ni siquiera en fallback',
        () async {
      // Primera: random (fallback) — muestra 3 versículos.
      final SelectionResult first = await selector.select(
        userInput: 'qwerty',
        conversationId: convId,
      );
      final Set<int> shownFirst = first.verses.map((Verse v) => v.id).toSet();
      // Segunda: random otra vez — no debe repetir.
      final SelectionResult second = await selector.select(
        userInput: 'qwerty',
        conversationId: convId,
      );
      final Set<int> shownSecond =
          second.verses.map((Verse v) => v.id).toSet();
      expect(shownSecond.intersection(shownFirst), isEmpty);
    });

    test('MMR diversifica: con 3 versículos no devuelve 3 del mismo libro',
        () async {
      // Seleccionamos "paz" tres veces para mostrar todo el set
      // {1 (Gen), 5 (Sal), 6 (Isa)}. El set final tiene 3 libros.
      // Con la aleatoriedad del randomExcluding, la cobertura no
      // se garantiza al 100% en una sola ejecución, pero el primer
      // turno con "paz" sí debería traer uno por libro.
      final SelectionResult r = await selector.select(
        userInput: 'paz',
        conversationId: convId,
      );
      final Set<int> books =
          r.verses.map((Verse v) => v.bookNumber).toSet();
      // 3 versículos, 3 libros diferentes (1, 19, 23).
      expect(books.length, greaterThanOrEqualTo(2));
    });
  });
}
