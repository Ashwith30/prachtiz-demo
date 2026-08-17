import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryBlue,
      dividerColor: AppColors.divider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondary,
        error: AppColors.danger,
        surface: AppColors.white,
        background: AppColors.background,
      ),
      textTheme: AppTypography.textTheme,
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radius16,
          side: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radius12,
          borderSide: const BorderSide(color: AppColors.gray200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radius12,
          borderSide: const BorderSide(color: AppColors.gray200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radius12,
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.0),
        ),
        labelStyle: AppTypography.body.copyWith(color: AppColors.gray500),
        hintStyle: AppTypography.label.copyWith(color: AppColors.gray400),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radius16,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF131930), // Dark background color
      primaryColor: AppColors.primaryBlue,
      dividerColor: Colors.white10,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: const Color(0xFF24C06F),
        error: AppColors.danger,
        surface: const Color(0xFF2A3042),
        background: const Color(0xFF131930),
      ),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2A3042),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radius16,
          side: const BorderSide(color: Colors.white10, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2548),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radius12,
          borderSide: const BorderSide(color: Colors.white12, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radius12,
          borderSide: const BorderSide(color: Colors.white12, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radius12,
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.0),
        ),
        labelStyle: AppTypography.body.copyWith(color: Colors.white54),
        hintStyle: AppTypography.label.copyWith(color: Colors.white38),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0C0E1F),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radius16,
          side: const BorderSide(color: Colors.white10),
        ),
      ),
    );
  }
}
