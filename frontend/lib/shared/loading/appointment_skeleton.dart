import 'package:flutter/material.dart';
import 'shimmer_placeholder.dart';

class AppointmentSkeleton extends StatelessWidget {
  const AppointmentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerPlaceholder(
            width: 44.0,
            height: 44.0,
            borderRadius: BorderRadius.circular(22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerPlaceholder(
                  width: 140.0,
                  height: 14.0,
                ),
                const SizedBox(height: 6),
                const ShimmerPlaceholder(
                  width: 90.0,
                  height: 10.0,
                ),
              ],
            ),
          ),
          const ShimmerPlaceholder(
            width: 70.0,
            height: 22.0,
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          const SizedBox(width: 12),
          const ShimmerPlaceholder(
            width: 32.0,
            height: 32.0,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ],
      ),
    );
  }
}
