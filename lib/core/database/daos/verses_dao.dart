import 'package:drift/drift.dart';

import '../app_database.dart';

part 'verses_dao.g.dart';

/// DAO para la tabla `verses` (catálogo bíblico read-only).
///
/// Sprint 2: queries reales para el Lector, búsqueda y chat.
@DriftAccessor(tables: <Type>[Verses])
class VersesDao extends DatabaseAccessor<AppDatabase> with _$VersesDaoMixin {
  VersesDao(super.db);

  /// Lista de libros únicos de la Biblia (66 libros, ordenados por número).
  Future<List<BookSummary>> listBooks() async {
    final query = selectOnly(verses)
      ..addColumns(<Expression<Object>>[
        verses.bookNumber,
        verses.book,
        verses.translation,
      ])
      ..groupBy(<Column<Object>>[verses.bookNumber, verses.book, verses.translation])
      ..orderBy(<OrderingTerm>[OrderingTerm.asc(verses.bookNumber)]);

    final rows = await query.get();
    final List<BookSummary> out = <BookSummary>[];
    final Set<int> seen = <int>{};
    for (final row in rows) {
      final bn = row.read(verses.bookNumber);
      final name = row.read(verses.book);
      final tr = row.read(verses.translation);
      if (bn != null && name != null && tr != null && seen.add(bn)) {
        out.add(BookSummary(
          bookNumber: bn,
          name: name,
          translation: tr,
        ));
      }
    }
    return out;
  }

  /// Número de capítulos del libro.
  Future<int> chapterCountFor(int bookNumber) async {
    final exp = verses.bookNumber.equals(bookNumber);
    final q = selectOnly(verses)
      ..addColumns(<Expression<Object>>[verses.chapter.max()])
      ..where(exp);
    final row = await q.getSingleOrNull();
    return row?.read(verses.chapter.max()) ?? 0;
  }

  /// Conteo de versículos por libro (`Map<bookNumber, count>`).
  Future<Map<int, int>> verseCountByBook() async {
    final countExp = verses.id.count();
    final q = selectOnly(verses)
      ..addColumns(<Expression<Object>>[verses.bookNumber, countExp])
      ..groupBy(<Column<Object>>[verses.bookNumber]);

    final Map<int, int> out = <int, int>{};
    for (final row in await q.get()) {
      final bn = row.read(verses.bookNumber);
      final c = row.read(countExp);
      if (bn != null && c != null) {
        out[bn] = c;
      }
    }
    return out;
  }

  /// Versículos de un capítulo (libro + capítulo).
  Future<List<Verse>> byChapter(int bookNumber, int chapter) {
    final stmt = select(verses)
      ..where(($VersesTable v) =>
          v.bookNumber.equals(bookNumber) & v.chapter.equals(chapter))
      ..orderBy([
        ($VersesTable v) => OrderingTerm.asc(v.verse),
      ]);
    return stmt.get();
  }

  /// Versículo por referencia canónica (libro, capítulo, versículo).
  Future<Verse?> byReference(int bookNumber, int chapter, int verse) {
    return (select(verses)
          ..where(($VersesTable v) =>
              v.bookNumber.equals(bookNumber) &
              v.chapter.equals(chapter) &
              v.verse.equals(verse))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Versículo por id (PK).
  Future<Verse?> byId(int id) {
    return (select(verses)..where(($VersesTable v) => v.id.equals(id)))
        .getSingleOrNull();
  }

  /// Busca versículos que contengan el texto (LIKE, case-insensitive via SQL).
  Future<List<Verse>> searchText(String query, {int limit = 200}) {
    final like = '%${_escapeLike(query)}%';
    return (select(verses)
          ..where(($VersesTable v) => v.body.like(like))
          ..orderBy([
            ($VersesTable v) => OrderingTerm.asc(v.bookNumber),
            ($VersesTable v) => OrderingTerm.asc(v.chapter),
            ($VersesTable v) => OrderingTerm.asc(v.verse),
          ])
          ..limit(limit))
        .get();
  }

  /// Versos random excluyendo los ya mostrados.
  Future<List<Verse>> randomExcluding(
    Set<int> excludeIds, {
    int limit = 1,
  }) async {
    final q = select(verses)..limit(limit);
    if (excludeIds.isNotEmpty) {
      q.where(($VersesTable v) => v.id.isNotIn(excludeIds.toList()));
    }
    // Random nativo de SQLite
    q.orderBy([
      ($VersesTable v) => OrderingTerm.random(),
    ]);
    return q.get();
  }

  /// IDs de versículos que tengan TODOS los tags dados (AND, no OR).
  Future<List<int>> idsByAllTags(List<String> tags, {int limit = 200}) async {
    if (tags.isEmpty) return <int>[];
    final vt = attachedDatabase.verseTags;
    final String placeholders = List<String>.filled(tags.length, '?').join(',');
    final rows = await customSelect(
      'SELECT verse_id FROM verse_tags '
      'WHERE tag IN ($placeholders) '
      'GROUP BY verse_id '
      'HAVING COUNT(DISTINCT tag) = ? '
      'LIMIT ?',
      variables: <Variable<Object>>[
        for (final String t in tags) Variable<String>(t),
        Variable<int>(tags.length),
        Variable<int>(limit),
      ],
      readsFrom: <TableInfo<Table, dynamic>>{vt},
    ).get();
    return rows.map((r) => r.read<int>('verse_id')).toList();
  }

  /// IDs de versículos que tengan CUALQUIERA de los tags dados (OR).
  Future<List<int>> idsByAnyTag(List<String> tags, {int limit = 200}) async {
    if (tags.isEmpty) return <int>[];
    final vt = attachedDatabase.verseTags;
    final String placeholders = List<String>.filled(tags.length, '?').join(',');
    final rows = await customSelect(
      'SELECT DISTINCT verse_id FROM verse_tags '
      'WHERE tag IN ($placeholders) '
      'LIMIT ?',
      variables: <Variable<Object>>[
        for (final String t in tags) Variable<String>(t),
        Variable<int>(limit),
      ],
      readsFrom: <TableInfo<Table, dynamic>>{vt},
    ).get();
    return rows.map((r) => r.read<int>('verse_id')).toList();
  }

  String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}

/// Resumen ligero de un libro bíblico (sin capítulos ni versículos).
class BookSummary {
  const BookSummary({
    required this.bookNumber,
    required this.name,
    required this.translation,
  });

  final int bookNumber;
  final String name;
  final String translation;
}
