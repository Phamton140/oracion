// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_dao.dart';

// ignore_for_file: type=lint
mixin _$FavoritesDaoMixin on DatabaseAccessor<AppDatabase> {
  $VersesTable get verses => attachedDatabase.verses;
  $FavoritesTable get favorites => attachedDatabase.favorites;
  FavoritesDaoManager get managers => FavoritesDaoManager(this);
}

class FavoritesDaoManager {
  final _$FavoritesDaoMixin _db;
  FavoritesDaoManager(this._db);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db.attachedDatabase, _db.verses);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db.attachedDatabase, _db.favorites);
}
