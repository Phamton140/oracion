// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_stats_dao.dart';

// ignore_for_file: type=lint
mixin _$UsageStatsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsageStatsTable get usageStats => attachedDatabase.usageStats;
  UsageStatsDaoManager get managers => UsageStatsDaoManager(this);
}

class UsageStatsDaoManager {
  final _$UsageStatsDaoMixin _db;
  UsageStatsDaoManager(this._db);
  $$UsageStatsTableTableManager get usageStats =>
      $$UsageStatsTableTableManager(_db.attachedDatabase, _db.usageStats);
}
