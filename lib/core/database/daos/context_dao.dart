import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'context_dao.g.dart';

/// DAO para la tabla `conversation_contexts`.
///
/// Guarda el contexto emocional/temático de la conversación actual y
/// la lista de versículos ya mostrados (anti-repetición en MVP).
@DriftAccessor(tables: <Type>[ConversationContexts])
class ContextDao extends DatabaseAccessor<AppDatabase>
    with _$ContextDaoMixin {
  ContextDao(super.db);

  /// Lee el contexto de una conversación (null si no existe).
  Future<ConversationContextEntry?> byConversation(int conversationId) {
    return (select(conversationContexts)
          ..where(($ConversationContextsTable c) =>
              c.conversationId.equals(conversationId))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Asegura que existe un contexto para la conversación (lo crea vacío).
  Future<ConversationContextEntry> ensureExists(int conversationId) async {
    final existing = await byConversation(conversationId);
    if (existing != null) return existing;
    await into(conversationContexts).insert(
      ConversationContextsCompanion.insert(
        conversationId: Value<int>(conversationId),
        turnCount: const Value.absent(),
      ),
    );
    return (await byConversation(conversationId))!;
  }

  /// Actualiza el contexto. Hace upsert.
  Future<void> upsert({
    required int conversationId,
    String? dominantEmotion,
    String? dominantIntent,
    List<String>? topicTags,
    List<int>? shownVerseIds,
    Uint8List? centroid,
    int? turnCount,
  }) async {
    await ensureExists(conversationId);
    await (update(conversationContexts)
          ..where(($ConversationContextsTable c) =>
              c.conversationId.equals(conversationId)))
        .write(ConversationContextsCompanion(
      dominantEmotion: Value<String?>(dominantEmotion),
      dominantIntent: Value<String?>(dominantIntent),
      topicTagsJson: topicTags == null
          ? const Value.absent()
          : Value<String>(jsonEncode(topicTags)),
      shownVerseIdsJson: shownVerseIds == null
          ? const Value.absent()
          : Value<String>(jsonEncode(shownVerseIds)),
      centroid: centroid == null
          ? const Value.absent()
          : Value<Uint8List>(centroid),
      turnCount: turnCount == null
          ? const Value.absent()
          : Value<int>(turnCount),
    ));
  }

  /// Añade versículos al set de mostrados.
  Future<void> addShownVerses(int conversationId, List<int> verseIds) async {
    final ctx = await ensureExists(conversationId);
    final List<int> current = _decodeIds(ctx.shownVerseIdsJson);
    final Set<int> merged = <int>{...current, ...verseIds};
    await (update(conversationContexts)
          ..where(($ConversationContextsTable c) =>
              c.conversationId.equals(conversationId)))
        .write(ConversationContextsCompanion(
      shownVerseIdsJson: Value<String>(jsonEncode(merged.toList())),
    ));
  }

  /// Lee la lista de versículos mostrados (puede ser null/empty).
  Future<List<int>> readShownVerses(int conversationId) async {
    final ctx = await byConversation(conversationId);
    if (ctx == null) return <int>[];
    return _decodeIds(ctx.shownVerseIdsJson);
  }

  List<int> _decodeIds(String? raw) {
    if (raw == null || raw.isEmpty) return <int>[];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<num>().map((n) => n.toInt()).toList();
    }
    return <int>[];
  }
}
