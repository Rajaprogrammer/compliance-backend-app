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
  static const Color gray = Color(0xFF8E8E93);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF5AC8FA), Color(0xFF64D2FF)],
  );

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'GST': Color(0xFF34C759),
    'TDS': Color(0xFF007AFF),
    'INCOME_TAX': Color(0xFFAF52DE),
    'ROC': Color(0xFFFF9500),
    'ACCOUNTING': Color(0xFF5AC8FA),
    'AUDIT': Color(0xFFFF3B30),
    'OTHER': Color(0xFF8E8E93),
  };

  // Priority Colors
  static const Map<String, Color> priorityColors = {
    'HIGH': Color(0xFFFF3B30),
    'MEDIUM': Color(0xFFFF9500),
    'LOW': Color(0xFF34C759),
  };

  // View Accent Colors
  static const Map<String, Color> viewAccents = {
    'home': Color(0xFF0EA5E9),
    'work': Color(0xFF8B5CF6),
    'calendar': Color(0xFFF97316),
    'clients': Color(0xFF22C55E),
    'studio': Color(0xFF06B6D4),
    'ops': Color(0xFFEF4444),
    'help': Color(0xFFA855F7),
  };

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
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Colors.black),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.black),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.black),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.black),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white.withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.black87),
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
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: danger)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.inter(color: gray, fontWeight: FontWeight.w500),
      labelStyle: GoogleFonts.inter(color: gray, fontWeight: FontWeight.w600),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF2F2F7),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1C1C1E),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE5E5EA), thickness: 0.5),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return primary;
      return Colors.white;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return primary.withOpacity(0.5);
      return const Color(0xFFE5E5EA); // (or your dark color in darkTheme)
    }),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primary,
      unselectedLabelColor: gray,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primary, width: 3)),
    ),
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
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white70),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
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
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: danger)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.inter(color: gray, fontWeight: FontWeight.w500),
      labelStyle: GoogleFonts.inter(color: gray, fontWeight: FontWeight.w600),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF38383A), thickness: 0.5),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return primary;
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return primary.withOpacity(0.5);
        return const Color(0xFFE5E5EA); // (or your dark color in darkTheme)
      }),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primary,
      unselectedLabelColor: gray,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primary, width: 3)),
    ),
  );
}
