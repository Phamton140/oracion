import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/bible_metadata_service.dart';

/// Pantalla del Lector bíblico.
///
/// Modos:
/// - Sin argumentos: muestra la lista de los 66 libros.
/// - Con `bookNumber` y `chapter`: muestra los versículos del capítulo.
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({
    super.key,
    this.bookNumber,
    this.chapter,
  });

  final int? bookNumber;
  final int? chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lector bíblico'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: (bookNumber == null || chapter == null)
          ? const _BookListView()
          : _ChapterView(
              bookNumber: bookNumber!,
              chapter: chapter!,
            ),
    );
  }
}

class _BookListView extends ConsumerWidget {
  const _BookListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BibleMetadataService meta = ref.watch(bibleMetadataProvider);
    return FutureBuilder<List<BookDisplay>>(
      future: meta.listBooks(),
      builder: (BuildContext context, AsyncSnapshot<List<BookDisplay>> snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final List<BookDisplay> books = snap.data ?? <BookDisplay>[];
        return ListView.separated(
          itemCount: books.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int i) {
            final BookDisplay b = books[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${b.bookNumber}')),
              title: Text(b.displayName),
              subtitle: b.hasAlias ? Text(b.subtitle) : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/reader/${b.bookNumber}/1'),
            );
          },
        );
      },
    );
  }
}

class _ChapterView extends ConsumerWidget {
  const _ChapterView({required this.bookNumber, required this.chapter});

  final int bookNumber;
  final int chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDatabase db = ref.watch(appDatabaseProvider);
    final BibleMetadataService meta = ref.watch(bibleMetadataProvider);
    return FutureBuilder<({BookDisplay? book, List<Verse> verses, int chapterCount})>(
      future: () async {
        final BookDisplay? b = await meta.bookByNumber(bookNumber);
        final List<Verse> vs = await db.versesDao.byChapter(bookNumber, chapter);
        final int cc = await db.versesDao.chapterCountFor(bookNumber);
        return (book: b, verses: vs, chapterCount: cc);
      }(),
      builder: (BuildContext context,
          AsyncSnapshot<({BookDisplay? book, List<Verse> verses, int chapterCount})>
              snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final BookDisplay? b = snap.data?.book;
        final List<Verse> verses = snap.data?.verses ?? <Verse>[];
        final int cc = snap.data?.chapterCount ?? 1;
        if (verses.isEmpty) {
          return const Center(child: Text('Capítulo no encontrado.'));
        }
        return Column(
          children: <Widget>[
            if (b != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${b.displayName} $chapter',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('de $cc',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: verses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int i) {
                  final Verse v = verses[i];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'v${v.verse}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: Colors.brown),
                          ),
                          const SizedBox(height: 4),
                          Text(v.body, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
