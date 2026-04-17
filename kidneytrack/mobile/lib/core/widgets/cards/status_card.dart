import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_types.dart';
import '../../animations/count_up_animation.dart';
import '../../animations/micro_interactions.dart';
import '../indicators/threshold_bar.dart';
import '../charts/sparkline_chart.dart';

class StatusCard extends StatelessWidget {
  final String indicatorName;
  final double value;
  final String unit;
  final IndicatorStatus status;
  final List<double> sparklineData;
  final ThresholdRange thresholds;
  final double? delta;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.indicatorName,
    required this.value,
    required this.unit,
    required this.status,
    required this.sparklineData,
    required this.thresholds,
    this.delta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color statusColor;
    String statusLabelAr;
    switch (status) {
      case IndicatorStatus.safe:
        statusColor = isDark ? AppColors.textSuccessDark : AppColors.textSuccess;
        statusLabelAr = 'مستقر';
        break;
      case IndicatorStatus.warning:
        statusColor = isDark ? AppColors.textWarningDark : AppColors.textWarning;
        statusLabelAr = 'تنبيه';
        break;
      case IndicatorStatus.critical:
        statusColor = isDark ? AppColors.textCriticalDark : AppColors.textCritical;
        statusLabelAr = 'حرج';
        break;
    }

    return TapScale(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderBaseDark : AppColors.borderBase.withValues(alpha: 0.1),
          ),
          boxShadow: isDark ? null : AppShadows.elev1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                _StatusBadge(status: status, color: statusColor, text: statusLabelAr, isDark: isDark),
              ],
            ),
            const Gap(12),
            Text(
              indicatorName,
              style: AppTextStyles.label.copyWith(
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 80),
                  child: CountUpText(
                    endValue: value,
                    decimals: 1,
                    style: AppTextStyles.metricValue.copyWith(
                      fontSize: 24, 
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  unit, 
                  style: AppTextStyles.unit.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 28,
              child: SparklineChart(
                values: sparklineData,
                color: statusColor.withValues(alpha: 0.4),
              ),
            ),
            const Gap(12),
            ThresholdBar(
              value: value,
              min: thresholds.warningMin,
              max: thresholds.warningMax,
              safeMin: thresholds.safeMin,
              safeMax: thresholds.safeMax,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}

class _StatusBadge extends StatelessWidget {
  final IndicatorStatus status;
  final Color color;
  final String text;
  final bool isDark;

  const _StatusBadge({
    required this.status, 
    required this.color, 
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyS.copyWith(
          color: color, 
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
