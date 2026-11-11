import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const navy = Color(0xff142d39);
  static const teal = Color(0xff087e79);
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xfff4f7f8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: navy,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xffe5ecee)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffdce5e7)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
