import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Mode Colors
  static const ink = Color(0xFF0F3D4C);
  static const inkSoft = Color(0xFF1A5A6E);
  static const seafoam = Color(0xFFE8F3F1);
  static const mist = Color(0xFFF4F8F7);
  static const accent = Color(0xFFE36414);
  static const accentSoft = Color(0xFFFFF0E6);
  static const success = Color(0xFF1F7A4C);
  static const successSoft = Color(0xFFE5F5EC);
  static const danger = Color(0xFFC0392B);
  static const dangerSoft = Color(0xFFFDECEA);
  static const line = Color(0xFFD5E3DF);
  static const muted = Color(0xFF5F7380);

  // Dark Mode Colors
  static const darkBg = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkLine = Color(0xFF333333);
  static const darkMuted = Color(0xFFAAAAAA);

  // ✅ NEW: Dark mode ke liye feedback colors
  static const darkSuccessSoft = Color(0xFF1B3A2A); // Dark green
  static const darkDangerSoft = Color(0xFF3A1E1E); // Dark red
}

class AppTheme {
  static ThemeData light() {
    return _baseTheme(Brightness.light);
  }

  static ThemeData dark() {
    return _baseTheme(Brightness.dark);
  }

  static ThemeData _baseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.mist,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        primary: isDark ? const Color(0xFF64FFDA) : AppColors.ink,
        secondary: isDark ? const Color(0xFFFF8A65) : AppColors.accent,
        surface: isDark ? AppColors.darkCard : Colors.white,
        error: AppColors.danger,
        brightness: brightness,
      ),
    );

    final display = GoogleFonts.frauncesTextTheme(base.textTheme);
    final body = GoogleFonts.dmSansTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          color: isDark ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: isDark ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: isDark ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkMuted : AppColors.muted,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkBg : AppColors.mist,
        foregroundColor: isDark ? Colors.white : AppColors.ink,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF64FFDA) : AppColors.ink,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.line,
      ),
    );
  }
}
