import 'package:flutter/material.dart';

/// Central place for all app colors so you don't scatter hex codes everywhere.
class AppColors {
  // Brand colors sampled from the logo
  static const Color primaryNavy = Color(0xFF0B3C5D);
  static const Color accentBlue = Color(0xFF2D8CFF);
  static const Color lightBackground = Color(0xFFD7ECFF);

  // Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

/// AppTheme exposes ready-made light and dark ThemeData.
class AppTheme {
  /// Light theme: default for most users.
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentBlue,
        primary: AppColors.primaryNavy,
        brightness: Brightness.light,
      ),
      // Global body font
      fontFamily: 'Nunito',
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontFamily: 'Baloo2',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.primaryNavy,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primaryNavy,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: AppColors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: _buildTextTheme(base.textTheme, isDark: false),
    );
  }

  /// Dark theme: keeps the same brand feeling but on dark surfaces.
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentBlue,
        primary: AppColors.accentBlue,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Nunito',
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF050810),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontFamily: 'Baloo2',
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: const Color(0xFF111827),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: _buildTextTheme(base.textTheme, isDark: true),
    );
  }

  /// Builds a text theme that uses:
  /// - Baloo2 for headings / display
  /// - Nunito for body, labels, etc.
  static TextTheme _buildTextTheme(TextTheme base, {required bool isDark}) {
    final headingColor =
    isDark ? AppColors.white : AppColors.primaryNavy;

    return base.copyWith(
      // Big screens / page titles
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: 0.2,
        color: headingColor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w700,
        fontSize: 26,
        color: headingColor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: headingColor,
      ),

      // Body text
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Nunito',
        fontSize: 16,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Nunito',
        fontSize: 14,
        height: 1.4,
      ),

      // Captions / small labels
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: 'Nunito',
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
