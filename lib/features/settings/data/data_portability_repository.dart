import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/logger.dart';

/// Payload de un backup de Oración.
///
/// Estructura estable (version 1) que el exportador emite y el
/// importador valida. Cualquier cambio incompatible requiere bumpear
/// el `version` y manejar migraciones.
class BackupPayload {
  const BackupPayload({
    required this.version,
    required this.exportedAt,
    required this.favorites,
    required this.conversations,
    required this.messages,
    required this.conversationContexts,
    required this.settings,
  });

  static const String appName = 'Oración';
  static const int currentVersion = 1;

  final int version;
  final DateTime exportedAt;
  final List<BackupFavorite> favorites;
  final List<BackupConversation> conversations;
  final List<BackupMessage> messages;
  final List<BackupConversationContext> conversationContexts;
  final List<BackupSetting> settings;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'app': appName,
        'version': version,
        'exported_at': exportedAt.toIso8601String(),
        'favorites': favorites.map((BackupFavorite f) => f.toJson()).toList(),
        'conversations':
            conversations.map((BackupConversation c) => c.toJson()).toList(),
        'messages': messages.map((BackupMessage m) => m.toJson()).toList(),
        'conversation_contexts': conversationContexts
            .map((BackupConversationContext c) => c.toJson())
            .toList(),
        'settings': settings.map((BackupSetting s) => s.toJson()).toList(),
      };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Valida y parsea un JSON como BackupPayload. Lanza [FormatException]
  /// si la estructura no es la esperada.
  static BackupPayload fromJson(Map<String, dynamic> json) {
    if (json['app'] != appName) {
      throw const FormatException(
        'El archivo no es un backup de Oración (app != "Oración").',
      );
    }
    final int? version = (json['version'] as num?)?.toInt();
    if (version == null || version != currentVersion) {
      throw FormatException(
        'Versión de backup no soportada: $version (esperado $currentVersion).',
      );
    }
    final DateTime? exportedAt = DateTime.tryParse(
      json['exported_at'] as String? ?? '',
    );
    if (exportedAt == null) {
      throw const FormatException('Falta "exported_at" o tiene formato inválido.');
    }

    List<T> parseList<T>(
      String key,
      T Function(Map<String, dynamic>) parse,
    ) {
      final dynamic raw = json[key];
      if (raw is! List) {
        throw FormatException('Sección "$key" no es una lista.');
      }
      return raw
          .map((dynamic e) {
            if (e is! Map<String, dynamic>) {
              throw FormatException('Elemento de "$key" no es un objeto.');
            }
            return parse(e);
          })
          .toList(growable: false);
    }

    return BackupPayload(
      version: version,
      exportedAt: exportedAt,
      favorites: parseList('favorites', BackupFavorite.fromJson),
      conversations:
          parseList('conversations', BackupConversation.fromJson),
      messages: parseList('messages', BackupMessage.fromJson),
      conversationContexts: parseList(
        'conversation_contexts',
        BackupConversationContext.fromJson,
      ),
      settings: parseList('settings', BackupSetting.fromJson),
    );
  }
}

class BackupFavorite {
  const BackupFavorite({
    required this.id,
    required this.verseId,
    required this.createdAt,
    this.note,
  });

  final int id;
  final int verseId;
  final DateTime createdAt;
  final String? note;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'verse_id': verseId,
        'created_at': createdAt.toIso8601String(),
        'note': note,
      };

  static BackupFavorite fromJson(Map<String, dynamic> json) {
    return BackupFavorite(
      id: (json['id'] as num).toInt(),
      verseId: (json['verse_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      note: json['note'] as String?,
    );
  }

  factory BackupFavorite.fromDrift(Favorite f) => BackupFavorite(
        id: f.id,
        verseId: f.verseId,
        createdAt: f.createdAt,
        note: f.note,
      );
}

class BackupConversation {
  const BackupConversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.title,
  });

  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? title;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'title': title,
      };

  static BackupConversation fromJson(Map<String, dynamic> json) {
    return BackupConversation(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      title: json['title'] as String?,
    );
  }

  factory BackupConversation.fromDrift(Conversation c) => BackupConversation(
        id: c.id,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        title: c.title,
      );
}

