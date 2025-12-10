import 'package:flutter/material.dart';

class AppColors {
  // 🌞 Light Theme - minimalist & professional
  static const Color lightPrimary = Color(
    0xFF1E293B,
  ); // Slate 800 (Deep Grey-Blue)
  static const Color lightSecondary = Color(0xFF334155); // Slate 700
  static const Color lightAccent = Color(
    0xFF4F46E5,
  ); // Indigo 600 (Vibrant but professional)
  static const Color lightRed = Color(0xFFEF4444); // Red 500

  static const Color lightBackground = Color(
    0xFFF1F5F9,
  ); // Slate 100 (Slightly darker for better white contrast)
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightText = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(
    0xFF475569,
  ); // Slate 600 (Darker for readability)

  // 🌙 Dark Theme - sophisticated dark mode
  static const Color darkPrimary = Color(
    0xFFF8FAFC,
  ); // Slate 50 (Inverted for contrast)
  static const Color darkSecondary = Color(0xFFCBD5E1); // Slate 300
  static const Color darkAccent = Color(
    0xFF818CF8,
  ); // Indigo 400 (Brighter for dark mode visibility)
  static const Color darkRed = Color(0xFFF87171); // Red 400

  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(
    0xFF334155,
  ); // Slate 700 (Lighter for visibility against BG)
  static const Color darkText = Color(0xFFF1F5F9); // Slate 100
  static const Color darkTextSecondary = Color(
    0xFFCBD5E1,
  ); // Slate 300 (Lighter for readability)

  static const Color error = Color.fromARGB(255, 232, 47, 47);
  static const Color edit = Color.fromARGB(
    255,
    89,
    145,
    235,
  ); // Blue 500 (Brighter)
}
