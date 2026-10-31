import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Светлая и тёмная темы Material 3 с общим сидом.
abstract final class AppTheme {
  static ThemeData light() => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.petrol,
          brightness: Brightness.light,
        ),
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        outline: AppColors.lightOutline,
        card: AppColors.lightSurface,
      );

  static ThemeData dark() => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.petrol,
          brightness: Brightness.dark,
        ),
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        outline: AppColors.darkOutline,
        card: AppColors.darkSurfaceCard,
      );

  static ThemeData _build(
    ColorScheme scheme, {
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color outline,
    required Color card,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        surface: surface,
        onSurface: onSurface,
        outline: outline,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: outline.withValues(alpha: 0.4)),
    );
  }
}
