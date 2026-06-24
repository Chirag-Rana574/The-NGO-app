import 'package:flutter/material.dart';
import 'app_colors.dart';

extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surface   => isDark ? AppColors.darkSurface  : Colors.white;
  Color get ground    => isDark ? AppColors.darkGround   : AppColors.marble;
  Color get raised    => isDark ? AppColors.darkRaised   : AppColors.sandXlt;
  Color get border    => isDark ? AppColors.darkBorder   : AppColors.sandLt;
  Color get border2   => isDark ? AppColors.darkBorder2  : AppColors.sandstone;
  Color get textPri   => isDark ? AppColors.darkTextPri  : AppColors.ink;
  Color get textSec   => isDark ? AppColors.darkTextSec  : AppColors.dust;
  Color get textDim   => isDark ? AppColors.darkTextDim  : AppColors.stone;
  Color get accent    => isDark ? AppColors.darkGold     : AppColors.gold;
  Color get accentDim => isDark ? AppColors.darkGoldDim  : AppColors.sandstone;
  Color get primary   => isDark ? AppColors.darkLalDim   : AppColors.lal;
  Color get success   => isDark ? AppColors.darkMalachite : AppColors.malachite;
  Color get info      => isDark ? AppColors.darkLazuli   : AppColors.lazuli;
  Color get danger    => isDark ? AppColors.darkLal      : AppColors.lalLt;
  Color get sandGlow  => isDark ? AppColors.darkSandGlow : AppColors.sandXlt;
}
