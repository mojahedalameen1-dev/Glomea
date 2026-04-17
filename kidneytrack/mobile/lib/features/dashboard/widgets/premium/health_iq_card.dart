import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/medical_models.dart';

class HealthIQCard extends StatelessWidget {
  final double? egfr;
  final KidneyStageInfo? stage;

  const HealthIQCard({
    super.key,
    this.egfr,
    this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Safety check for null data
    final hasData = egfr != null && stage != null;
    final displayEgfr = egfr ?? 0.0;
    final displayStage = stage ?? KidneyStageInfo(
      stage: 'قيد التقييم',
      label: 'أدخل التحاليل للتقييم',
      color: Colors.grey,
      risk: 'أدخل التحاليل للتقييم',
    );
    
    final progress = (displayEgfr / 120).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.premiumCardDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark || !hasData
            ? null
            : [
                BoxShadow(
                  color: displayStage.color.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مؤشر صحة الكلى',
                  style: AppTextStyles.label.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.premiumTextSub,
                  ),
                ),
                const Gap(8),
                Text(
                  displayStage.label,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: hasData ? 24 : 18,
                    color: isDark ? Colors.white : AppColors.premiumTextMain,
                  ),
                ),
                const Gap(12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: displayStage.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasData ? 'المرحلة ${displayStage.stage}' : 'بيانات ناقصة',
                    style: AppTextStyles.label.copyWith(
                      color: displayStage.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: hasData ? value : 0,
                    strokeWidth: 10,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hasData ? displayStage.color : Colors.grey[300]!,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasData ? displayEgfr.toStringAsFixed(0) : '--',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 32,
                      color: hasData ? displayStage.color : Colors.grey,
                    ),
                  ),
                  Text(
                    'eGFR',
                    style: AppTextStyles.bodyS.copyWith(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: -5,
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/icons/3d/kidney.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, _, __) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
