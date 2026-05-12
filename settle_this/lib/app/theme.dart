import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettleThisColors {
  SettleThisColors._();

  static const Color cream = Color(0xFFFBF6EC);
  static const Color creamDeep = Color(0xFFF1E9D6);
  static const Color navy = Color(0xFF1F2452);
  static const Color navyDeep = Color(0xFF141838);
  static const Color gavelGold = Color(0xFFE8B43C);
  static const Color coral = Color(0xFFEF6F5E);
  static const Color success = Color(0xFF3FA66B);
  static const Color warning = Color(0xFFD79A2B);
  static const Color blocked = Color(0xFFB23A48);
  static const Color ink = Color(0xFF1B1B1B);
  static const Color inkSoft = Color(0xFF565B6E);
}

ThemeData buildSettleThisTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: SettleThisColors.navy,
    primary: SettleThisColors.navy,
    onPrimary: SettleThisColors.cream,
    secondary: SettleThisColors.gavelGold,
    onSecondary: SettleThisColors.navyDeep,
    tertiary: SettleThisColors.coral,
    surface: SettleThisColors.cream,
    onSurface: SettleThisColors.ink,
    error: SettleThisColors.blocked,
    brightness: Brightness.light,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
    bodyColor: SettleThisColors.ink,
    displayColor: SettleThisColors.navyDeep,
  );

  return base.copyWith(
    scaffoldBackgroundColor: SettleThisColors.cream,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: SettleThisColors.cream,
      foregroundColor: SettleThisColors.navyDeep,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: SettleThisColors.navyDeep,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SettleThisColors.creamDeep),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SettleThisColors.navy,
        foregroundColor: SettleThisColors.cream,
        textStyle: GoogleFonts.nunito(
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SettleThisColors.gavelGold,
        foregroundColor: SettleThisColors.navyDeep,
        textStyle: GoogleFonts.nunito(
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: SettleThisColors.navy),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SettleThisColors.creamDeep),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SettleThisColors.creamDeep),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SettleThisColors.navy, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: SettleThisColors.gavelGold,
      labelStyle: GoogleFonts.nunito(
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SettleThisColors.creamDeep),
      ),
    ),
    dividerTheme: const DividerThemeData(color: SettleThisColors.creamDeep),
  );
}
