import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, outline, danger, success }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;
  final bool isLoading;
  final String? tooltip;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 48.0, // Minimum touch target footprint 48px
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primary;
        fg = AppColors.white;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.primaryBg;
        fg = AppColors.primary;
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.greyText;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.gray700;
        border = const BorderSide(color: AppColors.gray300, width: 1.0);
        break;
      case AppButtonVariant.danger:
        bg = AppColors.danger;
        fg = AppColors.white;
        break;
      case AppButtonVariant.success:
        bg = AppColors.secondary;
        fg = AppColors.white;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withOpacity(0.5),
      disabledForegroundColor: fg.withOpacity(0.5),
      shadowColor: variant == AppButtonVariant.ghost || variant == AppButtonVariant.outline
          ? Colors.transparent
          : Colors.black.withOpacity(0.05),
      elevation: variant == AppButtonVariant.ghost || variant == AppButtonVariant.outline ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radius12,
        side: border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTypography.bodySemibold.copyWith(color: fg),
              ),
            ],
          );

    Widget button = SizedBox(
      width: width,
      height: height,
      child: variant == AppButtonVariant.ghost
          ? TextButton(
              onPressed: isLoading ? null : onPressed,
              style: TextButton.styleFrom(
                foregroundColor: fg,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radius12),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              child: content,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: content,
            ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: button,
    );
  }
}
