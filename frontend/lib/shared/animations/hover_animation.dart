import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HoverAnimation extends StatefulWidget {
  final Widget child;
  final double scale;
  final double translateUp;
  final Duration duration;
  final Curve curve;

  const HoverAnimation({
    super.key,
    required this.child,
    this.scale = 1.015,
    this.translateUp = 4.0,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  State<HoverAnimation> createState() => _HoverAnimationState();
}

class _HoverAnimationState extends State<HoverAnimation> {
  bool _isHovered = false;

  void _onHover(bool isHovered) {
    if (_isHovered != isHovered) {
      setState(() {
        _isHovered = isHovered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the platform natively supports hovers
    final isDesktop = kIsWeb || 
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux;
        
    if (!isDesktop) {
      return widget.child;
    }

    final scaleValue = _isHovered ? widget.scale : 1.0;
    final translateValue = _isHovered ? -widget.translateUp : 0.0;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        transform: Matrix4.identity()
          ..translate(0.0, translateValue, 0.0)
          ..scale(scaleValue, scaleValue),
        child: widget.child,
      ),
    );
  }
}
