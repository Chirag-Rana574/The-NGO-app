import 'package:flutter/material.dart';
import 'app_colors.dart';

class DecorationStyles {
  // Standard card decoration for light mode
  static BoxDecoration cardLight({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: AppColors.sandXlt,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      border: Border.all(color: AppColors.sandLt, width: 0.5),
    );
  }

  // Standard card decoration for dark mode
  static BoxDecoration cardDark({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: AppColors.darkRaised,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      border: Border.all(color: AppColors.darkBorder, width: 0.5),
    );
  }

  // Input decoration helper
  static InputDecoration inputDecoration({
    required String hintText,
    bool isDark = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.darkRaised : AppColors.sandXlt,
      hintText: hintText,
      hintStyle: TextStyle(color: isDark ? AppColors.darkTextDim : AppColors.dust),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.sandLt, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.sandLt, width: 0.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3), topRight: Radius.circular(3),
        ),
        borderSide: BorderSide(color: AppColors.sandstone, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
