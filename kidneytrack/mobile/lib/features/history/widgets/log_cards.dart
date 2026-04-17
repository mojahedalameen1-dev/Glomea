import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_types.dart';
import '../../../core/models/lab_result.dart';
import '../../../core/models/daily_reading.dart';
import '../../../core/models/food_consumption.dart';
import '../../medications/models/medication_log.dart';
import '../../../core/data/lab_indicators.dart';
import '../../../core/widgets/indicators/trust_badge.dart';

abstract class HistoryLogCard extends StatelessWidget {
  const HistoryLogCard({super.key});

  Widget _buildBaseContainer({
    required BuildContext context,
    required Widget child,
    bool isCritical = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final criticalColor = isDark ? AppColors.textCriticalDark : AppColors.textCritical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCritical 
            ? criticalColor.withValues(alpha: 0.5) 
            : (isDark ? AppColors.borderBaseDark : AppColors.borderBase).withValues(alpha: 0.1),
          width: isCritical ? 2 : 1,
        ),
        boxShadow: isDark ? null : AppShadows.elev1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildStatusIndicator({
    required BuildContext context,
    required MedicalSeverity severity,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color color = switch (severity) {
      MedicalSeverity.normal => isDark ? AppColors.textSuccessDark : AppColors.textSuccess,
      MedicalSeverity.info => AppColors.primary,
      MedicalSeverity.warning => isDark ? AppColors.textWarningDark : AppColors.textWarning,
      MedicalSeverity.critical => isDark ? AppColors.textCriticalDark : AppColors.textCritical,
    };

    final IconData icon = switch (severity) {
      MedicalSeverity.normal => Icons.check_circle_outline,
      MedicalSeverity.info => Icons.info_outline,
      MedicalSeverity.warning => Icons.error_outline,
      MedicalSeverity.critical => Icons.dangerous_outlined,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class LabLogCard extends HistoryLogCard {
  final LabResult result;

  const LabLogCard({super.key, required this.result});

  MedicalSeverity _getSeverity() {
    final indicator = labIndicators[result.indicatorCode];
    if (indicator == null) return MedicalSeverity.normal;

    final val = result.value;
    final criticalMax = (indicator['criticalMax'] as num?)?.toDouble();
    final criticalMin = (indicator['criticalMin'] as num?)?.toDouble();
    final warningMax = (indicator['warningMax'] as num?)?.toDouble();
    final warningMin = (indicator['warningMin'] as num?)?.toDouble();
    final normalMax = (indicator['normalMax'] as num?)?.toDouble();
    final normalMin = (indicator['normalMin'] as num?)?.toDouble();

    if ((criticalMax != null && val >= criticalMax) || (criticalMin != null && val <= criticalMin)) {
      return MedicalSeverity.critical;
    }
    if ((warningMax != null && val >= warningMax) || (warningMin != null && val <= warningMin)) {
      return MedicalSeverity.warning;
    }
    if ((normalMax != null && val > normalMax) || (normalMin != null && val < normalMin)) {
      return MedicalSeverity.info;
    }
    return MedicalSeverity.normal;
  }

  String _getStatusLabel(MedicalSeverity severity) {
    return switch (severity) {
      MedicalSeverity.normal => 'طبيعي',
      MedicalSeverity.info => 'مرتفع قليلاً',
      MedicalSeverity.warning => 'تنبيه',
      MedicalSeverity.critical => 'حرج خطير',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final severity = _getSeverity();
    final name = labIndicators[result.indicatorCode]?['nameAr'] ?? result.indicatorCode;
    
    // Determine source
    final String sourceLabel = result.imageUrl != null ? 'موثق' : 'يدوي';
    final bool isVerified = result.imageUrl != null;

    return _buildBaseContainer(
      context: context,
      isCritical: severity == MedicalSeverity.critical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              TrustBadge(label: sourceLabel, verified: isVerified),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: result.value.toStringAsFixed(1),
                          style: AppTextStyles.metricValue.copyWith(
                            fontSize: 24,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' ${result.unit}',
                          style: AppTextStyles.unit.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    intl.DateFormat.jm('ar').format(result.recordedAt),
                    style: AppTextStyles.bodyS.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              _buildStatusIndicator(
                context: context,
                severity: severity,
                label: _getStatusLabel(severity),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VitalsLogCard extends HistoryLogCard {
  final DailyReading reading;

  const VitalsLogCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildBaseContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المؤشرات اليومية',
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                intl.DateFormat.jm('ar').format(reading.date),
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              if (reading.weightKg != null)
                _buildVitalMetric(
                  label: 'الوزن',
                  value: '${reading.weightKg}',
                  unit: 'كجم',
                  icon: Icons.scale_outlined,
                  isDark: isDark,
                ),
              if (reading.systolic != null && reading.diastolic != null)
                _buildVitalMetric(
                  label: 'الضغط',
                  value: '${reading.systolic}/${reading.diastolic}',
                  unit: 'mmHg',
                  icon: Icons.favorite_outline,
                  isDark: isDark,
                ),
              if (reading.bloodSugarMgDl != null)
                _buildVitalMetric(
                  label: 'السكر',
                  value: '${reading.bloodSugarMgDl}',
                  unit: 'mg/dL',
                  icon: Icons.water_drop_outlined,
                  isDark: isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalMetric({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: AppTextStyles.unit.copyWith(
                  fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MedicationLogCard extends HistoryLogCard {
  final MedicationLog log;

  const MedicationLogCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTaken = log.status == 'taken';
    final med = log.medication;

    return _buildBaseContainer(
      context: context,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med?.name ?? 'دواء',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                Text(
                  med?.dose ?? '',
                  style: AppTextStyles.bodyS.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusIndicator(
                context: context,
                severity: isTaken ? MedicalSeverity.normal : MedicalSeverity.warning,
                label: isTaken ? 'تم التناول' : 'فائت',
              ),
              const SizedBox(height: 4),
              Text(
                intl.DateFormat.jm('ar').format(log.scheduledAt),
                style: AppTextStyles.bodyS.copyWith(
                  fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConsumptionLogCard extends HistoryLogCard {
  final dynamic entry; // Can be FoodConsumption or FluidIntake

  const ConsumptionLogCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFood = entry is FoodConsumption;
    
    final String title = isFood ? entry.foodName : 'شرب ماء';
    final DateTime time = isFood ? entry.consumedAt : entry.loggedAt;
    final String amount = isFood ? '${entry.gramsConsumed.toStringAsFixed(0)} جم' : '${entry.amountMl} مل';
    final IconData icon = isFood ? Icons.restaurant_outlined : Icons.water_drop_outlined;

    return _buildBaseContainer(
      context: context,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isFood ? Colors.orange : Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                intl.DateFormat.jm('ar').format(time),
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amount,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              if (isFood)
                Row(
                  children: [
                    _buildMiniNutrient('بوتاسيوم', entry.potassium, isDark),
                    const SizedBox(width: 8),
                    _buildMiniNutrient('فوسفور', entry.phosphorus, isDark),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNutrient(String label, double value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.borderBaseDark : AppColors.borderBase).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 9,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}
