import 'package:drift/drift.dart';

import '../app_database.dart';

part 'conversations_dao.g.dart';

/// DAO para la tabla `conversations`.
@DriftAccessor(tables: <Type>[Conversations, Messages])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(super.db);

  /// Crea una nueva conversación. Retorna el id.
  Future<int> create({String? title}) {
    final now = DateTime.now();
    return into(conversations).insert(
      ConversationsCompanion.insert(
        createdAt: now,
        updatedAt: now,
        title: Value<String?>(title),
      ),
    );
  }

  /// Renombra (título) una conversación.
  Future<bool> rename(int id, String? title) async {
    final updated = await (update(conversations)
          ..where(($ConversationsTable c) => c.id.equals(id)))
        .write(ConversationsCompanion(
      title: Value<String?>(title),
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
    return updated > 0;
  }

  /// Toca (actualiza) `updatedAt` (llamar al añadir mensajes).
  Future<void> touch(int id) async {
    await (update(conversations)
          ..where(($ConversationsTable c) => c.id.equals(id)))
        .write(ConversationsCompanion(
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
  }

  /// Elimina una conversación. Cascadea a messages y conversation_contexts.
  Future<int> remove(int id) {
    return (delete(conversations)
          ..where(($ConversationsTable c) => c.id.equals(id)))
        .go();
  }

  /// Lee una conversación por id.
  Future<Conversation?> byId(int id) {
    return (select(conversations)
          ..where(($ConversationsTable c) => c.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Stream de todas las conversaciones, más recientes primero.
  Stream<List<Conversation>> watchAll() {
    return (select(conversations)
          ..orderBy([
            ($ConversationsTable c) => OrderingTerm.desc(c.updatedAt),
          ]))
        .watch();
  }

  /// Lista puntual con conteo de mensajes (subquery correlacionada).
  Future<List<ConversationWithCount>> allWithMessageCount() async {
    // Subquery correlacionada para el conteo de mensajes.
    final Expression<int> countExpr = const CustomExpression<int>(
      '(SELECT COUNT(*) FROM messages WHERE messages.conversation_id = conversations.id)',
    );

    final q = select(conversations).addColumns(<Expression<Object>>[
      countExpr,
    ])
      ..orderBy([OrderingTerm.desc(conversations.updatedAt)]);

    final rows = await q.get();
    return rows
        .map((row) => ConversationWithCount(
              conversation: row.readTable(conversations),
              messageCount: row.read<int>(countExpr) ?? 0,
            ))
        .toList();
  }
}

class ConversationWithCount {
  const ConversationWithCount({
    required this.conversation,
    required this.messageCount,
  });
  final Conversation conversation;
  final int messageCount;
}
