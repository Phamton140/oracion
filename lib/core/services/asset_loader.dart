import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import 'logger.dart';

/// Metadata del asset bíblico embebido en el APK.
class BibleAssetManifest {
  const BibleAssetManifest({
    required this.assetPath,
    required this.version,
    required this.translation,
    required this.verseCount,
    required this.bookCount,
    required this.verseTagCount,
  });

  final String assetPath;
  final int version;
  final String translation;
  final int verseCount;
  final int bookCount;
  final int verseTagCount;

  factory BibleAssetManifest.fromJson(
    Map<String, dynamic> json, {
    required String assetPath,
  }) {
    return BibleAssetManifest(
      assetPath: assetPath,
      version: (json['version'] as num).toInt(),
      translation: json['translation'] as String,
      verseCount: (json['verse_count'] as num).toInt(),
      bookCount: (json['book_count'] as num).toInt(),
      verseTagCount: (json['verse_tag_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Carga el corpus bíblico pre-poblado (asset) en la base local
/// de Drift (`oracion_db`) la primera vez que se abre la app (o cuando
/// se actualiza la versión del asset).
///
/// Flujo:
/// 1. Lee el manifest JSON del asset (versión, conteos, sha256).
/// 2. Compara con `bible_assets_version` en settings.
/// 3. Si difieren: extrae el DB asset a documents, lo abre read-only con
///    sqlite3, copia verses y verse_tags al drift DB en una transacción.
/// 4. Actualiza el setting `bible_assets_version`.
///
/// El corpus se guarda en `getApplicationDocumentsDirectory()/bible_assets/`
/// para evitar re-extracciones innecesarias del APK en cada arranque.
class AssetLoader {
  AssetLoader({
    required AppDatabase database,
    required AppLogger logger,
    String assetDbPath = 'assets/bible/bible_assets.db',
    String manifestJsonPath = 'assets/bible/bible_assets.manifest.json',
  }) : _db = database,
       _log = logger,
       _assetDbPath = assetDbPath,
       _manifestJsonPath = manifestJsonPath;

  final AppDatabase _db;
  final AppLogger _log;
  final String _assetDbPath;
  final String _manifestJsonPath;

  /// Devuelve la versión del asset actualmente embebido.
  Future<BibleAssetManifest> loadManifest() async {
    final String raw = await rootBundle.loadString(_manifestJsonPath);
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return BibleAssetManifest.fromJson(json, assetPath: _assetDbPath);
  }

  /// Asegura que el corpus bíblico está cargado en el drift DB.
  /// Idempotente: si la versión ya coincide, no hace nada.
  ///
  /// Retorna `true` si se hizo un seed nuevo, `false` si ya estaba cargado.
  Future<bool> ensureBibleSeeded() async {
    final BibleAssetManifest manifest = await loadManifest();
    final String currentVersion =
        await _getSetting(AppConstants.settingAssetsVersion) ?? '0';
    if (currentVersion == manifest.version.toString()) {
      _log.i('Bible asset v${manifest.version} ya cargado. Skip seed.');
      return false;
    }

    _log.i(
      'Bible asset v$currentVersion -> v${manifest.version}. Seeding...',
    );
    final Stopwatch sw = Stopwatch()..start();

    final String extractedPath = await _extractAssetToDocuments();
    _log.d(
      '  Asset extraído a $extractedPath '
      '(${await File(extractedPath).length()} bytes).',
    );

    await _copyFromAsset(extractedPath);

    await _setSetting(AppConstants.settingAssetsVersion, manifest.version.toString());
    await _setSetting('bible_translation', manifest.translation);

    sw.stop();
    _log.i(
      'Seed completado en ${sw.elapsedMilliseconds}ms. '
      '${manifest.verseCount} versículos, ${manifest.verseTagCount} tags.',
    );
    return true;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<String> _extractAssetToDocuments() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory dir = Directory(p.join(docs.path, 'bible_assets'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final String outPath = p.join(dir.path, 'bible_assets.db');
    final ByteData data = await rootBundle.load(_assetDbPath);
    final File outFile = File(outPath);
    await outFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    return outPath;
  }

  Future<void> _copyFromAsset(String assetPath) async {
    final Sqlite3 sqlite = sqlite3;
    final Database src = sqlite.open(
      assetPath,
      mode: OpenMode.readOnly,
    );
    try {
      await _copyVerses(src);
      await _copyVerseTags(src);
    } finally {
      src.close();
    }
  }

  Future<void> _copyVerses(Database src) async {
    final ResultSet rows = src.select(
      'SELECT book, book_number, chapter, verse, body FROM verses ORDER BY id',
    );
    final int total = rows.length;
    _log.d('  Copiando $total versículos...');

    const int batchSize = 500;
    final List<Map<String, Object?>> batch = <Map<String, Object?>>[];
    int processed = 0;
    final Stopwatch sw = Stopwatch()..start();

    await _db.transaction(() async {
      for (final Row row in rows) {
        batch.add(<String, Object?>{
          'book': row['book'] as String,
          'book_number': row['book_number'] as int,
          'chapter': row['chapter'] as int,
          'verse': row['verse'] as int,
          'body': row['body'] as String,
          'translation': AppConstants.defaultTranslation,
        });
        if (batch.length >= batchSize) {
          await _flushVerseBatch(batch);
          processed += batch.length;
          batch.clear();
        }
      }
      if (batch.isNotEmpty) {
        await _flushVerseBatch(batch);
        processed += batch.length;
      }
    });

    sw.stop();
    _log.d('  $processed versículos copiados en ${sw.elapsedMilliseconds}ms.');
  }

  Future<void> _flushVerseBatch(List<Map<String, Object?>> batch) async {
    await _db.batch((Batch b) {
      for (final Map<String, Object?> v in batch) {
        b.insert(
          _db.verses,
          VersesCompanion.insert(
            book: v['book'] as String,
            bookNumber: v['book_number'] as int,
            chapter: v['chapter'] as int,
            verse: v['verse'] as int,
            body: v['body'] as String,
            translation: Value<String>(
              v['translation'] as String? ?? AppConstants.defaultTranslation,
            ),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _copyVerseTags(Database src) async {
    // Los verse_id del asset coinciden con los del drift DB porque
    // ambos se insertan en el mismo orden (ver build_bible_db.py).
    final ResultSet rows = src.select(
      'SELECT verse_id, tag, weight FROM verse_tags ORDER BY id',
    );
    final int total = rows.length;
    _log.d('  Copiando $total verse_tags...');

    const int batchSize = 1000;
    final List<({int verseId, String tag, double weight})> batch =
        <({int verseId, String tag, double weight})>[];
    int processed = 0;
    final Stopwatch sw = Stopwatch()..start();

    await _db.transaction(() async {
      for (final Row row in rows) {
        batch.add((
          verseId: row['verse_id'] as int,
          tag: row['tag'] as String,
          weight: (row['weight'] as num).toDouble(),
        ));
        if (batch.length >= batchSize) {
          await _flushVerseTagBatch(batch);
          processed += batch.length;
          batch.clear();
        }
      }
      if (batch.isNotEmpty) {
        await _flushVerseTagBatch(batch);
        processed += batch.length;
      }
    });

    sw.stop();
    _log.d('  $processed tags copiados en ${sw.elapsedMilliseconds}ms.');
  }

  Future<void> _flushVerseTagBatch(
    List<({int verseId, String tag, double weight})> batch,
  ) async {
    await _db.batch((Batch b) {
      for (final ({int verseId, String tag, double weight}) t in batch) {
        b.insert(
          _db.verseTags,
          VerseTagsCompanion.insert(
            verseId: t.verseId,
            tag: t.tag,
            weight: Value<double>(t.weight),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<String?> _getSetting(String key) async {
    final query = _db.select(_db.settings)..where((s) => s.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> _setSetting(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }
}
