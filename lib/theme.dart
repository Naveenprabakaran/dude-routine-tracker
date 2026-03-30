// lib/theme.dart
// Defines the dark theme for the entire app
// One place to change colors/fonts for consistency

import 'package:flutter/material.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────
  static const Color bgDark      = Color(0xFF0D0D0F);  // Near-black background
  static const Color bgCard      = Color(0xFF1A1A1F);  // Card background
  static const Color bgCard2     = Color(0xFF22222A);  // Elevated card
  static const Color accent      = Color(0xFF00E5A0);  // Neon green - primary accent
  static const Color accentBlue  = Color(0xFF4D9EFF);  // Blue accent
  static const Color accentRed   = Color(0xFFFF4D6D);  // Red for "no"
  static const Color textPrimary = Color(0xFFF0F0F5);  // Main text
  static const Color textSecond  = Color(0xFF8888A0);  // Secondary/muted text
  static const Color divider     = Color(0xFF2A2A35);  // Divider lines

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentBlue,
        surface: bgCard,
        error: accentRed,
      ),
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      // Card theme
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
      // Bottom nav bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: accent,
        unselectedItemColor: textSecond,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary, fontSize: 32, fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: textSecond, fontSize: 13),
        labelLarge: TextStyle(
          color: bgDark, fontSize: 14, fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      // Input decoration theme (for notes text field)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecond),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
