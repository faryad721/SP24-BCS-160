import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🌞 LIGHT THEME
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),

    textTheme: GoogleFonts.poppinsTextTheme(),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );

  // 🌙 DARK THEME
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFF121212),

    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );
}