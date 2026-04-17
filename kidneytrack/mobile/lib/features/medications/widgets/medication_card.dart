import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidneytrack_mobile/features/medications/models/medication.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/providers/interaction_provider.dart';
import 'package:kidneytrack_mobile/core/services/medication_warning_engine.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

class MedicationCard extends ConsumerWidget {
  final Medication medication;
  final VoidCallback? onTap;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risksMapAsync = ref.watch(medicationRisksProvider);
    final List<MedicationRiskResult> dynamicRisks =
        risksMapAsync.valueOrNull?[medication.id] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final hasHardcodedWarning = medication.isNephrotoxic ||
        medication.needsDoseAdjustment ||
        (medication.renalWarning != null &&
            medication.renalWarning!.isNotEmpty);

    final showWarning = hasHardcodedWarning || dynamicRisks.isNotEmpty;

    Color indicatorColor = AppColors.primary;
    String severityLabel = '';
    if (dynamicRisks.any((r) => r.severity == Severity.critical) ||
        medication.isNephrotoxic) {
      indicatorColor = AppColors.textCritical;
      severityLabel = l10n.highRisk;
    } else if (dynamicRisks.any((r) => r.severity == Severity.warning) ||
        medication.needsDoseAdjustment) {
      indicatorColor = AppColors.textWarning;
      severityLabel = l10n.medicalWarning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showWarning
              ? indicatorColor.withValues(alpha: 0.3)
              : AppColors.borderBase.withValues(alpha: 0.1),
          width: showWarning ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showWarning)
                Container(
                  width: 6,
                  color: indicatorColor,
                ),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medication.name,
                                    style:
                                        AppTextStyles.h3.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    medication.dose,
                                    style: AppTextStyles.bodyS.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildFrequencyBadge(
                                context, medication.frequency, l10n),
                          ],
                        ),
                        if (severityLabel.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _SeverityBadge(
                              label: severityLabel, color: indicatorColor),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        _buildInfoRow(
                          Icons.access_time_filled_rounded,
                          l10n.scheduleLabel(medication.times.join(' ، ')),
                        ),
                        if (dynamicRisks.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...dynamicRisks.map((risk) => _buildWarningBox(
                                risk.severity == Severity.critical
                                    ? AppColors.textCritical
                                    : AppColors.textWarning,
                                risk.safetyMessage,
                              )),
                        ] else if (showWarning &&
                            medication.renalWarning != null) ...[
                          const SizedBox(height: 12),
                          _buildWarningBox(
                              indicatorColor, medication.renalWarning!),
                        ],
                        if (medication.notes?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.sticky_note_2_rounded,
                            medication.notes!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyBadge(
      BuildContext context, String frequency, AppLocalizations l10n) {
    final label = frequency == 'daily' ? l10n.frequencyDaily : frequency;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16, color: AppColors.textSecondary.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBox(Color color, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_problem_rounded, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.security_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
