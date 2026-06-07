import 'package:drift/drift.dart';

import '../app_database.dart';

part 'messages_dao.g.dart';

/// Roles permitidos para un mensaje.
class MessageRole {
  const MessageRole._();
  static const String user = 'user';
  static const String bible = 'bible';
  static const String system = 'system';
}

/// DAO para la tabla `messages`.
@DriftAccessor(tables: <Type>[Messages, Conversations, Verses])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  /// Inserta un mensaje. Retorna el id.
  Future<int> insert({
    required int conversationId,
    required String role,
    required String content,
    int? verseId,
  }) {
    return into(messages).insert(
      MessagesCompanion.insert(
        conversationId: conversationId,
        role: role,
        content: content,
        createdAt: DateTime.now(),
        verseId: Value<int?>(verseId),
      ),
    );
  }

  /// Stream de mensajes de una conversación, en orden cronológico.
  Stream<List<Message>> watchByConversation(int conversationId) {
    return (select(messages)
          ..where(($MessagesTable m) => m.conversationId.equals(conversationId))
          ..orderBy([
            ($MessagesTable m) => OrderingTerm.asc(m.createdAt),
          ]))
        .watch();
  }

  /// Stream de mensajes con join al versículo (puede ser null).
  /// Usado por la pantalla de chat para mostrar la referencia bíblica.
  Stream<List<MessageWithVerse>> watchByConversationWithVerse(
      int conversationId) {
    final j = select(messages).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(verses, verses.id.equalsExp(messages.verseId)),
    ])
      ..where(messages.conversationId.equals(conversationId))
      ..orderBy([OrderingTerm.asc(messages.createdAt)]);

    return j.watch().map((List<TypedResult> rows) {
      return rows
          .map((TypedResult row) => MessageWithVerse(
                message: row.readTable(messages),
                verse: row.readTableOrNull(verses),
              ))
          .toList();
    });
  }

  /// Lista puntual de mensajes con join al versículo (puede ser null).
  Future<List<MessageWithVerse>> listByConversation(int conversationId) async {
    final j = select(messages).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(verses, verses.id.equalsExp(messages.verseId)),
    ])
      ..where(messages.conversationId.equals(conversationId))
      ..orderBy([OrderingTerm.asc(messages.createdAt)]);

    final rows = await j.get();
    return rows
        .map((row) => MessageWithVerse(
              message: row.readTable(messages),
              verse: row.readTableOrNull(verses),
            ))
        .toList();
  }

  /// Cuenta mensajes de una conversación.
  Future<int> countByConversation(int conversationId) async {
    final exp = messages.conversationId.equals(conversationId);
    final countExp = messages.id.count();
    final q = selectOnly(messages)
      ..addColumns(<Expression<Object>>[countExp])
      ..where(exp);
    final row = await q.getSingleOrNull();
    return row?.read(countExp) ?? 0;
  }

  /// Elimina todos los mensajes de una conversación.
  Future<int> deleteByConversation(int conversationId) {
    return (delete(messages)
          ..where(($MessagesTable m) => m.conversationId.equals(conversationId)))
        .go();
  }
}

class MessageWithVerse {
  const MessageWithVerse({required this.message, this.verse});
  final Message message;
  final Verse? verse;
}
