import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual de Oración.
///
/// Paleta inspirada en manuscritos antiguos: marrones cálidos,
/// dorados tenues, tonos pergamino. Tipografía serif (Lora) para
/// versículos y sans-serif (Inter) para la UI.
class AppTheme {
  const AppTheme._();

  // Deshabilitar descarga de fuentes en runtime. La app es 100% offline.
  // Si las fuentes no están bundleadas, se usará la tipografía del sistema.
  static bool get _disableGoogleFontsFetching =>
      !_runtimeFetchingEnabled;

  // Flag para habilitar descarga. Por defecto: deshabilitado en MVP.
  // Sprint 2 empaquetará los .ttf de Lora e Inter en assets/fonts/.
  static const bool _runtimeFetchingEnabled = false;

  // Colores semilla
  static const Color _seedColor = Color(0xFF5B4636); // marrón cálido
  static const Color _accent = Color(0xFFB08D57); // dorado tenue

  // Colores light específicos
  static const Color _lightBackground = Color(0xFFFAF7F2); // pergamino
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightOnSurface = Color(0xFF1F1B16);

  // Colores dark específicos
  static const Color _darkBackground = Color(0xFF1A1612);
  static const Color _darkSurface = Color(0xFF2A2520);
  static const Color _darkOnSurface = Color(0xFFE8E2D8);

  /// Tema claro.
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: _seedColor,
      secondary: _accent,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
    );

    return _build(scheme, _lightBackground);
  }

  /// Tema oscuro.
  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: _lighten(_seedColor, 0.15),
      secondary: _lighten(_accent, 0.10),
      surface: _darkSurface,
      onSurface: _darkOnSurface,
    );

    return _build(scheme, _darkBackground);
  }

  static ThemeData _build(ColorScheme scheme, Color background) {
    final TextTheme baseText = scheme.brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    // Tipografía base: Inter (sans-serif moderna) para UI.
    // Si fetching está deshabilitado, GoogleFonts hace fallback a la
    // fuente del sistema, manteniendo la app 100% offline.
    final TextTheme uiText = _disableGoogleFontsFetching
        ? baseText
        : GoogleFonts.interTextTheme(baseText);

    // Tipografía display/headline: Lora (serif elegante) para
    // versículos y títulos destacados.
    final TextTheme displayText = _disableGoogleFontsFetching
        ? ThemeData(brightness: scheme.brightness).textTheme
        : GoogleFonts.loraTextTheme(
            ThemeData(brightness: scheme.brightness).textTheme,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,

      // Combinar UI + display.
      textTheme: uiText.copyWith(
        displayLarge: displayText.displayLarge,
        displayMedium: displayText.displayMedium,
        displaySmall: displayText.displaySmall,
        headlineLarge: displayText.headlineLarge,
        headlineMedium: displayText.headlineMedium,
        headlineSmall: displayText.headlineSmall,
        titleLarge: displayText.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: _disableGoogleFontsFetching
            ? TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              )
            : GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
      ),

      // Tarjetas
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        color: scheme.surface,
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _disableGoogleFontsFetching
              ? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
              : GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ),

      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: _disableGoogleFontsFetching
              ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
              : GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      // NavigationBar (bottom tabs)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          _disableGoogleFontsFetching
              ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)
              : GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: scheme.primary, size: 26);
            }
            return IconThemeData(
              color: scheme.onSurfaceVariant,
              size: 24,
            );
          },
        ),
        height: 68,
      ),

      // Divisor
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 0.5,
        space: 0,
      ),

      // Diálogos
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: scheme.surface,
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Aclara un color mezclándolo con blanco.
  static Color _lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(color, Colors.white, amount) ?? color;
  }
}
