import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class PietraCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;  // The top border color
  final Color? fillColor;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const PietraCard({
    super.key,
    required this.child,
    this.accentColor,
    this.fillColor,
    this.padding = const EdgeInsets.all(10),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topColor = accentColor ??
      (isDark ? AppColors.darkGoldDim : AppColors.gold);
    final cardFill = fillColor ??
      (isDark ? AppColors.darkRaised : AppColors.sandXlt);
    final borderColor =
      isDark ? AppColors.darkBorder : AppColors.sandLt;

    return Container(
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                if (topColor != Colors.transparent)
                  Positioned(
                    top: 0, left: 0, right: 0,
                    height: 2,
                    child: ColoredBox(color: topColor),
                  ),
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
