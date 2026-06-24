import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GoldDivider extends StatelessWidget {
  final EdgeInsets padding;

  const GoldDivider({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor =
      isDark ? AppColors.darkBorder : AppColors.sandLt;
    final diamondColor =
      isDark ? AppColors.darkSandDim : AppColors.sandstone;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Divider(color: lineColor, thickness: 0.5, height: 1)),
          const SizedBox(width: 8),
          Transform.rotate(
            angle: 3.14159 / 4, // 45°
            child: Container(
              width: 7, height: 7,
              color: diamondColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: lineColor, thickness: 0.5, height: 1)),
        ],
      ),
    );
  }
}