class BackupMessage {
  const BackupMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.verseId,
  });

  final int id;
  final int conversationId;
  final String role;
  final String content;
  final DateTime createdAt;
  final int? verseId;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'conversation_id': conversationId,
        'role': role,
        'content': content,
        'verse_id': verseId,
        'created_at': createdAt.toIso8601String(),
      };

  static BackupMessage fromJson(Map<String, dynamic> json) {
    return BackupMessage(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversation_id'] as num).toInt(),
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      verseId: (json['verse_id'] as num?)?.toInt(),
    );
  }

  factory BackupMessage.fromDrift(Message m) => BackupMessage(
        id: m.id,
        conversationId: m.conversationId,
        role: m.role,
        content: m.content,
        createdAt: m.createdAt,
        verseId: m.verseId,
      );
}

class BackupConversationContext {
  const BackupConversationContext({
    required this.conversationId,
    this.dominantEmotion,
    this.dominantIntent,
    this.topicTagsJson,
    this.shownVerseIdsJson,
    this.turnCount = 0,
  });

  final int conversationId;
  final String? dominantEmotion;
  final String? dominantIntent;
  final String? topicTagsJson;
  final String? shownVerseIdsJson;
  final int turnCount;

  Map<String, Object?> toJson() => <String, Object?>{
        'conversation_id': conversationId,
        'dominant_emotion': dominantEmotion,
        'dominant_intent': dominantIntent,
        'topic_tags_json': topicTagsJson,
        'shown_verse_ids_json': shownVerseIdsJson,
        'turn_count': turnCount,
      };

  static BackupConversationContext fromJson(Map<String, dynamic> json) {
    return BackupConversationContext(
      conversationId: (json['conversation_id'] as num).toInt(),
      dominantEmotion: json['dominant_emotion'] as String?,
      dominantIntent: json['dominant_intent'] as String?,
      topicTagsJson: json['topic_tags_json'] as String?,
      shownVerseIdsJson: json['shown_verse_ids_json'] as String?,
      turnCount: (json['turn_count'] as num?)?.toInt() ?? 0,
    );
  }

  factory BackupConversationContext.fromDrift(ConversationContextEntry c) =>
      BackupConversationContext(
        conversationId: c.conversationId,
        dominantEmotion: c.dominantEmotion,
        dominantIntent: c.dominantIntent,
        topicTagsJson: c.topicTagsJson,
        shownVerseIdsJson: c.shownVerseIdsJson,
        turnCount: c.turnCount,
      );
}

class BackupSetting {
  const BackupSetting({required this.key, required this.value});

