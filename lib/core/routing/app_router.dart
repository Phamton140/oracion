import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/reader/presentation/screens/reader_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/presentation/screens/home_shell.dart';
import '../constants/route_paths.dart';

/// Wrapper que entrega el `GoRouter` configurado.
///
/// Mantener una clase wrapper permite inyectar mocks o configuración
/// adicional en tests futuros.
class GoRouterConfig {
  GoRouterConfig._(this.router);

  factory GoRouterConfig.create() {
    return GoRouterConfig._(_buildRouter());
  }

  final GoRouter router;

  static GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: RoutePaths.home,
      debugLogDiagnostics: true,
      routes: <RouteBase>[
        // Shell con bottom navigation
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell shell,
          ) {
            return HomeShell(navigationShell: shell);
          },
          branches: <StatefulShellBranch>[
            // Tab 1: Chat
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePaths.home,
                  builder: (BuildContext context, GoRouterState state) =>
                      const ChatScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'conversation/:conversationId',
                      builder: (
                        BuildContext context,
                        GoRouterState state,
                      ) {
                        final String id =
                            state.pathParameters['conversationId']!;
                        return ChatScreen(conversationId: int.parse(id));
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Tab 2: Historial
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePaths.history,
                  builder: (BuildContext context, GoRouterState state) =>
                      const HistoryScreen(),
                ),
              ],
            ),
            // Tab 3: Favoritos
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePaths.favorites,
                  builder: (BuildContext context, GoRouterState state) =>
                      const FavoritesScreen(),
                ),
              ],
            ),
          ],
        ),

        // Pantallas fuera del shell (acceso desde drawer/menú)
        GoRoute(
          path: RoutePaths.reader,
          builder: (BuildContext context, GoRouterState state) =>
              const ReaderScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: ':bookNumber/:chapter',
              builder: (BuildContext context, GoRouterState state) {
                final String bookNumber =
                    state.pathParameters['bookNumber']!;
                final String chapter = state.pathParameters['chapter']!;
                return ReaderScreen(
                  bookNumber: int.tryParse(bookNumber) ?? 1,
                  chapter: int.tryParse(chapter) ?? 1,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: RoutePaths.settings,
          builder: (BuildContext context, GoRouterState state) =>
              const SettingsScreen(),
        ),
      ],
      errorBuilder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Ruta no encontrada: ${state.uri}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
