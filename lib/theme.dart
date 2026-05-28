import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XocketTheme {
  static const Color primary = Color(0xFFFFB000); // Locket Yellow
  static const Color primaryDark = Color(0xFFE69A00);
  static const Color background = Color(0xFF000000); // Deep Black
  static const Color surface = Color(0xFF1C1C1E); // Glass surface
  static const Color textMain = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0A5);

  // Gradient siêu mượt cho nền hoặc nút bấm
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFFB000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get themeData {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        background: background,
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          shadowColor: primary.withOpacity(0.5),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: textSecondary),
      ),
    );
  }
}