  final String key;
  final String value;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'value': value,
      };

  static BackupSetting fromJson(Map<String, dynamic> json) {
    return BackupSetting(
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  factory BackupSetting.fromDrift(Setting s) =>
      BackupSetting(key: s.key, value: s.value);
}

/// Resultado de una operación de import.
class ImportResult {
  const ImportResult({
    required this.favorites,
    required this.conversations,
    required this.messages,
    required this.contexts,
    required this.settings,
  });

  final int favorites;
  final int conversations;
  final int messages;
  final int contexts;
  final int settings;

  int get total =>
      favorites + conversations + messages + contexts + settings;
}

/// Servicio de portabilidad de datos: exporta a JSON e importa desde
/// JSON con validación de schema y reemplazo transaccional.
///
/// Es la única capa que la pantalla de Configuración debe conocer
/// para "Exportar mis datos" e "Importar datos".
class DataPortabilityRepository {
  DataPortabilityRepository({
    required this.database,
    required this.logger,
  });

  final AppDatabase database;
  final AppLogger logger;

  /// Construye un [BackupPayload] con todo el estado mutable del usuario.
  Future<BackupPayload> exportAll() async {
    final List<Favorite> favs = await database.select(database.favorites).get();
    final List<Conversation> convs =
        await database.select(database.conversations).get();
    final List<Message> msgs = await database.select(database.messages).get();
    final List<ConversationContextEntry> ctxs =
        await database.select(database.conversationContexts).get();
    final List<Setting> sets = await database.select(database.settings).get();

    return BackupPayload(
      version: BackupPayload.currentVersion,
      exportedAt: DateTime.now(),
      favorites:
          favs.map(BackupFavorite.fromDrift).toList(growable: false),
      conversations:
          convs.map(BackupConversation.fromDrift).toList(growable: false),
      messages:
          msgs.map(BackupMessage.fromDrift).toList(growable: false),
      conversationContexts: ctxs
          .map(BackupConversationContext.fromDrift)
          .toList(growable: false),
      settings: sets.map(BackupSetting.fromDrift).toList(growable: false),
    );
  }

  /// Importa un [BackupPayload] en una transacción atómica.
  ///
  /// Comportamiento:
  /// - Reemplaza los datos del usuario (favoritos, conversaciones,
  ///   mensajes, contextos) por los del payload.
  /// - Para los settings, hace upsert PERO respeta los settings
  ///   protegidos (`assets_version`, `bible_translation`) que son
  ///   gestionados por `AssetLoader` y no deben alterarse desde un
  ///   backup externo.
  ///
  /// Si ocurre cualquier error, la transacción se revierte y la DB
  /// queda exactamente como estaba.
  Future<ImportResult> importAll(BackupPayload payload) async {
    if (payload.version != BackupPayload.currentVersion) {
      throw FormatException(
        'Versión de backup no soportada: ${payload.version} '
        '(esperado ${BackupPayload.currentVersion}).',
      );
    }
    logger.i(
      'Importando backup v${payload.version}: '
      '${payload.favorites.length} favs, ${payload.conversations.length} convs, '
      '${payload.messages.length} msgs, ${payload.settings.length} sets',
    );

    int fCount = 0;
    int cCount = 0;
    int mCount = 0;
    int ctxCount = 0;
    int sCount = 0;

    await database.transaction(() async {
      // 1) Borrar datos del usuario en orden (FK-safe).
      await database.delete(database.messages).go();
      await database.delete(database.conversationContexts).go();
      await database.delete(database.favorites).go();
      await database.delete(database.conversations).go();

      // 2) Reinsertar conversaciones (preservando IDs del payload).
      for (final BackupConversation c in payload.conversations) {
        await database.into(database.conversations).insert(
              ConversationsCompanion.insert(
                id: Value<int>(c.id),
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
                title: Value<String?>(c.title),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        cCount++;
      }

      // 3) Reinsertar mensajes.
      for (final BackupMessage m in payload.messages) {
        await database.into(database.messages).insert(
              MessagesCompanion.insert(
                id: Value<int>(m.id),
                conversationId: m.conversationId,
                role: m.role,
                content: m.content,
                createdAt: m.createdAt,
                verseId: Value<int?>(m.verseId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        mCount++;
      }

      // 4) Reinsertar contextos conversacionales.
      for (final BackupConversationContext cx in payload.conversationContexts) {
        await database.into(database.conversationContexts).insert(
              ConversationContextsCompanion.insert(
                conversationId: Value<int>(cx.conversationId),
                dominantEmotion: Value<String?>(cx.dominantEmotion),
                dominantIntent: Value<String?>(cx.dominantIntent),
                topicTagsJson: Value<String?>(cx.topicTagsJson),
                shownVerseIdsJson: Value<String?>(cx.shownVerseIdsJson),
                turnCount: Value<int>(cx.turnCount),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        ctxCount++;
      }

      // 5) Reinsertar favoritos.
      for (final BackupFavorite f in payload.favorites) {
        await database.into(database.favorites).insert(
              FavoritesCompanion.insert(
                id: Value<int>(f.id),
                verseId: f.verseId,
                createdAt: f.createdAt,
                note: Value<String?>(f.note),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        fCount++;
      }

      // 6) Upsert de settings, respetando los protegidos.
      const Set<String> protected = <String>{
        AppConstants.settingAssetsVersion,
        'bible_translation',
      };
      for (final BackupSetting s in payload.settings) {
        if (protected.contains(s.key)) continue;
        await database.into(database.settings).insertOnConflictUpdate(
              SettingsCompanion.insert(key: s.key, value: s.value),
            );
        sCount++;
      }
    });

    logger.i(
      'Import completado: '
      '$fCount favs, $cCount convs, $mCount msgs, $ctxCount ctxs, $sCount sets',
    );

    return ImportResult(
      favorites: fCount,
      conversations: cCount,
      messages: mCount,
      contexts: ctxCount,
      settings: sCount,
    );
  }
}
