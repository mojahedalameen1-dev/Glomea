import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kidneytrack_mobile/features/medications/models/medication.dart';
import 'package:kidneytrack_mobile/features/medications/models/medication_log.dart';
import 'package:kidneytrack_mobile/features/medications/providers/medications_provider.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

class MedicationLogTile extends ConsumerWidget {
  final MedicationLog log;
  final Medication medication;

  const MedicationLogTile({
    super.key,
    required this.log,
    required this.medication,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTaken = log.status == 'taken';
    final isMissed = log.status == 'missed';
    final timeStr = DateFormat('HH:mm').format(log.scheduledAt);

    Color surfaceColor = AppColors.bgSurface;
    Color borderColor = AppColors.borderBase.withValues(alpha: 0.1);
    Color statusColor = AppColors.primary;
    IconData statusIcon = Icons.access_time_rounded;
    String statusLabel = 'قيد الانتظار';

    if (isTaken) {
      statusColor = AppColors.textSuccess;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'تم الأخذ';
      surfaceColor = AppColors.textSuccess.withValues(alpha: 0.04);
      borderColor = AppColors.textSuccess.withValues(alpha: 0.15);
    } else if (isMissed) {
      statusColor = AppColors.textWarning;
      statusIcon = Icons.error_outline_rounded;
      statusLabel = 'فاتت الجرعة';
      surfaceColor = AppColors.textWarning.withValues(alpha: 0.04);
      borderColor = AppColors.textWarning.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.bgSurfaceDark
            : surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderBaseDark.withValues(alpha: 0.1)
              : borderColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16,
                        decoration: isTaken ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${medication.dose} • $timeStr',
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(
                          label: statusLabel,
                          color: statusColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isTaken)
                ElevatedButton(
                  onPressed: () => ref
                      .read(medicationsProvider.notifier)
                      .markAsTaken(log.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(80, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تم',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
