import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/medical_models.dart';

class HealthIQCard extends StatelessWidget {
  final double egfr;
  final KidneyStageInfo stage;

  const HealthIQCard({
    super.key,
    required this.egfr,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (egfr / 120).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.premiumCardDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: stage.color.withValues(alpha: 0.08),
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
                    color: isDark ? AppColors.textSecondaryDark : AppColors.premiumTextSub,
                  ),
                ),
                const Gap(8),
                Text(
                  stage.label,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 24,
                    color: isDark ? Colors.white : AppColors.premiumTextMain,
                  ),
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: stage.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'المرحلة ${stage.stage}',
                    style: AppTextStyles.label.copyWith(
                      color: stage.color,
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
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(stage.color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    egfr.toStringAsFixed(0),
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 28,
                      color: stage.color,
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
