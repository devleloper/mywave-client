import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color tiffanyBlue = Color(0xFF0ABAB5);
  static const Color background = Color(0xFF090909);
  static const Color surface = Color(0xFF1A1A1A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: tiffanyBlue,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: tiffanyBlue,
        secondary: tiffanyBlue,
        surface: surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: tiffanyBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }
}
