import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/favorites_dao.dart';
import '../../../../core/di/providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDatabase db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: StreamBuilder<List<FavoriteWithVerse>>(
        stream: db.favoritesDao.watchAllWithVerse(),
        builder: (BuildContext context,
            AsyncSnapshot<List<FavoriteWithVerse>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final List<FavoriteWithVerse> items = snap.data ?? <FavoriteWithVerse>[];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no tienes versículos favoritos.\n\n'
                  'Marca con estrella los versículos que desees recordar.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) {
              final FavoriteWithVerse item = items[i];
              return _FavoriteTile(item: item);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({required this.item});
  final FavoriteWithVerse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Verse v = item.verse;
    return ListTile(
      title: Text('${v.book} ${v.chapter}:${v.verse}'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(v.body, maxLines: 3, overflow: TextOverflow.ellipsis),
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Quitar de favoritos',
        onPressed: () async {
          final AppDatabase db = ref.read(appDatabaseProvider);
          await db.favoritesDao.removeById(item.favorite.id);
        },
      ),
    );
  }
}
