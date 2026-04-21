import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color tiffanyBlue = Color(0xFF0ABAB5);
  static const Color backgroundDark = Color.fromARGB(255, 17, 17, 17);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF1D1D1F);

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    return base.copyWith(
      displayLarge: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.outfit(color: color),
      bodyMedium: GoogleFonts.outfit(color: color),
      bodySmall: GoogleFonts.outfit(color: color.withValues(alpha: 0.6)),
      labelLarge: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: tiffanyBlue,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: tiffanyBlue,
        secondary: tiffanyBlue,
        surface: surfaceDark,
        onSurface: Colors.white,
      ),
      textTheme: _buildTextTheme(base.textTheme, Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: tiffanyBlue,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: tiffanyBlue,
        secondary: tiffanyBlue,
        surface: surfaceLight,
        onSurface: textLight,
      ),
      textTheme: _buildTextTheme(base.textTheme, textLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textLight),
      ),
    );
  }
}
