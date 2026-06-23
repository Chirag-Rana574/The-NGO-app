import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/context_colors.dart';
import '../core/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Simulate initialization (loading config, checking auth, etc.)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ground,
      body: Stack(
        children: [
          // Jaali background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _JaaliPainter(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkLazuli.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.accent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.gavel,
                    size: 50,
                    color: context.primary,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 400.ms),
                
                const SizedBox(height: 32),
                
                // App Name
                Text(
                  'Delhi Legal Assistant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.textPri,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutQuad)
                    .fadeIn(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Your legal companion for Delhi courts',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSec,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutQuad)
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                
                const SizedBox(height: 48),
                
                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(context.accent),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
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