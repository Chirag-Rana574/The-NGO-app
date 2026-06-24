import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ArchRow extends StatelessWidget {
  final int count;
  final double height;
  final Color? color;
  final double gap;

  const ArchRow({
    super.key,
    this.count = 3,
    this.height = 20,
    this.color,
    this.gap = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ??
      (isDark ? AppColors.darkGround : AppColors.marble);

    return Row(
      children: List.generate(count, (i) => Expanded(
        child: Container(
          height: height,
          margin: EdgeInsets.symmetric(horizontal: gap),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(height * 2),
            ),
          ),
        ),
      )),
    );
  }
}
