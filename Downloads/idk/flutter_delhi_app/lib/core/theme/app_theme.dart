import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {

  // ── LIGHT THEME ───────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.marble,

    colorScheme: const ColorScheme.light(
      primary:        AppColors.lal,
      onPrimary:      AppColors.sandXlt,
      secondary:      AppColors.sandstone,
      onSecondary:    AppColors.ink,
      surface:        AppColors.sandXlt,
      onSurface:      AppColors.ink,
      error:          AppColors.lalLt,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor:  AppColors.lal,
      foregroundColor:  AppColors.sandXlt,
      elevation:        0,
      scrolledUnderElevation: 0,
      titleTextStyle:   AppTextStyles.screenTitle(color: AppColors.sandXlt),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor:            Colors.transparent,
        statusBarIconBrightness:   Brightness.light,
      ),
      shape: const Border(
        bottom: BorderSide(color: AppColors.gold, width: 1.5),
      ),
    ),

    cardTheme: CardThemeData(
      color:          AppColors.sandXlt,
      elevation:      0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.sandLt, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   AppColors.sandXlt,
      border:      OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: AppColors.sandLt, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: AppColors.sandLt, width: 0.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3), topRight: Radius.circular(3),
        ),
        borderSide: BorderSide(color: AppColors.sandstone, width: 2),
      ),
      hintStyle: AppTextStyles.searchPlaceholder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    dividerTheme: const DividerThemeData(
      color:     AppColors.sandLt,
      thickness: 0.5,
    ),

    textTheme: TextTheme(
      bodyLarge:   AppTextStyles.body(),
      bodyMedium:  AppTextStyles.bodySmall(),
      labelSmall:  AppTextStyles.label(),
    ),
  );

  // ── DARK THEME (Lapis Lazuli) ────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkGround,

    colorScheme: const ColorScheme.dark(
      primary:        AppColors.darkSandGlow, // Lapis Glow
      onPrimary:      AppColors.darkGround,
      secondary:      AppColors.darkSandstone, // Lapis Dim
      onSecondary:    AppColors.darkGround,
      surface:        AppColors.darkRaised,
      onSurface:      AppColors.darkTextPri,
      error:          AppColors.darkLal,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor:  AppColors.darkSurface,
      foregroundColor:  AppColors.darkSandGlow,
      elevation:        0,
      scrolledUnderElevation: 0,
      titleTextStyle:   AppTextStyles.screenTitle(color: AppColors.darkSandGlow),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor:            Colors.transparent,
        statusBarIconBrightness:   Brightness.light,
      ),
      shape: const Border(
        bottom: BorderSide(color: AppColors.darkLazuli, width: 1.5), // Was goldDim, replaced with lapis
      ),
    ),

    cardTheme: CardThemeData(
      color:     AppColors.darkRaised,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: AppColors.darkRaised,
      border:      OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3), topRight: Radius.circular(3),
        ),
        borderSide: BorderSide(color: AppColors.darkSandstone, width: 2), // Focus using Lapis dim
      ),
      hintStyle: AppTextStyles.searchPlaceholder(color: AppColors.darkTextDim),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    dividerTheme: const DividerThemeData(
      color:     AppColors.darkBorder,
      thickness: 0.5,
    ),

    textTheme: TextTheme(
      bodyLarge:  AppTextStyles.body(color: AppColors.darkTextPri),
      bodyMedium: AppTextStyles.bodySmall(color: AppColors.darkTextSec),
      labelSmall: AppTextStyles.label(color: AppColors.darkTextSec),
    ),
  );
}
