import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/conversations_dao.dart';
import '../../../core/di/providers.dart';
import '../../../core/services/logger.dart';

/// Controller de la sesión activa del chat.
///
/// Mantiene el `conversationId` de la conversación actual cuando el
/// usuario está usando la pestaña "Orar" sin un id explícito en la
/// ruta (caso por defecto al abrir la app).
///
/// Problema que resuelve: sin este controller, el primer mensaje
/// crea una conversación, y el segundo mensaje (sin un id en la
/// ruta) crearía OTRA conversación, perdiendo el contexto previo.
///
/// Uso:
///   final id = await ref
///       .read(chatSessionControllerProvider.notifier)
///       .ensureActive();
class ChatSessionController extends StateNotifier<int?> {
  ChatSessionController({
    required ConversationsDao conversationsDao,
    required AppLogger logger,
  })  : _conversationsDao = conversationsDao,
        _logger = logger,
        super(null);

  final ConversationsDao _conversationsDao;
  final AppLogger _logger;

  /// Devuelve el `conversationId` activo. Si no hay ninguno (sesión
  /// nueva), crea una conversación vacía y la adopta como activa.
  Future<int> ensureActive() async {
    final int? current = state;
    if (current != null) return current;
    final int id = await _conversationsDao.create();
    state = id;
    _logger.d('Nueva sesión de chat: conv=$id');
    return id;
  }

  /// Resetea la sesión activa (para el botón "Nueva conversación").
  void reset() {
    if (state == null) return;
    _logger.d('Sesión de chat reseteada (era conv=$state)');
    state = null;
  }
}

/// Provider Riverpod del controller de sesión del chat.
///
/// Es un provider regular (no auto-dispose) para que múltiples
/// widgets puedan observar la misma sesión. El reset se hace
/// explícitamente con el botón "Nueva conversación" en la UI.
final StateNotifierProvider<ChatSessionController, int?>
    chatSessionControllerProvider =
    StateNotifierProvider<ChatSessionController, int?>((Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider);
  return ChatSessionController(
    conversationsDao: db.conversationsDao,
    logger: logger,
  );
});
