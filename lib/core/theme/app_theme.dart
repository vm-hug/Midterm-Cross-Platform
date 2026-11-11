import 'package:flutter/material.dart';

abstract final class AppTheme {
  // Bảng màu người dùng gợi ý
  static const cyanLight = Color(0xff99ffff);
  static const cyanBright = Color(0xff66ffff);
  static const purplePastel = Color(0xffcc99ff);

  // Màu bổ trợ cho giao diện hiện đại & tương phản cao
  static const purpleDark = Color(0xff110e24);
  static const purpleDeep = Color(0xff1c173b);
  static const purpleSurface = Color(0xff251f4c);
  static const purplePrimary = Color(0xff7c3aed);
  static const purpleAccent = Color(0xff8b5cf6);

  // Tương thích với code cũ
  static const navy = Color(0xff18153a);
  static const teal = Color(0xff06b6d4);

  // Nền sáng và chữ
  static const scaffoldBg = Color(0xfff7f8fc);
  static const cardBorder = Color(0xffe8eaf4);
  static const textPrimary = Color(0xff18153a);
  static const textSecondary = Color(0xff64748b);

  // Gradients
  static const brandGradient = LinearGradient(
    colors: [cyanBright, purplePastel],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const buttonGradient = LinearGradient(
    colors: [Color(0xff6366f1), purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [purpleDark, purpleDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: purplePrimary,
      primary: purplePrimary,
      secondary: cyanBright,
      tertiary: purplePastel,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: scaffoldBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: navy,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: navy,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorder, width: 1.2),
      ),
      shadowColor: purplePastel.withValues(alpha: 0.15),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: purpleAccent, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      prefixIconColor: purpleAccent,
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: purplePrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        elevation: 2,
        shadowColor: purplePrimary.withValues(alpha: 0.35),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: purplePrimary,
        side: BorderSide(color: purplePastel.withValues(alpha: 0.8), width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: navy,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
