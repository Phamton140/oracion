import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _themeMode = 'system';
  double _fontScale = 1.0;
  String? _bibleTranslation;
  String? _assetsVersion;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final AppDatabase db = ref.read(appDatabaseProvider);
    final String? theme = await db.settingsDao.getValue(AppConstants.settingThemeMode);
    final String? scale = await db.settingsDao.getValue(AppConstants.settingFontScale);
    final String? translation = await db.settingsDao.getValue('bible_translation');
    final String? av = await db.settingsDao.getValue(AppConstants.settingAssetsVersion);
    if (!mounted) return;
    setState(() {
      _themeMode = theme ?? 'system';
      _fontScale = double.tryParse(scale ?? '1.0') ?? 1.0;
      _bibleTranslation = translation;
      _assetsVersion = av;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: <Widget>[
          _SectionHeader(text: 'Apariencia'),
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_themeLabel(_themeMode)),
            trailing: DropdownButton<String>(
              value: _themeMode,
              onChanged: (String? v) async {
                if (v == null) return;
                setState(() => _themeMode = v);
                final AppDatabase db = ref.read(appDatabaseProvider);
                await db.settingsDao.setValue(AppConstants.settingThemeMode, v);
              },
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'system', child: Text('Sistema')),
                DropdownMenuItem<String>(value: 'light', child: Text('Claro')),
                DropdownMenuItem<String>(value: 'dark', child: Text('Oscuro')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Tamaño de letra'),
            subtitle: Slider(
              value: _fontScale,
              min: 0.8,
              max: 1.6,
              divisions: 8,
              label: _fontScale.toStringAsFixed(2),
              onChanged: (double v) async {
                setState(() => _fontScale = v);
                final AppDatabase db = ref.read(appDatabaseProvider);
                await db.settingsDao.setValue(
                  AppConstants.settingFontScale,
                  v.toStringAsFixed(2),
                );
              },
            ),
            trailing: Text('x${_fontScale.toStringAsFixed(2)}'),
          ),
          const Divider(),
          _SectionHeader(text: 'Corpus bíblico'),
          ListTile(
            title: const Text('Traducción'),
            subtitle: Text(_bibleTranslation ?? 'Cargando…'),
          ),
          ListTile(
            title: const Text('Versión del corpus'),
            subtitle: Text(_assetsVersion ?? 'Desconocida'),
          ),
          const Divider(),
          _SectionHeader(text: 'Datos del usuario'),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Exportar mis datos'),
            subtitle: const Text('Favoritos, conversaciones y ajustes (JSON).'),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Importar datos'),
            subtitle: const Text('Reemplaza los datos locales desde un JSON.'),
            onTap: _importData,
          ),
          const Divider(),
          _SectionHeader(text: 'Acerca de'),
          const ListTile(
            title: Text('Oración'),
            subtitle: Text('Versión 0.1.0+1 — Sprint 2'),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Principio: Oración no responde al usuario. '
              'Oración encuentra y presenta pasajes bíblicos relevantes. '
              'Toda respuesta visible proviene de la Biblia.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Oscuro';
      default:
        return 'Sistema';
    }
  }

  Future<void> _exportData() async {
    try {
      final AppDatabase db = ref.read(appDatabaseProvider);
      final List<Favorite> favs = await db.select(db.favorites).get();
      final List<Conversation> convs = await db.select(db.conversations).get();
      final List<Message> msgs = await db.select(db.messages).get();
      final List<ConversationContextEntry> ctxs =
          await db.select(db.conversationContexts).get();
      final List<Setting> sets = await db.select(db.settings).get();

      final Map<String, dynamic> payload = <String, dynamic>{
        'app': 'Oración',
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'favorites': favs
            .map((Favorite f) => <String, Object?>{
                  'id': f.id,
                  'verse_id': f.verseId,
                  'created_at': f.createdAt.toIso8601String(),
                  'note': f.note,
                })
            .toList(),
        'conversations': convs
            .map((Conversation c) => <String, Object?>{
                  'id': c.id,
                  'created_at': c.createdAt.toIso8601String(),
                  'updated_at': c.updatedAt.toIso8601String(),
                  'title': c.title,
                })
            .toList(),
        'messages': msgs
            .map((Message m) => <String, Object?>{
                  'id': m.id,
                  'conversation_id': m.conversationId,
                  'role': m.role,
                  'content': m.content,
                  'verse_id': m.verseId,
                  'created_at': m.createdAt.toIso8601String(),
                })
            .toList(),
        'conversation_contexts': ctxs
            .map((ConversationContextEntry c) => <String, Object?>{
                  'conversation_id': c.conversationId,
                  'dominant_emotion': c.dominantEmotion,
                  'dominant_intent': c.dominantIntent,
                  'topic_tags_json': c.topicTagsJson,
                  'shown_verse_ids_json': c.shownVerseIdsJson,
                  'turn_count': c.turnCount,
                })
            .toList(),
        'settings': sets
            .map((Setting s) => <String, String>{'key': s.key, 'value': s.value})
            .toList(),
      };

      final Directory docs = await getApplicationDocumentsDirectory();
      final String ts = DateTime.now().millisecondsSinceEpoch.toString();
      final File out = File(p.join(docs.path, 'oracion_export_$ts.json'));
      await out.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));

      // Compartir
      await Share.shareXFiles(
        <XFile>[XFile(out.path)],
        text:
            'Respaldo de Oración (${favs.length} favoritos, ${convs.length} conversaciones)',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exportado a ${out.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exportando: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      final FilePickerResult? res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );
      if (res == null) return;
      final String path = res.files.single.path!;
      final String raw = await File(path).readAsString();
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('JSON raíz debe ser un objeto.');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Importación: validación pendiente. Solo lectura.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importando: $e')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
