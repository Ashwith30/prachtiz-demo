import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum AppBadgeVariant { success, danger, warning, info, primary, secondary }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    
    switch (variant) {
      case AppBadgeVariant.success:
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        break;
      case AppBadgeVariant.danger:
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
        break;
      case AppBadgeVariant.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case AppBadgeVariant.info:
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
      case AppBadgeVariant.primary:
        bg = AppColors.primaryBg;
        fg = AppColors.primaryBlue;
        break;
      case AppBadgeVariant.secondary:
        bg = AppColors.successLight;
        fg = AppColors.secondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.35), width: 1.0),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
