import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── CORMORANT GARAMOND (serif — authority, permanence) ────────
  // Use for: screen titles, stat values, greeting, feed section headers

  static TextStyle display({Color? color}) => TextStyle(
    fontSize: 28, fontWeight: FontWeight.w600,
    color: color ?? AppColors.ink,
  );

  static TextStyle displayItalic({Color? color}) => TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic,
    color: color ?? AppColors.ink,
  );

  static TextStyle screenTitle({Color? color}) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: color ?? AppColors.ink, letterSpacing: 0.3,
  );

  static TextStyle statValue({Color? color}) => TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, height: 1.0,
    color: color ?? AppColors.lal,
  );

  static TextStyle feedSectionTitle({Color? color}) => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: color ?? AppColors.stone,
  );

  static TextStyle chatTitle({Color? color}) => TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: color ?? AppColors.ink,
  );

  static TextStyle avatarInitials({Color? color}) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: color ?? AppColors.ink,
  );

  // ── JOST (geometric sans — functional, readable) ──────────────
  // Use for: everything else

  static TextStyle body({Color? color}) => TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,
    color: color ?? AppColors.ink,
  );

  static TextStyle bodySec({Color? color}) => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.5,
    color: color ?? AppColors.dust,
  );

  static TextStyle bodySmall({Color? color}) => TextStyle(
    fontSize: 11, fontWeight: FontWeight.w300,
    color: color ?? AppColors.dust,
  );

  static TextStyle label({Color? color}) => TextStyle(
    fontSize: 9, fontWeight: FontWeight.w600,
    letterSpacing: 1.5, color: color ?? AppColors.dust,
  );

  static TextStyle navItem({Color? color}) => TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: color ?? AppColors.stone,
  );

  static TextStyle badge({Color? color}) => TextStyle(
    fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.5,
    color: color ?? Colors.white,
  );

  static TextStyle sectionLabel({Color? color}) => TextStyle(
    fontSize: 9, fontWeight: FontWeight.w600,
    letterSpacing: 2.0, color: color ?? AppColors.sandstone,
  );

  static TextStyle stat({Color? color}) => TextStyle(
    fontSize: 9, fontWeight: FontWeight.w400,
    color: color ?? AppColors.dust,
  );

  static TextStyle searchPlaceholder({Color? color}) => TextStyle(
    fontSize: 10, fontWeight: FontWeight.w300,
    color: color ?? AppColors.dust,
  );
}
