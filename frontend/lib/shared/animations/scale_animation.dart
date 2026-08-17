import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double beginScale;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.beginScale = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOutCubic)
        .scale(
          begin: Offset(beginScale, beginScale),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
