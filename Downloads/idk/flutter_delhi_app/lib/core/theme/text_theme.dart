import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextTheme {
  // Outfit for headings and display text
  static TextTheme get outfit => TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.stone,
    ),
  );

  // Inter for body and UI text
  static TextTheme get inter => TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.ink,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.dust,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.stone,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.dust,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: AppColors.dust,
    ),
  );

  // Combined theme for easy use
  static TextTheme get combined => TextTheme(
    displayLarge: outfit.displayLarge,
    displayMedium: outfit.displayMedium,
    headlineLarge: outfit.headlineLarge,
    headlineMedium: outfit.headlineMedium,
    titleLarge: outfit.titleLarge,
    titleMedium: outfit.titleMedium,
    titleSmall: outfit.titleSmall,
    bodyLarge: inter.bodyLarge,
    bodyMedium: inter.bodyMedium,
    bodySmall: inter.bodySmall,
    labelLarge: inter.labelLarge,
    labelMedium: inter.labelMedium,
    labelSmall: inter.labelSmall,
  );
}
