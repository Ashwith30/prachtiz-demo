import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/app_button.dart';

class EmptyAppointments extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyAppointments({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray200, width: 1.5),
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 40,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Appointments Found',
            style: AppTypography.bodySemibold.copyWith(
              fontSize: 16,
              color: AppColors.gray800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'There are no appointments scheduled for the selected period.',
            style: AppTypography.body.copyWith(
              color: AppColors.greyText,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Refresh',
              variant: AppButtonVariant.secondary,
              onPressed: onRefresh,
              height: 40.0,
            ),
          ],
        ],
      ),
    );
  }
}
