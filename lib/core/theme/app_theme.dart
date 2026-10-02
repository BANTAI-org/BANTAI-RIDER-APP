import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color surface = Color(0xFFF6F6FA);
  static const Color muted = Color(0xFF858894);
  static const Color brandRed = Color(0xFFE51D24);
  static const Color fieldFill = Colors.white;
  static const Color fieldBorder = Color(0xFFD9D9DE);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandRed,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: brandRed, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
