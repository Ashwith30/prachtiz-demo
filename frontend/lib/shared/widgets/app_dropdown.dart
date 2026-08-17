import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final String? labelText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const AppDropdown({
    super.key,
    this.value,
    this.labelText,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: AppTypography.body.copyWith(color: AppColors.gray900),
      decoration: InputDecoration(
        labelText: labelText,
        isDense: true,
      ),
    );
  }
}
