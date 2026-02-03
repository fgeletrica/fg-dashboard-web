import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0B0F1A);
  static const Color card = Color(0xFF121A2B);
  static const Color gold = Color(0xFFF7C948);
  static const Color muted = Color(0xFF9AA4B2);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      cardColor: card,

      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: gold,
        secondary: gold,
        surface: card,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      // Flutter recente usa CardThemeData
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: const TextStyle(color: muted),
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 1.2),
        ),
      ),
    );
  }
}
