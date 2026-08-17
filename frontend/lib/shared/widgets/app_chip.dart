import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : AppColors.gray50,
          border: Border.all(
            color: isSelected ? activeColor : AppColors.gray300,
            width: 1.0,
          ),
          borderRadius: AppRadius.radius12,
        ),
        child: Text(
          label,
          style: AppTypography.bodySemibold.copyWith(
            color: isSelected ? activeColor : AppColors.gray700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
