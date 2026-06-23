import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Motif 1: Jaali Lattice Texture
/// A repeating diamond grid pattern from Humayun's Tomb stone screens
class JaaliPattern extends StatelessWidget {
  const JaaliPattern({
    super.key,
    this.opacity = 0.08,
    this.darkOpacity = 0.15,
  });

  final double opacity;
  final double darkOpacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _JaaliPainter(
        color: isDark
            ? AppColors.darkLapisLt.withValues(alpha: darkOpacity)
            : Colors.white.withValues(alpha: opacity),
      ),
      size: Size.infinite,
    );
  }
}

class _JaaliPainter extends CustomPainter {
  _JaaliPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;

    const double diamondSize = 20.0;
    
    for (double y = 0; y < size.height + diamondSize; y += diamondSize) {
      for (double x = 0; x < size.width + diamondSize; x += diamondSize) {
        final path = Path()
          ..moveTo(x, y + diamondSize / 2)
          ..lineTo(x + diamondSize / 2, y)
          ..lineTo(x + diamondSize, y + diamondSize / 2)
          ..lineTo(x + diamondSize / 2, y + diamondSize)
          ..close();
        
        canvas.drawPath(path, paint);

        // Inscribed circle
        canvas.drawCircle(
          Offset(x + diamondSize / 2, y + diamondSize / 2),
          2.0,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Motif 2: Triple Arch Silhouette (Login screen)
class TripleArch extends StatelessWidget {
  const TripleArch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 22,
      child: Row(
        children: [
          Expanded(
            child: ArchCutout(
              backgroundColor: isDark ? AppColors.darkGround : AppColors.marble,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: ArchCutout(
              backgroundColor: isDark ? AppColors.darkGround : AppColors.marble,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: ArchCutout(
              backgroundColor: isDark ? AppColors.darkGround : AppColors.marble,
            ),
          ),
        ],
      ),
    );
  }
}

class ArchCutout extends StatelessWidget {
  const ArchCutout({super.key, required this.backgroundColor});
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(40),
      ),
      child: Container(
        color: backgroundColor,
      ),
    );
  }
}

/// Motif 3: Single Arch (Home hero)
class SingleArch extends StatelessWidget {
  const SingleArch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SizedBox(
        width: 120,
        height: 18,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(60),
          ),
          child: Container(
            color: isDark ? AppColors.darkGround : AppColors.marble,
          ),
        ),
      ),
    );
  }
}

/// Motif 4: Pietra Border (2px top border on cards)
class PietraBorder extends StatelessWidget {
  const PietraBorder({
    super.key,
    this.accentColor,
    this.height = 2,
  });

  final Color? accentColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: double.infinity,
      color: accentColor ?? (isDark ? AppColors.darkGoldDim : AppColors.gold),
    );
  }
}

/// Motif 5: Diamond Divider
class DiamondDivider extends StatelessWidget {
  const DiamondDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 20,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 0.5,
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Transform.rotate(
            angle: 0.7854, // 45 degrees
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkLapisDim : AppColors.sandstone,
                border: Border.all(
                  color: isDark ? AppColors.darkLapis : AppColors.sandstone,
                  width: isDark ? 1 : 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 0.5,
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
              ),
            ),
          ),
        ],
      ),
    );
  }
}