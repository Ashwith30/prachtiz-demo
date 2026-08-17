import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/app_button.dart';

class DataErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const DataErrorWidget({
    super.key,
    this.errorMessage = 'An unexpected error occurred while loading data.',
    this.onRetry,
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
            decoration: const BoxDecoration(
              color: AppColors.dangerLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Load Failed',
            style: AppTypography.bodySemibold.copyWith(
              fontSize: 16,
              color: AppColors.gray800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: AppTypography.body.copyWith(
              color: AppColors.greyText,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Retry Connection',
              variant: AppButtonVariant.danger,
              onPressed: onRetry,
              height: 40.0,
            ),
          ],
        ],
      ),
    );
  }
}
