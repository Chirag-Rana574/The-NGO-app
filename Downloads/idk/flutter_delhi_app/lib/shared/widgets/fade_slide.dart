import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeSlide extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset startOffset;

  const FadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.startOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration)
        .slideY(begin: startOffset.dy, end: 0, duration: duration, curve: Curves.easeOut);
  }
}
