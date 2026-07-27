/// MemFlow 主题系统 — 极致扁平，专注内容
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5856D6);
  static const Color primaryLight = Color(0xFF7B79E0);
  static const Color primaryBg = Color(0xFFEEEEFF);

  // 浅色
  static const Color bgLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  // 深色
  static const Color bgDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);

  static const Color again = Color(0xFFFF3B30);
  static const Color againBg = Color(0xFFFFF0EF);
  static const Color hard = Color(0xFFFF9500);
  static const Color hardBg = Color(0xFFFFF5EB);
  static const Color good = Color(0xFF34C759);
  static const Color goodBg = Color(0xFFEDFFF3);

  static const Color codeBg = Color(0xFF1E1E2E);
  static const Color codeText = Color(0xFFD4D4D4);
}

class AppText {
  static const TextStyle largeTitle = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 0.37, height: 1.2);
  static const TextStyle title2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle title3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.41, height: 1.3);
  static const TextStyle body = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: -0.41, height: 1.5);
  static const TextStyle callout = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.32, height: 1.4);
  static const TextStyle subhead = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: -0.24, height: 1.3);
  static const TextStyle footnote = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.2);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.2);
}

// ── 浅色 ──────────────────────────────────────────────

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.black.withAlpha(10)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgLight,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFF9F9FB),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.bgLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    dividerTheme: const DividerThemeData(color: Color(0xFFE5E5EA), thickness: 0.5, space: 0),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary, linearMinHeight: 6),
  );
}

// ── 深色 ──────────────────────────────────────────────

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: Color(0xFFE5E5EA),
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF2C2C2E)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDark,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFE5E5EA)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: Color(0xFF636366),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: const Color(0xFF2C2C2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), backgroundColor: AppColors.surfaceDark),
    dividerTheme: const DividerThemeData(color: Color(0xFF38383A), thickness: 0.5, space: 0),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryLight, linearMinHeight: 6),
  );
}
