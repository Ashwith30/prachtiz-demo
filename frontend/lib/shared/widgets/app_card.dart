import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../animations/hover_animation.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final bool isGlass;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool animateHover;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.isGlass = false,
    this.padding,
    this.width,
    this.height,
    this.animateHover = false,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    if (isGlass) {
      decoration = BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius ?? AppRadius.radius18,
        border: border ?? Border.all(color: AppColors.glassBorder),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppColors.glassShadow,
                offset: const Offset(0, 8),
                blurRadius: 32,
              ),
            ],
      );
    } else {
      decoration = BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: borderRadius ?? AppRadius.radius18,
        border: border ?? Border.all(color: AppColors.gray200, width: 1.0),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: const Color(0xFF13294B).withOpacity(0.04),
                offset: const Offset(0, 4),
                blurRadius: 20,
              ),
              BoxShadow(
                color: const Color(0xFF13294B).withOpacity(0.02),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
      );
    }

    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: decoration,
      child: child,
    );

    if (animateHover) {
      cardContent = HoverAnimation(child: cardContent);
    }

    return cardContent;
  }
}
