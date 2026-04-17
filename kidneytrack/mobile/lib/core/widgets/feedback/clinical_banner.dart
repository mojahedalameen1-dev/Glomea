import 'package:flutter/material.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_dimensions.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_types.dart';

class ClinicalBanner extends StatelessWidget {
  final String title;
  final String message;
  final MedicalSeverity severity;
  final VoidCallback? onAction;
  final String? actionLabel;

  const ClinicalBanner({
    super.key,
    required this.title,
    required this.message,
    this.severity = MedicalSeverity.info,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color accentColor;
    Color bgColor;
    IconData icon;

    switch (severity) {
      case MedicalSeverity.warning:
        accentColor = isDark ? AppColors.borderWarning : AppColors.borderWarning;
        bgColor = isDark ? AppColors.bgWarningDark : AppColors.bgWarning;
        icon = Icons.warning_amber_rounded;
        break;
      case MedicalSeverity.critical:
        accentColor = isDark ? AppColors.borderCritical : AppColors.borderCritical;
        bgColor = isDark ? AppColors.bgCriticalDark : AppColors.bgCritical;
        icon = Icons.gpp_maybe_rounded;
        break;
      case MedicalSeverity.info:
      case MedicalSeverity.normal:
        accentColor = isDark ? AppColors.borderInfo : AppColors.borderInfo;
        bgColor = isDark ? AppColors.bgInfoDark : AppColors.bgInfo;
        icon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border(
           left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.padM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(width: AppDimensions.padM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(message, style: AppTextStyles.bodyS),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: AppDimensions.padS),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionLabel!,
                      style: AppTextStyles.label.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
