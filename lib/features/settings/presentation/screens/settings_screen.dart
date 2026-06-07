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
import '../../../../core/services/logger.dart';
import '../../data/app_settings.dart';
import '../../data/data_portability_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppSettings> settingsAsync =
        ref.watch(appSettingsProvider);
    final AppSettings settings =
        settingsAsync.valueOrNull ?? AppSettings.defaults;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: <Widget>[
          const _SectionHeader(text: 'Apariencia'),
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_themeLabel(_themeModeString(settings.themeMode))),
            trailing: DropdownButton<String>(
              value: _themeModeString(settings.themeMode),
              onChanged: _busy ? null : _onThemeChanged,
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
              value: settings.fontScale,
              min: 0.8,
              max: 1.6,
              divisions: 8,
              label: settings.fontScale.toStringAsFixed(2),
              onChanged: _busy ? null : _onFontScaleChanged,
            ),
            trailing: Text('x${settings.fontScale.toStringAsFixed(2)}'),
          ),
          const Divider(),
          const _SectionHeader(text: 'Corpus bíblico'),
          ListTile(
            title: const Text('Traducción'),
            subtitle: Text(settings.bibleTranslation ?? 'Cargando…'),
          ),
          ListTile(
            title: const Text('Versión del corpus'),
            subtitle: Text(settings.assetsVersion ?? 'Desconocida'),
          ),
          const Divider(),
          const _SectionHeader(text: 'Datos del usuario'),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Exportar mis datos'),
            subtitle: const Text('Favoritos, conversaciones y ajustes (JSON).'),
            onTap: _busy ? null : _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Importar datos'),
            subtitle: const Text('Reemplaza los datos locales desde un JSON.'),
            onTap: _busy ? null : _importData,
          ),
          const Divider(),
          const _SectionHeader(text: 'Acerca de'),
          const ListTile(
            title: Text('Oración'),
            subtitle: Text('Versión 0.1.0+1'),
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

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  Future<void> _onThemeChanged(String? v) async {
    if (v == null) return;
    final AppDatabase db = ref.read(appDatabaseProvider);
    final AppLogger logger = ref.read(loggerProvider);
    try {
      await db.settingsDao.setValue(AppConstants.settingThemeMode, v);
    } catch (e, st) {
      logger.e('Error guardando tema', e, st);
    }
  }

  Future<void> _onFontScaleChanged(double v) async {
    final AppDatabase db = ref.read(appDatabaseProvider);
    final AppLogger logger = ref.read(loggerProvider);
    try {
      await db.settingsDao.setValue(
        AppConstants.settingFontScale,
        v.toStringAsFixed(2),
      );
    } catch (e, st) {
      logger.e('Error guardando font_scale', e, st);
    }
  }

  Future<void> _exportData() async {
    final AppLogger logger = ref.read(loggerProvider);
    final DataPortabilityRepository repo =
        ref.read(dataPortabilityRepositoryProvider);
    setState(() => _busy = true);
    try {
      final BackupPayload payload = await repo.exportAll();
      final String json = payload.encode();
      final Directory docs = await getApplicationDocumentsDirectory();
      final String ts = DateTime.now().millisecondsSinceEpoch.toString();
      final File out = File(p.join(docs.path, 'oracion_export_$ts.json'));
      await out.writeAsString(json, flush: true);
      logger.i('Export escrito: ${out.path} (${json.length} chars)');

      await Share.shareXFiles(
        <XFile>[XFile(out.path, mimeType: 'application/json')],
        text: 'Respaldo de Oración '
            '(${payload.favorites.length} favoritos, '
            '${payload.conversations.length} conversaciones)',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exportado: ${payload.favorites.length} favoritos, '
            '${payload.conversations.length} conversaciones',
          ),
        ),
      );
    } catch (e, st) {
      logger.e('Error exportando', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exportando: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData() async {
    final AppLogger logger = ref.read(loggerProvider);
    final DataPortabilityRepository repo =
        ref.read(dataPortabilityRepositoryProvider);
    setState(() => _busy = true);
    try {
      final FilePickerResult? res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );
      if (res == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final String? path = res.files.single.path;
      if (path == null) {
        if (!mounted) return;
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo acceder al archivo.')),
        );
        return;
      }

      final String raw = await File(path).readAsString();
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('JSON raíz debe ser un objeto.');
      }
      final BackupPayload payload = BackupPayload.fromJson(decoded);

      if (!mounted) {
        setState(() => _busy = false);
        return;
      }

      // Confirmación explícita: la importación es destructiva.
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext c) => AlertDialog(
          title: const Text('Importar datos'),
          content: Text(
            'Se reemplazarán tus datos locales con los del archivo:\n\n'
            '• ${payload.favorites.length} favoritos\n'
            '• ${payload.conversations.length} conversaciones\n'
            '• ${payload.messages.length} mensajes\n'
            '• ${payload.settings.length} ajustes\n\n'
            'Esta acción no se puede deshacer. ¿Continuar?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );
      if (ok != true) {
        if (mounted) setState(() => _busy = false);
        return;
      }

      final ImportResult result = await repo.importAll(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Importado: ${result.total} registros '
            '(${result.favorites} favs, ${result.conversations} convs, '
            '${result.messages} msgs)',
          ),
        ),
      );
    } catch (e, st) {
      logger.e('Error importando', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importando: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _themeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
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
