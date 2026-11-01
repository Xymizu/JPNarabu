import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF1C1C1C);
  static const inkSoft = Color(0xFF2A2A2A);
  static const paper = Color(0xFFF7F6F8);
  static const white = Color(0xFFFFFFFF);
  static const sun = Color(0xFFF8E198);
  static const sky = Color(0xFFBAE6EE);
  static const periwinkle = Color(0xFFB9C7F1);
  static const muted = Color(0xFF6B6B70);
  static const hairline = Color(0xFFC9D1EE);
  static const alert = Color(0xFFE5484D);
  static const memorized = Color(0xFF2E7D32);
  static const difficult = Color(0xFFC62828);
}

abstract final class AppTheme {
  static ThemeData light() => _theme(
    brightness: Brightness.light,
    background: AppColors.paper,
    foreground: AppColors.ink,
  );

  static ThemeData dark() => _theme(
    brightness: Brightness.dark,
    background: AppColors.ink,
    foreground: AppColors.white,
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color foreground,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.periwinkle,
      brightness: brightness,
      surface: background,
      onSurface: foreground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: foreground,
          fontSize: 72,
          height: 1,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.44,
        ),
        headlineLarge: TextStyle(
          color: foreground,
          fontSize: 36,
          height: 1.11,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.36,
        ),
        headlineSmall: TextStyle(
          color: foreground,
          fontSize: 28,
          height: 1.14,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: foreground,
          fontSize: 17,
          height: 1.29,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: foreground, fontSize: 15, height: 1.33),
        bodyMedium: TextStyle(color: foreground, fontSize: 14, height: 1.43),
        labelSmall: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.23,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const StadiumBorder(),
          backgroundColor: brightness == Brightness.dark
              ? AppColors.white
              : AppColors.ink,
          foregroundColor: brightness == Brightness.dark
              ? AppColors.ink
              : AppColors.white,
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}
