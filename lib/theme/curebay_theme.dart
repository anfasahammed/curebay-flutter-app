import 'package:flutter/material.dart';

/// CureBay brand colors extracted from their actual app and website
class CureBayColors {
  static const Color navy = Color(0xFF1A4789);
  static const Color navyDark = Color(0xFF0E2D5C);
  static const Color green = Color(0xFF3FB97F);
  static const Color greenLight = Color(0xFFE8F5EC);
  static const Color greenMint = Color(0xFFD9EFE2);
  static const Color background = Color(0xFFF7FAFC);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A2238);
  static const Color textMid = Color(0xFF5A6478);
  static const Color textLight = Color(0xFF8B95A8);
  static const Color divider = Color(0xFFE5EAF2);

  // Triage colors
  static const Color emergency = Color(0xFFE53935);
  static const Color urgent = Color(0xFFFF9800);
  static const Color normal = Color(0xFF4CAF50);
}

ThemeData curebayTheme() {
  return ThemeData(
    primaryColor: CureBayColors.navy,
    scaffoldBackgroundColor: CureBayColors.background,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.light(
      primary: CureBayColors.navy,
      secondary: CureBayColors.green,
      surface: CureBayColors.cardBg,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: CureBayColors.textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: CureBayColors.navy,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: CureBayColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        fontFamily: 'Poppins',
      ),
      iconTheme: IconThemeData(color: CureBayColors.navy),
    ),
    cardTheme: CardThemeData(
      color: CureBayColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: CureBayColors.divider, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CureBayColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CureBayColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CureBayColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CureBayColors.navy, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: CureBayColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 26,
      ),
      headlineMedium: TextStyle(
        color: CureBayColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        color: CureBayColors.textDark,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: CureBayColors.textDark,
        fontSize: 15,
      ),
      bodyMedium: TextStyle(
        color: CureBayColors.textMid,
        fontSize: 14,
      ),
    ),
  );
}
