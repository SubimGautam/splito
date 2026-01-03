import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Lato',

    primarySwatch: Colors.teal,

    scaffoldBackgroundColor: const Color(0xFFF9FAFB),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Colors.black45,
      ),
    ),
  );
}
