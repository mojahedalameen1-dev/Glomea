import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ThresholdBar extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double safeMin;
  final double safeMax;

  const ThresholdBar({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.safeMin,
    required this.safeMax,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final totalRange = max - min;

        // Safety check for division by zero
        if (totalRange <= 0) return const SizedBox.shrink();

        final safeStartValue = (safeMin - min).clamp(0, totalRange);
        final safeWidthValue =
            (safeMax - safeMin).clamp(0, totalRange - safeStartValue);

        final safeRangeStartPx = (safeStartValue / totalRange) * width;
        final safeRangeWidthPx = (safeWidthValue / totalRange) * width;

        final valuePosPct = ((value - min) / totalRange).clamp(0.0, 1.0);
        final valuePx = valuePosPct * width;

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Track
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Safe Zone (Greenish Highlight)
                Positioned(
                  left: safeRangeStartPx,
                  width: safeRangeWidthPx,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.safeGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Current Value Indicator (Circle with Glow)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  left: valuePx - 6, // Center the 12px indicator
                  top: -3, // Offset to center vertically on 6px track
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: AppColors.primary, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(min.toStringAsFixed(1),
                    style: AppTextStyles.bodyS.copyWith(
                        fontSize: 10, color: AppColors.textSecondary)),
                Text(max.toStringAsFixed(1),
                    style: AppTextStyles.bodyS.copyWith(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ],
        );
      },
    );
  }
}
// Note: In real implementation, LayoutBuilder would be used for exact positioning.
// I will refine this in the final iteration if needed.
