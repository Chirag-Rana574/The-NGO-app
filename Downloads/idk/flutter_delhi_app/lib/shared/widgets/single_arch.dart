import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class SingleArch extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const SingleArch({
    super.key,
    this.width = 120,
    this.height = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ??
      (isDark ? AppColors.darkGround : AppColors.marble);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
