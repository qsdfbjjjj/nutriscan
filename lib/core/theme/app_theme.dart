import 'package:flutter/material.dart';

/// Темы Material 3: светлая и тёмная строятся из одного seed-цвета.
abstract final class AppTheme {
  static const Color seed = Color(0xFF2E7D32);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// Цвета оценок Nutri-Score (A — лучшая, E — худшая).
abstract final class NutriScoreColors {
  static Color of(String grade) => switch (grade) {
        'a' => const Color(0xFF038141),
        'b' => const Color(0xFF85BB2F),
        'c' => const Color(0xFFFECB02),
        'd' => const Color(0xFFEE8100),
        'e' => const Color(0xFFE63E11),
        _ => Colors.grey,
      };
}
