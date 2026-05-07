import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE53935);
  static const Color pureWhite = Color(0xFFFFFFFF);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: pureWhite,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      primary: primaryRed,
      onPrimary: pureWhite,
      surface: pureWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryRed,
      foregroundColor: pureWhite,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryRed,
      foregroundColor: pureWhite,
    ),
    fontFamily: 'Inter', // Fallback to system font if not added
  );
}
