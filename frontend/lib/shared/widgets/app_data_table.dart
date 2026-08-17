import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double columnSpacing;
  final double headingRowHeight;
  final double dataRowHeight;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnSpacing = 24.0,
    this.headingRowHeight = 38.0,
    this.dataRowHeight = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: AppColors.divider,
        ),
        child: DataTable(
          columnSpacing: columnSpacing,
          headingRowHeight: headingRowHeight,
          dataRowHeight: dataRowHeight,
          horizontalMargin: 12,
          headingTextStyle: AppTypography.caption.copyWith(
            color: AppColors.gray500,
            fontWeight: FontWeight.bold,
          ),
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}
