import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color brandRed = Color(0xFFE51D24);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandRed,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brandRed,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
