import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme {
  // 🌞 Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.lightText),
    ),
    textTheme: const TextTheme(
      displayLarge: AppStyles.headline1,
      displayMedium: AppStyles.headline2,
      bodyLarge: AppStyles.bodyText,
      bodySmall: AppStyles.caption,
    ),
    inputDecorationTheme: AppStyles.inputDecorationTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppStyles.primaryButton,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppStyles.secondaryButton,
    ),
    cardTheme: CardTheme(
      color: AppColors.lightSurface,
      elevation: 0, // Flat cards
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)), // Subtle border
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightAccent,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.lightAccent,
      unselectedItemColor: AppColors.lightTextSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // 🌙 Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: AppStyles.headline1,
      displayMedium: AppStyles.headline2,
      bodyLarge: AppStyles.bodyText,
      bodySmall: AppStyles.caption,
    ).apply(bodyColor: AppColors.darkText, displayColor: AppColors.darkText),
    inputDecorationTheme: AppStyles.inputDecorationTheme.copyWith(
      fillColor: AppColors.darkSurface,
      hintStyle: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkAccent, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppStyles.primaryButton.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColors.darkAccent),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppStyles.secondaryButton.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColors.darkAccent),
        side: const MaterialStatePropertyAll(
          BorderSide(color: AppColors.darkAccent, width: 1.5),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkAccent,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkAccent,
      unselectedItemColor: AppColors.darkTextSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
