import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class EmptyCalendar extends StatelessWidget {
  const EmptyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 32,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Events Scheduled',
            style: AppTypography.bodySemibold.copyWith(
              fontSize: 14,
              color: AppColors.gray800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Select a date to schedule clinical consultations.',
            style: AppTypography.caption.copyWith(
              color: AppColors.greyText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
