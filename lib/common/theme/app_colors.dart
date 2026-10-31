import 'package:flutter/material.dart';

/// Палитра приложения: «научный» глубокий петроль + янтарный акцент.
/// Нарочно другая по сравнению с референсным покедексом.
abstract final class AppColors {
  // Фирменные цвета.
  static const Color petrol = Color(0xFF0B5C63);
  static const Color petrolDeep = Color(0xFF084349);
  static const Color oceanBlue = Color(0xFF1F6FA8);
  static const Color amber = Color(0xFFF2A541);
  static const Color coral = Color(0xFFE2604A);

  // Светлая тема.
  static const Color lightBackground = Color(0xFFF4F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF17282B);
  static const Color lightOutline = Color(0xFFC4D3D6);

  // Тёмная тема.
  static const Color darkBackground = Color(0xFF0D1517);
  static const Color darkSurface = Color(0xFF152023);
  static const Color darkSurfaceCard = Color(0xFF1B282C);
  static const Color darkOnSurface = Color(0xFFDCE9EB);
  static const Color darkOutline = Color(0xFF3A4E52);

  /// Цвет чипа для крупной категории ресурса DataCite.
  static Color resourceType(String? typeGeneral) => switch (typeGeneral) {
        'Dataset' => petrol,
        'JournalArticle' => oceanBlue,
        'Software' => const Color(0xFF7C5CBF),
        'Preprint' => amber,
        'PhysicalObject' => const Color(0xFF5B8C5A),
        _ => const Color(0xFF607D8B),
      };

  /// Иконка для крупной категории ресурса DataCite.
  static IconData resourceTypeIcon(String? typeGeneral) => switch (typeGeneral) {
        'Dataset' => Icons.storage_outlined,
        'JournalArticle' => Icons.article_outlined,
        'Software' => Icons.terminal_outlined,
        'Preprint' => Icons.description_outlined,
        'PhysicalObject' => Icons.science_outlined,
        _ => Icons.category_outlined,
      };

  /// Цвет «бейджа» состояния метаданных.
  static Color stateBadge(String? state) => switch (state) {
        'findable' => const Color(0xFF2E7D32),
        'registered' => oceanBlue,
        'draft' => amber,
        _ => const Color(0xFF607D8B),
      };
}
