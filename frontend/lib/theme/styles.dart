import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class AppStyles {
  // Border Radii
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 24.0;

  static BorderRadius get radiusSm => BorderRadius.circular(borderRadiusSm);
  static BorderRadius get radiusMd => BorderRadius.circular(borderRadiusMd);
  static BorderRadius get radiusLg => BorderRadius.circular(borderRadiusLg);
  static BorderRadius get radiusXl => BorderRadius.circular(borderRadiusXl);

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF273A91).withOpacity(0.07),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF273A91).withOpacity(0.11),
          offset: const Offset(0, 4),
          blurRadius: 16,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, 1),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF273A91).withOpacity(0.14),
          offset: const Offset(0, 8),
          blurRadius: 32,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 3),
          blurRadius: 8,
        ),
      ];

  // Text Styles delegated to core typography
  static TextStyle get titleLarge => AppTypography.headline;
  static TextStyle get titleMedium => AppTypography.title;
  static TextStyle get titleSmall => AppTypography.subtitle;
  static TextStyle get bodyBase => AppTypography.body;
  static TextStyle get bodySemibold => AppTypography.bodySemibold;
  static TextStyle get bodySmall => AppTypography.label;
  static TextStyle get caption => AppTypography.caption;

  // Card Decoration
  static BoxDecoration cardDecoration({
    Color color = AppColors.white,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius ?? radiusLg,
      border: border ?? Border.all(color: AppColors.gray200, width: 1.0),
      boxShadow: shadowSm,
    );
  }

  // Premium Glassmorphism Decoration
  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: borderRadius,
      border: border ?? Border(right: BorderSide(color: AppColors.glassBorder)),
      boxShadow: [
        BoxShadow(
          color: AppColors.glassShadow,
          offset: const Offset(2, 0),
          blurRadius: 32,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
