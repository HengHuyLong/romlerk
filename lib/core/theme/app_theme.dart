import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart'; 

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkGray,
        primary: AppColors.darkGray,
        secondary: AppColors.green,
        surface: AppColors.white,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.body,
      ),
    );
  }
}
