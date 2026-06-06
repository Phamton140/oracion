import 'package:drift/drift.dart';

import '../app_database.dart';

part 'favorites_dao.g.dart';

/// DAO para la tabla `favorites`.
@DriftAccessor(tables: <Type>[Favorites, Verses])
class FavoritesDao extends DatabaseAccessor<AppDatabase>
    with _$FavoritesDaoMixin {
  FavoritesDao(super.db);

  /// Inserta un favorito. Si ya existe el (verseId), se ignora.
  /// Retorna el id del favorito (nuevo o existente).
  Future<int> addOrIgnore({required int verseId, String? note}) async {
    final existing = await (select(favorites)
          ..where(($FavoritesTable f) => f.verseId.equals(verseId))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }
    return into(favorites).insert(
      FavoritesCompanion.insert(
        verseId: verseId,
        createdAt: DateTime.now(),
        note: Value<String?>(note),
      ),
    );
  }

  /// Elimina el favorito por verseId. Retorna el número de filas borradas.
  Future<int> removeByVerseId(int verseId) {
    return (delete(favorites)
          ..where(($FavoritesTable f) => f.verseId.equals(verseId)))
        .go();
  }

  /// Elimina un favorito por su id (PK).
  Future<int> removeById(int id) {
    return (delete(favorites)..where(($FavoritesTable f) => f.id.equals(id)))
        .go();
  }

  /// Actualiza la nota de un favorito por su id.
  Future<bool> updateNote(int id, String? note) async {
    final updated = await (update(favorites)
          ..where(($FavoritesTable f) => f.id.equals(id)))
        .write(FavoritesCompanion(note: Value<String?>(note)));
    return updated > 0;
  }

  /// ¿Es favorito?
  Future<bool> isFavorite(int verseId) async {
    final q = select(favorites)
      ..where(($FavoritesTable f) => f.verseId.equals(verseId))
      ..limit(1);
    final row = await q.getSingleOrNull();
    return row != null;
  }

  /// Stream de favoritos con join a versículos. Ordenados por fecha desc.
  Stream<List<FavoriteWithVerse>> watchAllWithVerse() {
    final query = select(favorites).join(<Join<HasResultSet, dynamic>>[
      innerJoin(verses, verses.id.equalsExp(favorites.verseId)),
    ])
      ..orderBy(<OrderingTerm>[OrderingTerm.desc(favorites.createdAt)]);
    return query.watch().map((rows) {
      return rows
          .map((row) => FavoriteWithVerse(
                favorite: row.readTable(favorites),
                verse: row.readTable(verses),
              ))
          .toList();
    });
  }

  /// Lista puntual (no-stream) de favoritos con versículo.
  Future<List<FavoriteWithVerse>> allWithVerse() async {
    final query = select(favorites).join(<Join<HasResultSet, dynamic>>[
      innerJoin(verses, verses.id.equalsExp(favorites.verseId)),
    ])
      ..orderBy(<OrderingTerm>[OrderingTerm.desc(favorites.createdAt)]);
    final rows = await query.get();
    return rows
        .map((row) => FavoriteWithVerse(
              favorite: row.readTable(favorites),
              verse: row.readTable(verses),
            ))
        .toList();
  }
}

/// Par (favorito, versículo) usado por el join de la UI.
class FavoriteWithVerse {
  const FavoriteWithVerse({required this.favorite, required this.verse});
  final Favorite favorite;
  final Verse verse;
}
