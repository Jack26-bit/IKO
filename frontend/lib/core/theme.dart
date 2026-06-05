import 'package:flutter/material.dart';

class IkoTheme {
  // Brand Colors
  static const Color primary = Color(0xFF000000); // Black
  static const Color background = Color(0xFFF9F9F9); // Light Gray Background
  static const Color surface = Color(0xFFF9F9F9); // Surface
  static const Color surfaceContainer = Color(0xFFEEEEEE); // Darker surface
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // White cards
  
  static const Color accent = Color(0xFF1A1A1A);
  
  static const Color textPrimary = Color(0xFF1B1B1B); // On-surface
  static const Color textSecondary = Color(0xFF646464); // On-secondary-container
  
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: textSecondary,
        onSecondary: Colors.white,
        surface: surfaceContainerLowest,
        onSurface: textPrimary,
        error: danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      
      // Typography
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
          color: primary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.01,
          color: primary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Geist',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          color: textSecondary,
        ),
      ),
    );
  }
}
