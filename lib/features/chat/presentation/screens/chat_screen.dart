import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla principal: chat con la Biblia.
///
/// Sprint 2: la UI básica está lista, pero el Bible Engine (lexicon +
/// embeddings) se implementa en Sprint 3 y 4. Por ahora esta pantalla
/// ofrece atajos a las funciones principales y muestra el principio
/// fundamental de la app.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, this.conversationId});

  /// Si es `null`, se crea/usa la conversación activa.
  final int? conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orar'),
        actions: <Widget>[
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.auto_stories, size: 48, color: Colors.brown),
                    SizedBox(height: 12),
                    Text(
                      'Bienvenido a Oración',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aquí podrás expresarte libremente. La Biblia responderá '
                      'con pasajes relevantes, nunca con texto generado por IA.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Principio fundamental:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Oración no responde al usuario. Oración encuentra y '
                      'presenta pasajes bíblicos relevantes. Toda respuesta '
                      'visible para el usuario proviene de la Biblia.',
                    ),
                    const SizedBox(height: 16),
                    const Text('Acciones rápidas:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () => context.push('/reader'),
                          icon: const Icon(Icons.menu_book_outlined),
                          label: const Text('Lector bíblico'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/favorites'),
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Favoritos'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/history'),
                          icon: const Icon(Icons.history),
                          label: const Text('Historial'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.bolt_outlined,
                            color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        const Text('Estado: Sprint 2',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✓ Corpus bíblico RV1909 (31,102 versículos) cargado.\n'
                      '✓ Lector, Favoritos, Historial y Configuración funcionales.\n'
                      '◷ Bible Engine (chat conversacional con búsqueda '
                      'semántica) en Sprint 3 y 4.',
                    ),
                  ],
                ),
              ),
            ),
            if (conversationId != null) ...<Widget>[
              const SizedBox(height: 8),
              Text('Conversación #$conversationId',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}
