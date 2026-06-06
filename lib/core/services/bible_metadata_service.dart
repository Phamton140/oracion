import '../database/daos/verses_dao.dart';
import 'logger.dart';

/// Alias de UI para un libro bíblico: el nombre fuente del corpus
/// (ej. "Revelación") puede mostrarse como "Apocalipsis" en la UI
/// con un subtítulo "Revelación".
class BookDisplay {
  const BookDisplay({
    required this.bookNumber,
    required this.sourceName,
    required this.displayName,
    required this.subtitle,
  });

  final int bookNumber;
  final String sourceName;
  final String displayName;
  final String subtitle;

  bool get hasAlias => sourceName != displayName;
}

/// Servicio que combina el `VersesDao` con los alias de display
/// declarados en el manifest. Usado por la UI para mostrar el nombre
/// "Apocalipsis" en lugar de "Revelación" (decisión de Sprint 2).
class BibleMetadataService {
  BibleMetadataService({
    required VersesDao versesDao,
    required AppLogger logger,
    Map<String, Map<String, String>>? bookAliases,
  })  // ignore: prefer_initializing_formals
      : _dao = versesDao,
        // ignore: unused_field
        _logger = logger,
        _aliases = bookAliases ?? _defaultAliases;

  final VersesDao _dao;
  // ignore: unused_field
  final AppLogger? _logger;
  final Map<String, Map<String, String>> _aliases;

  /// Aliases por defecto (deben coincidir con bible_assets.manifest.json).
  static const Map<String, Map<String, String>> _defaultAliases =
      <String, Map<String, String>>{
    'Revelación': <String, String>{
      'display_name': 'Apocalipsis',
      'subtitle': 'Revelación',
    },
  };

  /// Lee los 66 libros y los devuelve enriquecidos con alias de display.
  Future<List<BookDisplay>> listBooks() async {
    final List<BookSummary> raw = await _dao.listBooks();
    return raw
        .map((BookSummary b) {
          final Map<String, String>? alias = _aliases[b.name];
          return BookDisplay(
            bookNumber: b.bookNumber,
            sourceName: b.name,
            displayName: alias?['display_name'] ?? b.name,
            subtitle: alias?['subtitle'] ?? '',
          );
        })
        .toList();
  }

  /// Busca un BookDisplay por número. Retorna null si no existe.
  Future<BookDisplay?> bookByNumber(int bookNumber) async {
    final all = await listBooks();
    for (final b in all) {
      if (b.bookNumber == bookNumber) return b;
    }
    return null;
  }

  /// Conteo total de versículos por libro.
  Future<Map<int, int>> verseCountByBook() => _dao.verseCountByBook();
}
