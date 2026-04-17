import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PremiumStatusCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String iconPath;
  final Color accentColor;
  final bool isWarning;

  const PremiumStatusCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.iconPath,
    required this.accentColor,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.premiumCardDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  errorBuilder: (context, _, __) => Icon(
                    Icons.favorite,
                    size: 20,
                    color: accentColor,
                  ),
                ),
              ),
              if (isWarning)
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.textCritical, size: 20),
            ],
          ),
          const Gap(16),
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.premiumTextSub,
            ),
          ),
          const Gap(4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.metricValue.copyWith(
                  fontSize: 28,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const Gap(4),
              Text(
                unit,
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Gap(12),
          // Simple Sparkline replacement (visual)
          SizedBox(
            height: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(10, (index) {
                final height = (index % 3 + 1) * 4.0;
                return Container(
                  width: 4,
                  height: height,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color:
                        accentColor.withValues(alpha: index == 9 ? 1.0 : 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
