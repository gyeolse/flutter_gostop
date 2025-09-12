import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Custom Text Theme with larger font sizes
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.textLight),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.textLight),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.textLight),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textLight),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textLight),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textLight),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textLight),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textLight),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textLight),
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textLight),
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textLight),
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textLight),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLight),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
  );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      background: AppColors.backgroundLight,
    ),
    textTheme: _lightTextTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.elevatedButtonBackground,
        foregroundColor: AppColors.textLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.outlinedButtonBorder, width: 2),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
    ),
    textTheme: _darkTextTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textLight,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.primaryLight, width: 2),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white38),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}