import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidneytrack_mobile/features/medications/providers/medications_provider.dart';
import 'package:kidneytrack_mobile/features/medications/models/medication_log.dart';
import 'package:kidneytrack_mobile/features/medications/widgets/medication_log_tile.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

class TodayDosesWidget extends ConsumerWidget {
  const TodayDosesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationsProvider);
    final l10n = AppLocalizations.of(context)!;
    final sortedLogs = List<MedicationLog>.from(state.todayLogs)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (sortedLogs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.bgSurfaceDark 
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.borderBaseDark.withValues(alpha: 0.1) 
                : AppColors.borderBase.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_liquid_outlined, 
                size: 32, 
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noScheduledDosesToday,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            l10n.todayDoses,
            style: AppTextStyles.h3,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedLogs.length,
          itemBuilder: (context, index) {
            final log = sortedLogs[index];
            final medication = state.medications.firstWhere(
              (m) => m.id == log.medicationId,
              orElse: () => throw Exception('Medication not found'),
            );
            return MedicationLogTile(log: log, medication: medication);
          },
        ),
      ],
    );
  }
}
