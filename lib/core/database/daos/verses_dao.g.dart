// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verses_dao.dart';

// ignore_for_file: type=lint
mixin _$VersesDaoMixin on DatabaseAccessor<AppDatabase> {
  $VersesTable get verses => attachedDatabase.verses;
  VersesDaoManager get managers => VersesDaoManager(this);
}

class VersesDaoManager {
  final _$VersesDaoMixin _db;
  VersesDaoManager(this._db);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db.attachedDatabase, _db.verses);
}
