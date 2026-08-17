import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum StatusBadgeVariant { success, danger, warning, info, neutral, primary }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final bool showDot;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.showDot = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color dotColor;

    switch (variant) {
      case StatusBadgeVariant.success:
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        dotColor = AppColors.success;
        break;
      case StatusBadgeVariant.danger:
        bg = AppColors.dangerLight;
        fg = AppColors.dangerDark;
        dotColor = AppColors.danger;
        break;
      case StatusBadgeVariant.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warningDark;
        dotColor = AppColors.warning;
        break;
      case StatusBadgeVariant.info:
        bg = AppColors.infoLight;
        fg = AppColors.infoDark;
        dotColor = AppColors.info;
        break;
      case StatusBadgeVariant.primary:
        bg = AppColors.primaryBg;
        fg = AppColors.primary;
        dotColor = AppColors.primary;
        break;
      case StatusBadgeVariant.neutral:
        bg = AppColors.gray100;
        fg = AppColors.gray700;
        dotColor = AppColors.gray400;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: fg.withOpacity(0.12), width: 1.0),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (icon != null && !showDot) ...[
              Icon(
                icon,
                size: 12,
                color: fg,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
