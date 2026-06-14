import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// IKO — Editorial luxury theme.
/// Inspired by fine print magazines: cream paper, deep ink, a single accent
/// stroke. No gradients, no neon — just typography, space, and discipline.
class IkoTheme {
  // ---------------------------------------------------------------------
  // Palette
  // ---------------------------------------------------------------------
  static const Color primary = Color(0xFF0B0B0C); // Ink black
  static const Color background = Color(0xFFF6F4EF); // Warm paper
  static const Color surface = Color(0xFFF6F4EF);
  static const Color surfaceContainer = Color(0xFFEAE7E0); // Soft contrast
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Cards

  static const Color accent = Color(0xFFB8956A); // Aged brass (subtle warmth)
  static const Color hairline = Color(0xFFD9D5CC); // Divider hairline

  static const Color textPrimary = Color(0xFF0B0B0C);
  static const Color textSecondary = Color(0xFF6E6A60); // Warm grey
  static const Color textTertiary = Color(0xFFA8A498);

  static const Color success = Color(0xFF2F5A3D);
  static const Color warning = Color(0xFFB07A1E);
  static const Color danger = Color(0xFF8E2A23);

  // ---------------------------------------------------------------------
  // Font family resolvers — let pre-existing TextStyles pick up the
  // correct GoogleFonts family without rewriting every callsite.
  // ---------------------------------------------------------------------
  static String? get serifFamily => GoogleFonts.fraunces().fontFamily;
  static String? get sansFamily => GoogleFonts.inter().fontFamily;
  static String? get monoFamily => GoogleFonts.ibmPlexMono().fontFamily;

  // ---------------------------------------------------------------------
  // Font helpers — Google Fonts, loaded at runtime, no asset wiring needed.
  // ---------------------------------------------------------------------
  static TextStyle display(
          {double size = 48, FontWeight weight = FontWeight.w600, Color? color, double letterSpacing = -0.02, double height = 1.05}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: color ?? primary,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle serif(
          {double size = 20, FontWeight weight = FontWeight.w500, Color? color, double letterSpacing = 0, double height = 1.2}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: color ?? primary,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle body(
          {double size = 15, FontWeight weight = FontWeight.w400, Color? color, double height = 1.5}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color ?? textPrimary,
        height: height,
      );

  static TextStyle mono(
          {double size = 11, FontWeight weight = FontWeight.w600, Color? color, double letterSpacing = 1.6}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        color: color ?? textSecondary,
        letterSpacing: letterSpacing,
      );

  // ---------------------------------------------------------------------
  // Material Theme
  // ---------------------------------------------------------------------
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: surfaceContainerLowest,
        onSurface: textPrimary,
        error: danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: hairline,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: display(size: 56, weight: FontWeight.w700),
        displayMedium: display(size: 40, weight: FontWeight.w700),
        displaySmall: display(size: 32, weight: FontWeight.w600),
        headlineMedium: serif(size: 26, weight: FontWeight.w600),
        headlineSmall: serif(size: 22, weight: FontWeight.w600),
        titleLarge: serif(size: 20, weight: FontWeight.w600),
        bodyLarge: body(size: 16),
        bodyMedium: body(size: 14),
        bodySmall: body(size: 12, color: textSecondary),
        labelLarge: mono(size: 12),
        labelMedium: mono(size: 11),
        labelSmall: mono(size: 10),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: serif(size: 20, weight: FontWeight.w600),
      ),
    );
  }
}

/// Tiny semantic helpers for spacing — keeps layouts editorial-consistent.
class IkoSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 72;
}
