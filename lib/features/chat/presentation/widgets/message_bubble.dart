import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/messages_dao.dart';
import '../../../../core/di/providers.dart';

/// Burbuja de mensaje en el chat.
///
/// Roles soportados:
///   - `MessageRole.user`: usuario (alineado a la derecha).
///   - `MessageRole.bible`: versículo (alineado a la izquierda, con
///     referencia canónica y cuerpo del versículo).
///   - `MessageRole.system`: mensaje de sistema (centrado, opaco).
class MessageBubble extends ConsumerWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.verse,
    this.onFavorite,
    this.onShare,
  });

  final Message message;
  final Verse? verse;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String role = message.role;

    if (role == MessageRole.user) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(color: cs.onPrimary, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (role == MessageRole.bible) {
      final String reference = verse == null
          ? ''
          : '${verse!.book} ${verse!.chapter}:${verse!.verse}';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: cs.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (reference.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          reference,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSecondaryContainer
                                .withValues(alpha: 0.8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: cs.onSecondaryContainer,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (onFavorite != null || onShare != null)
                      _BubbleActions(
                        verseId: verse?.id,
                        onFavorite: onFavorite,
                        onShare: onShare,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // system
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Center(
        child: Text(
          message.content,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontStyle: FontStyle.italic,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Acciones (favorito, compartir) mostradas debajo de cada versículo.
///
/// El icono de favorito es **reactivo**: se rellena automáticamente
/// cuando el versículo pasa a estar en favoritos, sin necesidad de
/// que la pantalla padre haga `setState`.
class _BubbleActions extends ConsumerWidget {
  const _BubbleActions({
    required this.verseId,
    required this.onFavorite,
    required this.onShare,
  });

  final int? verseId;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final AsyncValue<bool> isFav = verseId == null
        ? const AsyncValue<bool>.data(false)
        : ref.watch(_isFavoriteProvider(verseId!));

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (onFavorite != null)
            IconButton(
              icon: Icon(
                isFav.maybeWhen(
                      data: (bool v) => v ? Icons.favorite : Icons.favorite_border,
                      orElse: () => Icons.favorite_border,
                    ) ??
                    Icons.favorite_border,
                size: 18,
              ),
              color: isFav.maybeWhen(
                data: (bool v) => v ? cs.primary : null,
                orElse: () => null,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: isFav.maybeWhen(
                data: (bool v) => v ? 'Quitar de favoritos' : 'Guardar en favoritos',
                orElse: () => 'Guardar en favoritos',
              ),
              onPressed: onFavorite,
            ),
          if (onShare != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: 'Compartir',
              onPressed: onShare,
            ),
        ],
      ),
    );
  }
}

/// StreamProvider.family para "¿es favorito este versículo?".
final StreamProviderFamily<bool, int> _isFavoriteProvider =
    StreamProvider.family<bool, int>((Ref ref, int verseId) {
  return ref.watch(favoritesRepositoryProvider).watchIsFavorite(verseId);
});
