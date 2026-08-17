import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

class SlideAnimation extends StatelessWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;
  final double offset;

  const SlideAnimation({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottomToTop,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.offset = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.leftToRight:
        beginOffset = Offset(-offset, 0);
        break;
      case SlideDirection.rightToLeft:
        beginOffset = Offset(offset, 0);
        break;
      case SlideDirection.topToBottom:
        beginOffset = Offset(0, -offset);
        break;
      case SlideDirection.bottomToTop:
        beginOffset = Offset(0, offset);
        break;
    }

    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOutCubic)
        .slide(
          begin: beginOffset / 100, // Normalize relative distance mapping
          end: Offset.zero,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
