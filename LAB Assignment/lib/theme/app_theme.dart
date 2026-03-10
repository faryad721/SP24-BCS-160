import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color brand = Color(0xFF1E6B5E);
  static const Color accent = Color(0xFF1D9A92);
  static const Color surface = Color(0xFFF6F9F8);
  static const Color card = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0E2B28);

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        primary: brand,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.manrope(fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: dark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        elevation: 10,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brand, width: 1.6),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
    );
  }
}
