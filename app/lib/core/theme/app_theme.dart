import 'package:flutter/material.dart';

import 'app_fonts.dart';

class AppPalette {
  const AppPalette({
    required this.dark,
    required this.canvas,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.raisedStart,
    required this.raisedEnd,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderSubtle,
    required this.divider,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final bool dark;
  final Color canvas;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color raisedStart;
  final Color raisedEnd;
  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderSubtle;
  final Color divider;
  final Color success;
  final Color warning;
  final Color danger;

  bool get isDark => dark;

  List<BoxShadow> get raisedShadow => isDark
      ? const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color(0x0DFFFFFF),
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ];

  List<BoxShadow> get primaryGlow => isDark
      ? [
          BoxShadow(
            color: primary.withValues(alpha: 0.38),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ]
      : [
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];

  static const darkPalette = AppPalette(
    dark: true,
    canvas: Color(0xFF1B1D21),
    surface1: Color(0xFF2A2D34),
    surface2: Color(0xFF23262B),
    surface3: Color(0xFF32363D),
    raisedStart: Color(0xFF2E3138),
    raisedEnd: Color(0xFF26292F),
    primary: Color(0xFF0A6CFF),
    primaryHover: Color(0xFF2D82FF),
    primaryPressed: Color(0xFF0857CF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9A9EA7),
    textMuted: Color(0xFF62666F),
    borderSubtle: Color(0x14FFFFFF),
    divider: Color(0x12FFFFFF),
    success: Color(0xFF2ECC8F),
    warning: Color(0xFFF5B544),
    danger: Color(0xFFFF5A6A),
  );

  static const lightPalette = AppPalette(
    dark: false,
    canvas: Color(0xFFF3F5F8),
    surface1: Color(0xFFFFFFFF),
    surface2: Color(0xFFE9EDF2),
    surface3: Color(0xFFDDE3EA),
    raisedStart: Color(0xFFFFFFFF),
    raisedEnd: Color(0xFFF7F9FC),
    primary: Color(0xFF0A6CFF),
    primaryHover: Color(0xFF2D82FF),
    primaryPressed: Color(0xFF0857CF),
    textPrimary: Color(0xFF171A1F),
    textSecondary: Color(0xFF5D636D),
    textMuted: Color(0xFF8B919A),
    borderSubtle: Color(0x14000000),
    divider: Color(0x0F000000),
    success: Color(0xFF16A36B),
    warning: Color(0xFFB7791F),
    danger: Color(0xFFD92D3A),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkPalette
      : lightPalette;
}

abstract final class AppRadius {
  static const card = 28.0;
  static const field = 20.0;
  static const row = 16.0;
  static const pill = 999.0;
}

abstract final class AppSpacing {
  static const page = 16.0;
  static const section = 20.0;
  static const gap = 8.0;
}

abstract final class AppTheme {
  static ThemeData light() => _theme(AppPalette.lightPalette);

  static ThemeData dark() => _theme(AppPalette.darkPalette);

  static ThemeData _theme(AppPalette palette) {
    final brightness = palette.isDark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: Colors.white,
      secondary: palette.primary,
      onSecondary: Colors.white,
      error: palette.danger,
      onError: Colors.white,
      surface: palette.canvas,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.surface1,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.borderSubtle,
      outlineVariant: palette.divider,
    );
    final textTheme = _textTheme(palette);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppFonts.latin,
      fontFamilyFallback: AppFonts.japaneseFallback,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      cardColor: palette.surface1,
      dividerColor: palette.divider,
      primaryColor: palette.primary,
      hintColor: palette.textMuted,
      splashColor: palette.primary.withValues(alpha: 0.12),
      highlightColor: palette.primary.withValues(alpha: 0.08),
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      iconTheme: IconThemeData(color: palette.textSecondary, size: 22),
      listTileTheme: ListTileThemeData(
        textColor: palette.textPrimary,
        iconColor: palette.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.row),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return palette.surface3;
            if (states.contains(WidgetState.pressed)) {
              return palette.primaryPressed;
            }
            return palette.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return palette.textMuted;
            return Colors.white;
          }),
          overlayColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: 0.12),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.surface2;
            }
            return palette.surface3;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return palette.textMuted;
            return palette.textPrimary;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: palette.borderSubtle)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return palette.textMuted;
            return palette.primary;
          }),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(palette.textPrimary),
          overlayColor: WidgetStatePropertyAll(
            palette.primary.withValues(alpha: 0.12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: palette.surface2,
        hintStyle: TextStyle(color: palette.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
        floatingLabelStyle: TextStyle(color: palette.primary, fontSize: 13),
        counterStyle: TextStyle(color: palette.textMuted, fontSize: 11),
        prefixIconColor: palette.textSecondary,
        suffixIconColor: palette.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: palette.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: palette.danger, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface3,
        selectedColor: palette.primary,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        side: BorderSide(color: palette.borderSubtle),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return palette.textMuted;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return palette.surface2;
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.surface3;
        }),
        trackOutlineColor: WidgetStatePropertyAll(palette.borderSubtle),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return palette.textPrimary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return palette.primary;
            return palette.surface3;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: palette.borderSubtle)),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(fontSize: 13),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.surface2,
        circularTrackColor: palette.surface2,
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surface3,
        contentTextStyle: TextStyle(color: palette.textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.row),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface1,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(AppPalette palette) {
    final base = TextTheme(
      displayLarge: const TextStyle(
        fontSize: 52,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      displayMedium: const TextStyle(
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displaySmall: const TextStyle(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineLarge: const TextStyle(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: const TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineSmall: const TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
    );
    return base
        .apply(
          fontFamily: AppFonts.latin,
          fontFamilyFallback: AppFonts.japaneseFallback,
          bodyColor: palette.textPrimary,
          displayColor: palette.textPrimary,
        )
        .copyWith(
          bodySmall: base.bodySmall?.copyWith(color: palette.textSecondary),
          labelMedium: base.labelMedium?.copyWith(color: palette.textSecondary),
          labelSmall: base.labelSmall?.copyWith(color: palette.textMuted),
        );
  }
}
