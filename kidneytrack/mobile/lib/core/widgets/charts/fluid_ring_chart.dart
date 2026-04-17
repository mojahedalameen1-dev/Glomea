import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/animations/count_up_animation.dart';

class FluidRingChart extends StatelessWidget {
  final int currentMl;
  final int limitMl;
  final bool animated;
  final double size;

  const FluidRingChart({
    super.key,
    required this.currentMl,
    required this.limitMl,
    this.animated = true,
    this.size = 180,
  });

  double get percent => math.min(1.0, currentMl / limitMl);

  Color get progressColor {
    if (percent < 0.8) return AppColors.primary;
    if (percent < 1.0) return AppColors.textWarning;
    return AppColors.textCritical;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveSize = math.min(
            size, math.min(constraints.maxWidth, constraints.maxHeight));

        return CircularPercentIndicator(
          radius: effectiveSize / 2,
          lineWidth: effectiveSize * 0.08,
          percent: percent,
          animation: animated,
          animationDuration: 1200,
          curve: Curves.easeOutCubic,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          linearGradient: LinearGradient(
            colors: percent < 0.8
                ? <Color>[
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ]
                : percent < 1.0
                    ? <Color>[AppColors.textWarning, Colors.orangeAccent]
                    : <Color>[AppColors.textCritical, Colors.redAccent],
          ),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CountUpText(
                endValue: currentMl.toDouble(),
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: effectiveSize * 0.22,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                'مل',
                style: AppTextStyles.bodyS.copyWith(
                  fontSize: effectiveSize * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: effectiveSize * 0.4,
                height: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 4),
              Text(
                'من $limitMl مل',
                style: AppTextStyles.bodyS
                    .copyWith(fontSize: effectiveSize * 0.08),
              ),
            ],
          ),
        );
      },
    );
  }
}
