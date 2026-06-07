import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/di/providers.dart';
import 'core/routing/app_router.dart';
import 'features/settings/data/app_settings.dart';
import 'shared/theme/app_theme.dart';

class OracionApp extends ConsumerWidget {
  const OracionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouterConfig routerConfig = ref.watch(appRouterProvider);
    final AsyncValue<AppSettings> settingsAsync =
        ref.watch(appSettingsProvider);
    final AppSettings settings = settingsAsync.valueOrNull ?? AppSettings.defaults;

    return MaterialApp.router(
      title: 'Oración',
      debugShowCheckedModeBanner: false,

      // Tema reactivo: cambia inmediatamente al editar
      // Configuración -> Tema / Tamaño de letra.
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,

      // Router
      routerConfig: routerConfig.router,

      // Localización
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale(AppConstants.supportedLocaleCode),
      ],

      // Aplica el font_scale persistido en la DB a toda la UI.
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
