import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/messages_dao.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/logger.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../data/chat_repository.dart';
import '../../data/chat_session_controller.dart';
import '../widgets/message_bubble.dart';

/// Pantalla principal: chat con la Biblia.
///
/// Integra el Bible Engine (Sprint 4): el usuario escribe una
/// intención en español; la app la expande con sinónimos curados,
/// recupera candidatos con BM25, los rerankea con embeddings
/// subword, los diversifica con MMR y devuelve los 3 más
/// relevantes (sin repetir los ya mostrados en esta conversación).
/// No hay fallback aleatorio: si BM25 no encuentra coincidencias,
/// la app lo dice abiertamente al usuario.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.conversationId});

  /// Si es `null`, se crea una conversación nueva en el primer envío.
  final int? conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    _focusNode.unfocus();
    final AppLogger logger = ref.read(loggerProvider);
    try {
      final ChatRepository repo = ref.read(chatRepositoryProvider);
      // Si la ruta fija un conversationId, lo usamos directamente.
      // Si no, lo obtenemos del session controller (que crea uno si
      // no existe y lo mantiene estable entre mensajes).
      final ChatSessionController session =
          ref.read(chatSessionControllerProvider.notifier);
      final int effectiveId =
          widget.conversationId ?? await session.ensureActive();
      await repo.processUserMessage(
        userInput: text,
        conversationId: effectiveId,
      );
      _scrollToBottom();
    } catch (e, st) {
      logger.e('Error procesando chat turn', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _onNewConversation() {
    ref.read(chatSessionControllerProvider.notifier).reset();
    _controller.clear();
    _focusNode.unfocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si la ruta fija un conversationId (al abrir desde Historial),
    // ese manda. Si no, usamos el id activo de la sesión actual.
    final int? sessionId = ref.watch(chatSessionControllerProvider);
    final int? convId = widget.conversationId ?? sessionId;
    final bool canReset = widget.conversationId == null && convId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orar'),
        actions: <Widget>[
          if (canReset)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Nueva conversación',
              onPressed: _onNewConversation,
            ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Lector bíblico',
            onPressed: () => context.push('/reader'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: convId == null
                  ? const _EmptyState()
                  : _MessageList(
                      conversationId: convId,
                      scrollController: _scrollController,
                    ),
            ),
            _InputBar(
              controller: _controller,
              focusNode: _focusNode,
              sending: _sending,
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Icon(Icons.auto_stories, size: 48, color: cs.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'Bienvenido a Oración',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuéntale a Dios lo que sientes. La Biblia responderá '
                    'con pasajes relevantes a tus palabras.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Principio fundamental',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Oración no responde al usuario. Oración encuentra y '
                    'presenta pasajes bíblicos relevantes. Toda respuesta '
                    'visible para el usuario proviene de la Biblia.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sugerencias para empezar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _SuggestionChip(text: 'Tengo miedo'),
                      _SuggestionChip(text: 'Me siento solo'),
                      _SuggestionChip(text: 'Necesito paz'),
                      _SuggestionChip(text: 'Doy gracias'),
                      _SuggestionChip(text: 'Estoy triste'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: cs.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.bolt_outlined, color: cs.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Oración guiada por la Biblia',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escribe tu primera intención en el cuadro inferior. '
                    'Cada versículo mostrado se recordará para no repetirlo '
                    'en esta conversación.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.chat_bubble_outline, size: 16),
      label: Text(text),
      onPressed: () {
        // Disparar la consulta a través del estado del padre.
        final _ChatScreenState? state =
            context.findAncestorStateOfType<_ChatScreenState>();
        if (state == null) return;
        state._controller.text = text;
        state._onSend();
      },
    );
  }
}

class _MessageList extends ConsumerWidget {
  const _MessageList({
    required this.conversationId,
    required this.scrollController,
  });

  final int conversationId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDatabase db = ref.watch(appDatabaseProvider);
    final FavoritesRepository favs = ref.watch(favoritesRepositoryProvider);
    final AppLogger logger = ref.read(loggerProvider);
    final Stream<List<MessageWithVerse>> stream =
        db.messagesDao.watchByConversationWithVerse(conversationId);

    return StreamBuilder<List<MessageWithVerse>>(
      stream: stream,
      builder: (BuildContext context,
          AsyncSnapshot<List<MessageWithVerse>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<MessageWithVerse> items = snapshot.data ?? <MessageWithVerse>[];
        if (items.isEmpty) {
          return const Center(
            child: Text('La conversación está vacía.'),
          );
        }
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int i) {
            final MessageWithVerse mv = items[i];
            final Verse? v = mv.verse;
            return MessageBubble(
              message: mv.message,
              verse: v,
              onFavorite: v == null
                  ? null
                  : () => _onToggleFavorite(context, ref, favs, v.id),
              onShare: v == null
                  ? null
                  : () => _onShare(context, ref, favs, logger, v, mv.message.content),
            );
          },
        );
      },
    );
  }

  Future<void> _onToggleFavorite(
    BuildContext context,
    WidgetRef ref,
    FavoritesRepository favs,
    int verseId,
  ) async {
    try {
      final bool isFav = await favs.toggleFavorite(verseId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFav ? 'Guardado en favoritos' : 'Quitado de favoritos'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e, st) {
      final AppLogger logger = ref.read(loggerProvider);
      logger.e('Error alternando favorito', e, st);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _onShare(
    BuildContext context,
    WidgetRef ref,
    FavoritesRepository favs,
    AppLogger logger,
    Verse v,
    String content,
  ) async {
    try {
      final String ref = '${v.book} ${v.chapter}:${v.verse}';
      await Share.share('$ref\n$content');
      await favs.trackShare(v.id);
    } catch (e, st) {
      logger.e('Error compartiendo versículo', e, st);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Escribe tu intención…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: sending ? null : onSend,
            icon: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            tooltip: 'Enviar',
          ),
        ],
      ),
    );
  }
}
