import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/footer_stat_model.dart';

class FooterSection extends StatelessWidget {
  final List<FooterStatModel> stats;

  const FooterSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType.isMobile) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: stats.map((stat) => _buildStatItem(stat)).toList(),
          );
        } else {
          return Row(
            children: stats
                .map((stat) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildStatItem(stat),
                      ),
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildStatItem(FooterStatModel stat) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  stat.value,
                  style: AppTypography.bodySemibold.copyWith(
                    fontSize: 14,
                    color: AppColors.gray800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
