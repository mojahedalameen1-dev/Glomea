import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_dimensions.dart';

class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppDimensions.radiusM,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF8FAFC);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const LoadingSkeleton(
              width: 180, height: 180, borderRadius: 99), // Ring
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: 4,
            itemBuilder: (context, index) =>
                const LoadingSkeleton(width: double.infinity, height: 200),
          ),
        ],
      ),
    );
  }
}

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingSkeleton(width: double.infinity, height: 200);
  }
}
