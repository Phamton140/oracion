import 'package:flutter_test/flutter_test.dart';
import 'package:oracion/core/database/app_database.dart';
import 'package:oracion/features/engine/domain/verse_candidate.dart';
import 'package:oracion/features/engine/services/mmr.dart';

VerseCandidate _candidate({
  required int id,
  required int bookNumber,
  required String book,
  double score = 1.0,
  List<String> tags = const <String>[],
}) {
  return VerseCandidate(
    verse: Verse(
      id: id,
      book: book,
      bookNumber: bookNumber,
      chapter: 1,
      verse: 1,
      body: 'body $id',
      translation: 'RV1909',
    ),
    score: score,
    matchedTags: tags,
  );
}

void main() {
  group('MmrSelector', () {
    test('devuelve todos los candidatos si n <= k', () {
      const MmrSelector mmr = MmrSelector();
      final List<VerseCandidate> cs = <VerseCandidate>[
        _candidate(id: 1, bookNumber: 1, book: 'Gen', score: 0.5),
        _candidate(id: 2, bookNumber: 2, book: 'Exo', score: 1.0),
      ];
      final List<VerseCandidate> picked = mmr.select(cs, 5);
      expect(picked.length, 2);
      // Orden: por score desc
      expect(picked.first.verse.id, 2);
      expect(picked.last.verse.id, 1);
    });

    test('con k=1 elige el de mayor score', () {
      const MmrSelector mmr = MmrSelector();
      final List<VerseCandidate> cs = <VerseCandidate>[
        _candidate(id: 1, bookNumber: 1, book: 'Gen', score: 0.5),
        _candidate(id: 2, bookNumber: 2, book: 'Exo', score: 1.0),
        _candidate(id: 3, bookNumber: 3, book: 'Lev', score: 0.8),
      ];
      final List<VerseCandidate> picked = mmr.select(cs, 1);
      expect(picked.length, 1);
      expect(picked.first.verse.id, 2);
    });

    test('diversifica entre libros cuando hay muchos del mismo libro', () {
      // 5 versículos del libro 1 y 5 del libro 2, todos score 1.0.
      // Con k=3 y lambda=0.7 esperamos 1 o 2 del mismo libro (no 3).
      const MmrSelector mmr = MmrSelector();
      final List<VerseCandidate> cs = <VerseCandidate>[
        for (int i = 1; i <= 5; i++)
          _candidate(id: i, bookNumber: 1, book: 'Gen', score: 1.0),
        for (int i = 6; i <= 10; i++)
          _candidate(id: i, bookNumber: 2, book: 'Exo', score: 1.0),
      ];
      final List<VerseCandidate> picked = mmr.select(cs, 3);
      expect(picked.length, 3);
      final int fromBook1 = picked.where((VerseCandidate c) => c.bookNumber == 1).length;
      final int fromBook2 = picked.where((VerseCandidate c) => c.bookNumber == 2).length;
      // Debe haber al menos 1 de cada libro (diversificación).
      expect(fromBook1, greaterThanOrEqualTo(1));
      expect(fromBook2, greaterThanOrEqualTo(1));
      // Y no más de 2 del mismo libro.
      expect(fromBook1, lessThanOrEqualTo(2));
      expect(fromBook2, lessThanOrEqualTo(2));
    });

    test('con lambda=0 ignora relevancia (puro diversity)', () {
      // lambda=0 -> selecciona primero el de mayor diversity penalty
      // (i.e. ningún libro seleccionado todavía, max sim = 0 para todos).
      // Como todos empatan, devuelve los primeros 3 (orden estable).
      const MmrSelector mmr = MmrSelector(lambda: 0.0);
      final List<VerseCandidate> cs = <VerseCandidate>[
        _candidate(id: 1, bookNumber: 1, book: 'Gen', score: 100.0),
        _candidate(id: 2, bookNumber: 2, book: 'Exo', score: 1.0),
        _candidate(id: 3, bookNumber: 3, book: 'Lev', score: 1.0),
        _candidate(id: 4, bookNumber: 4, book: 'Num', score: 1.0),
      ];
      final List<VerseCandidate> picked = mmr.select(cs, 3);
      // Todos libros diferentes, irrelevante el score.
      expect(picked.length, 3);
      final Set<int> books = picked.map((VerseCandidate c) => c.bookNumber).toSet();
      expect(books.length, 3);
    });

    test('con lambda=1 ignora diversity (puro relevance)', () {
      const MmrSelector mmr = MmrSelector(lambda: 1.0);
      final List<VerseCandidate> cs = <VerseCandidate>[
        for (int i = 1; i <= 5; i++)
          _candidate(id: i, bookNumber: 1, book: 'Gen', score: 1.0),
        for (int i = 6; i <= 10; i++)
          _candidate(id: i, bookNumber: 2, book: 'Exo', score: 0.5),
      ];
      final List<VerseCandidate> picked = mmr.select(cs, 3);
      // Sin diversity, los 3 primeros por score son todos del libro 1.
      expect(picked.length, 3);
      expect(picked.every((VerseCandidate c) => c.bookNumber == 1), isTrue);
    });

    test('lista vacía devuelve vacía', () {
      const MmrSelector mmr = MmrSelector();
      expect(mmr.select(<VerseCandidate>[], 3), isEmpty);
    });

    test('k=0 devuelve vacío', () {
      const MmrSelector mmr = MmrSelector();
      final List<VerseCandidate> cs = <VerseCandidate>[
        _candidate(id: 1, bookNumber: 1, book: 'Gen'),
      ];
      expect(mmr.select(cs, 0), isEmpty);
    });
  });
}
