import 'package:flutter/material.dart';
import '../widgets/app_card.dart';
import 'shimmer_placeholder.dart';

class SummaryCardSkeleton extends StatelessWidget {
  const SummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 154.0, // Matches AppDimensions.summaryCardHeight
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerPlaceholder(
                width: 100.0,
                height: 16.0,
              ),
              ShimmerPlaceholder(
                width: 36.0,
                height: 36.0,
                borderRadius: BorderRadius.circular(18),
              ),
            ],
          ),
          const ShimmerPlaceholder(
            width: 120.0,
            height: 36.0,
          ),
          const ShimmerPlaceholder(
            width: 160.0,
            height: 14.0,
          ),
        ],
      ),
    );
  }
}
