import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0066CC);
  static const Color accent = Color(0xFF5AC8FA);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFCC00);
  static const Color danger = Color(0xFFFF3B30);
  static const Color purple = Color(0xFFAF52DE);
  static const Color pink = Color(0xFFFF2D55);
  static const Color teal = Color(0xFF5AC8FA);
  static const Color orange = Color(0xFFFF9500);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF5AC8FA), Color(0xFF64D2FF)],
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: -1.5),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w800),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white.withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: GoogleFonts.inter(color: const Color(0xFF8E8E93), fontWeight: FontWeight.w500),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF2F2F7),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.9),
      selectedItemColor: primary,
      unselectedItemColor: const Color(0xFF8E8E93),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1C1C1E),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE5E5EA), thickness: 0.5),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF1C1C1E),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Colors.white),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFF1C1C1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: GoogleFonts.inter(color: const Color(0xFF8E8E93), fontWeight: FontWeight.w500),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.9),
      selectedItemColor: primary,
      unselectedItemColor: const Color(0xFF8E8E93),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF38383A), thickness: 0.5),
  );

  static Map<String, Color> categoryColors = {
    'GST': const Color(0xFF34C759),
    'TDS': const Color(0xFF007AFF),
    'INCOME_TAX': const Color(0xFFAF52DE),
    'ROC': const Color(0xFFFF9500),
    'ACCOUNTING': const Color(0xFF5AC8FA),
    'AUDIT': const Color(0xFFFF3B30),
    'OTHER': const Color(0xFF8E8E93),
  };

  static Map<String, Color> priorityColors = {
    'HIGH': const Color(0xFFFF3B30),
    'MEDIUM': const Color(0xFFFF9500),
    'LOW': const Color(0xFF34C759),
  };
}
