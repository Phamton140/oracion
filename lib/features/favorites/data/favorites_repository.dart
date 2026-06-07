import '../../../core/database/daos/favorites_dao.dart';
import '../../../core/database/daos/usage_stats_dao.dart';
import '../../../core/services/logger.dart';

/// Repository que orquesta la lógica de favoritos:
///
/// - Mantiene la tabla `favorites` (a través de `FavoritesDao`).
/// - Actualiza los contadores en `usage_stats` (favoritesSaved, versesShared).
/// - Ofrece un stream reactivo de "es favorito" por versículo para que
///   la UI cambie el icono en tiempo real.
///
/// Es la única capa que la UI debe conocer para gestionar favoritos.
class FavoritesRepository {
  FavoritesRepository({
    required this.favoritesDao,
    required this.usageStatsDao,
    required this.logger,
  });

  final FavoritesDao favoritesDao;
  final UsageStatsDao usageStatsDao;
  final AppLogger logger;

  /// Alterna el estado de favorito de un versículo.
  ///
  /// - Si NO era favorito, lo añade (no-op si ya existía) e incrementa
  ///   el contador de `favoritesSaved`.
  /// - Si YA era favorito, lo elimina.
  ///
  /// Retorna `true` si el versículo quedó como favorito, `false` si
  /// se quitó.
  Future<bool> toggleFavorite(int verseId) async {
    final bool wasFavorite = await favoritesDao.isFavorite(verseId);
    if (wasFavorite) {
      await favoritesDao.removeByVerseId(verseId);
      logger.d('Favorito eliminado: verse=$verseId');
      return false;
    }
    await favoritesDao.addOrIgnore(verseId: verseId);
    await usageStatsDao.incrementFavorites();
    logger.d('Favorito añadido: verse=$verseId');
    return true;
  }

  /// Stream reactivo: ¿es favorito este versículo?
  ///
  /// La UI lo consume para alternar el icono entre `favorite_border` y
  /// `favorite` sin necesidad de un provider extra.
  Stream<bool> watchIsFavorite(int verseId) {
    return favoritesDao.isFavoriteStream(verseId);
  }

  /// Registra un evento de versículo compartido. Incrementa
  /// `versesShared` en el contador local.
  Future<void> trackShare(int verseId) async {
    await usageStatsDao.incrementShared();
    logger.d('Versículo compartido: verse=$verseId');
  }
}
