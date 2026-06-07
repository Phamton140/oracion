import '../../../core/database/app_database.dart';
import '../../../core/database/daos/conversations_dao.dart';
import '../../../core/database/daos/messages_dao.dart';
import '../../../core/database/daos/usage_stats_dao.dart';
import '../../../core/services/logger.dart';
import '../../engine/services/verse_selector.dart';

/// Repository que orquesta el flujo de chat:
///   - Crea o reutiliza una conversación.
///   - Persiste el mensaje del usuario.
///   - Llama al selector de versículos (BM25 + embeddings).
///   - Persiste cada versículo como un mensaje "bible".
///   - Toca la conversación (actualiza `updatedAt`).
///   - Incrementa contadores de `usage_stats`.
///
/// Sprint 4 (reencuadre): ya NO hay mensaje de sistema de
/// fallback aleatorio. Si el selector no encuentra versículos,
/// devuelve los más relevantes del corpus (sin random). Si un
/// meta-intent (saludo, gracias, amén) coincide, se sirven
/// versículos curados directamente.
class ChatRepository {
  ChatRepository({
    required this.conversationsDao,
    required this.messagesDao,
    required this.selector,
    required this.usageStatsDao,
    required this.logger,
  });

  final ConversationsDao conversationsDao;
  final MessagesDao messagesDao;
  final VerseSelector selector;
  final UsageStatsDao usageStatsDao;
  final AppLogger logger;

  /// Procesa una consulta del usuario. Si [conversationId] es null,
  /// crea una conversación nueva.
  ///
  /// Efectos colaterales:
  ///  - Persiste el mensaje del usuario.
  ///  - Persiste cada versículo seleccionado como mensaje `bible`.
  ///  - Toca la conversación y actualiza `usage_stats.searchesPerformed`.
  Future<ChatTurnResult> processUserMessage({
    required String userInput,
    int? conversationId,
  }) async {
    final int convId = conversationId ?? await conversationsDao.create();

    // 1. Persistir el mensaje del usuario.
    await messagesDao.insert(
      conversationId: convId,
      role: MessageRole.user,
      content: userInput,
    );
    await conversationsDao.touch(convId);

    // 2. Pedir selección al engine.
    final SelectionResult result = await selector.select(
      userInput: userInput,
      conversationId: convId,
    );

    // 3. Persistir cada versículo como mensaje "bible".
    for (final Verse v in result.verses) {
      await messagesDao.insert(
        conversationId: convId,
        role: MessageRole.bible,
        content: v.body,
        verseId: v.id,
      );
    }
    await conversationsDao.touch(convId);

    // 4. Contadores (locales, no se envían a ningún servidor).
    if (result.verses.isNotEmpty) {
      await usageStatsDao.incrementSearches(by: result.verses.length);
    }

    logger.i(
      'Chat turn procesado: conv=$convId terms=${result.matchedTerms} '
      'verses=${result.verses.length} metaIntent=${result.usedMetaIntent}',
    );

    return ChatTurnResult(
      conversationId: convId,
      result: result,
    );
  }

  /// Crea una nueva conversación (vacía). Útil para el botón
  /// "Nueva conversación" del chat.
  Future<int> createConversation({String? title}) {
    return conversationsDao.create(title: title);
  }
}

class ChatTurnResult {
  const ChatTurnResult({
    required this.conversationId,
    required this.result,
  });

  final int conversationId;
  final SelectionResult result;
}
