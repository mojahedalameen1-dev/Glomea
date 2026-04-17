import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';
import 'package:kidneytrack_mobile/core/models/medical_models.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_shadows.dart';

class MedicalInsightContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const MedicalInsightContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.borderBaseDark
              : AppColors.borderBase.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : AppShadows.elev1,
      ),
      child: child,
    );
  }
}

class EGFRCard extends StatelessWidget {
  final double? egfr;
  final KidneyStageInfo? stage;

  const EGFRCard({super.key, this.egfr, this.stage});

  @override
  Widget build(BuildContext context) {
    if (egfr == null || stage == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return MedicalInsightContainer(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: (egfr! / 120).clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: AppColors.borderBase.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(stage!.color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                egfr!.toStringAsFixed(0),
                style: AppTextStyles.displayLarge.copyWith(
                  color: stage!.color,
                  fontSize: 36,
                ),
              ),
            ],
          ),
          const Gap(24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.kidneyEfficiency,
                  style: AppTextStyles.label,
                ),
                const Gap(4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stage!.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.kidneyStageDisplay(stage!.stage, stage!.label),
                    style: AppTextStyles.bodyS.copyWith(
                      color: stage!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FluidOverloadCard extends StatelessWidget {
  final double? overloadKg;
  final double? dryWeight;
  final double? currentWeight;

  const FluidOverloadCard({
    super.key,
    this.overloadKg,
    this.dryWeight,
    this.currentWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (overloadKg == null || dryWeight == null || currentWeight == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWarning = overloadKg! > 1.5;
    final color = isWarning ? AppColors.textCritical : AppColors.primary;

    final l10n = AppLocalizations.of(context)!;
    return MedicalInsightContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.fluidOverload, style: AppTextStyles.label),
              Text(
                '${overloadKg! > 0 ? "+" : ""}${overloadKg!.toStringAsFixed(1)} kg',
                style: AppTextStyles.metricValue.copyWith(
                  color: isWarning
                      ? (isDark
                          ? AppColors.textCriticalDark
                          : AppColors.textCritical)
                      : AppColors.primary,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (overloadKg! / 5).clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: isDark
                  ? AppColors.borderBaseDark
                  : AppColors.borderBase.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.dryWeight}: ${dryWeight!.toStringAsFixed(1)}',
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                '${l10n.currentWeight}: ${currentWeight!.toStringAsFixed(1)}',
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BloodPressureCard extends StatelessWidget {
  final double avg;
  final String trend;
  final double controlRate;

  const BloodPressureCard({
    super.key,
    required this.avg,
    required this.trend,
    required this.controlRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData trendIcon;
    Color trendColor;

    if (trend == 'rising') {
      trendIcon = Icons.trending_up;
      trendColor = AppColors.textCritical;
    } else if (trend == 'falling') {
      trendIcon = Icons.trending_down;
      trendColor = AppColors.textSuccess;
    } else {
      trendIcon = Icons.trending_flat;
      trendColor = AppColors.primary;
    }

    final l10n = AppLocalizations.of(context)!;
    return MedicalInsightContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(trendIcon, color: trendColor, size: 28),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.bpAverage, style: AppTextStyles.label),
                Text(
                  '${avg.toStringAsFixed(0)} mmHg',
                  style: AppTextStyles.metricValue.copyWith(fontSize: 28),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controlRate.toStringAsFixed(0)}%',
                style: AppTextStyles.h2.copyWith(
                  color: isDark
                      ? AppColors.textSuccessDark
                      : AppColors.textSuccess,
                ),
              ),
              Text(
                l10n.controlRate,
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PotassiumDailyCard extends StatelessWidget {
  final PotassiumDailyStatus status;

  const PotassiumDailyCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    if (status.status == 'danger') {
      color = AppColors.textCritical;
    } else if (status.status == 'warning') {
      color = AppColors.textWarning;
    } else {
      color = AppColors.textSuccess;
    }

    final l10n = AppLocalizations.of(context)!;
    return MedicalInsightContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.dailyPotassium, style: AppTextStyles.label),
              Text(
                '${status.consumed.toStringAsFixed(0)} / ${status.limit} mg',
                style: AppTextStyles.h3.copyWith(
                  color: isDark
                      ? (status.status == 'danger'
                          ? AppColors.textCriticalDark
                          : (status.status == 'warning'
                              ? AppColors.textWarningDark
                              : AppColors.textSuccessDark))
                      : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (status.percentage / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: isDark
                  ? AppColors.borderBaseDark
                  : AppColors.borderBase.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const Gap(12),
          Text(
            '${l10n.remaining}: ${status.remaining.toStringAsFixed(0)} mg',
            style: AppTextStyles.bodyS.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class EarlyDeteriorationAlert extends StatelessWidget {
  final String message;

  const EarlyDeteriorationAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCriticalDark : AppColors.bgCritical,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.borderCriticalDark
              : AppColors.borderCritical.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? AppColors.textCriticalDark : AppColors.textCritical,
            size: 32,
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.urgentMedicalAlert,
                  style: AppTextStyles.label.copyWith(
                    color: isDark
                        ? AppColors.textCriticalDark
                        : AppColors.textCritical,
                    fontSize: 16,
                  ),
                ),
                const Gap(4),
                Text(
                  message,
                  style: AppTextStyles.bodyM.copyWith(
                    color: isDark
                        ? AppColors.textCriticalDark
                        : AppColors.textCritical,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}
