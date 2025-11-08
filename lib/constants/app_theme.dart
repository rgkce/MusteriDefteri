import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme {
  // 🌞 Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
  );

  // 🌙 Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      displayLarge: AppStyles.headline1,
      displayMedium: AppStyles.headline2,
      bodyLarge: AppStyles.bodyText,
      bodySmall: AppStyles.caption,
    ).apply(bodyColor: AppColors.darkText, displayColor: AppColors.darkText),
    inputDecorationTheme: AppStyles.inputDecorationTheme.copyWith(
      fillColor: AppColors.darkSurface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkSecondary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppStyles.primaryButton.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColors.darkPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppStyles.secondaryButton.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColors.darkPrimary),
        side: const MaterialStatePropertyAll(
          BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
  );
}
