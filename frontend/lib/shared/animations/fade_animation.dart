import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return child.animate(delay: delay).fadeIn(
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
