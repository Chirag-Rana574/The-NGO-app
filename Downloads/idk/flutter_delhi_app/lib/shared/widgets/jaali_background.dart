import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class JaaliBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Color? patternColor;

  const JaaliBackground({
    super.key,
    required this.child,
    this.opacity = 0.07,
    this.patternColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = patternColor ??
      (isDark ? AppColors.darkLazuli : Colors.white);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _JaaliPainter(
              color: color.withValues(alpha: opacity),
            ),
          ),
        ),
        child,
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _JaaliPainter extends CustomPainter {
  final Color color;
  _JaaliPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const cellSize = 32.0;

    for (double x = 0; x < size.width + cellSize; x += cellSize) {
      for (double y = 0; y < size.height + cellSize; y += cellSize) {
        // Diamond
        final path = Path()
          ..moveTo(x + cellSize / 2, y)
          ..lineTo(x + cellSize, y + cellSize / 2)
          ..lineTo(x + cellSize / 2, y + cellSize)
          ..lineTo(x, y + cellSize / 2)
          ..close();
        canvas.drawPath(path, paint);

        // Inscribed circle
        canvas.drawCircle(
          Offset(x + cellSize / 2, y + cellSize / 2),
          3.5, paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_JaaliPainter old) => old.color != color;
}
