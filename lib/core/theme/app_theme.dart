import 'package:flutter/material.dart';

/// Design tokens from design-system/re-mind/MASTER.md.
abstract final class AppColors {
  static const primary = Color(0xFF0D9488);
  static const secondary = Color(0xFF14B8A6);
  static const accent = Color(0xFFEA580C);
  static const destructive = Color(0xFFDC2626);
  static const backgroundLight = Color(0xFFF0FDFA);
  static const backgroundDark = Color(0xFF0C1615);
}

abstract final class AppTheme {
  static const fontFamily = 'Plus Jakarta Sans';

  static ThemeData get light => _base(Brightness.light);

  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      secondary: AppColors.secondary,
      error: AppColors.destructive,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      fontFamily: AppTheme.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(52, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
