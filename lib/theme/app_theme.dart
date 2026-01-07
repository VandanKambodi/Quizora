import 'package:flutter/material.dart';

class QuizoraTheme {
  static const Color primaryBlue = Color(0xFF29B6F6);
  static const Color accentCyan = Color(0xFF26C6DA);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: primaryBlue),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black),
    ),
  );
}