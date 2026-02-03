import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF111827);
  static const Color border = Color(0xFF1F2937);
  static const Color gold = Color(0xFFF6C343);
  static const Color muted = Color(0xFF9CA3AF);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: gold,
        secondary: gold,
        surface: card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: muted),
        labelStyle: TextStyle(color: muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: gold),
        ),
      ),
    );
  }
}
