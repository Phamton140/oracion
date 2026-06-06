import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/di/providers.dart';
import 'core/routing/app_router.dart';
import 'shared/theme/app_theme.dart';

class OracionApp extends ConsumerWidget {
  const OracionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouterConfig routerConfig = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Oración',
      debugShowCheckedModeBanner: false,

      // Tema
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,

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

      // Builder envuelve en scroll behavior correcto
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
