// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_dao.dart';

// ignore_for_file: type=lint
mixin _$ContextDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ConversationContextsTable get conversationContexts =>
      attachedDatabase.conversationContexts;
  ContextDaoManager get managers => ContextDaoManager(this);
}

class ContextDaoManager {
  final _$ContextDaoMixin _db;
  ContextDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ConversationContextsTableTableManager get conversationContexts =>
      $$ConversationContextsTableTableManager(
        _db.attachedDatabase,
        _db.conversationContexts,
      );
}
