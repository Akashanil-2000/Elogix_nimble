// core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const primaryOrange = Color(0xFFFF7A00);

  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFFFFAE00),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFAE00),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFAE00),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
