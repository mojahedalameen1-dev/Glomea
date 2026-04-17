import 'package:flutter/material.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_dimensions.dart';
import 'package:kidneytrack_mobile/core/theme/app_shadows.dart';
import 'package:kidneytrack_mobile/core/theme/app_types.dart';

class MedicalCard extends StatelessWidget {
  final Widget child;
  final MedicalSeverity severity;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const MedicalCard({
    super.key,
    required this.child,
    this.severity = MedicalSeverity.normal,
    this.header,
    this.footer,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color borderColor;
    double borderWidth;
    List<BoxShadow> shadows;

    switch (severity) {
      case MedicalSeverity.info:
        bgColor = isDark ? AppColors.bgInfoDark : AppColors.bgInfo;
        borderColor = isDark ? AppColors.borderInfo : AppColors.borderInfo;
        borderWidth = 1.0;
        shadows = AppShadows.elev1;
        break;
      case MedicalSeverity.warning:
        bgColor = isDark ? AppColors.bgWarningDark : AppColors.bgWarning;
        borderColor = isDark ? AppColors.borderWarning : AppColors.borderWarning;
        borderWidth = 1.5;
        shadows = AppShadows.elev2;
        break;
      case MedicalSeverity.critical:
        bgColor = isDark ? AppColors.bgCriticalDark : AppColors.bgCritical;
        borderColor = isDark ? AppColors.borderCritical : AppColors.borderCritical;
        borderWidth = 2.0;
        shadows = AppShadows.elev3;
        break;
      case MedicalSeverity.normal:
        bgColor = isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface;
        borderColor = isDark ? AppColors.borderBaseDark : AppColors.borderBase;
        borderWidth = 0.5; // Subtle hairline
        shadows = AppShadows.elev1;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.padM),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (header != null) ...[
                  header!,
                  const SizedBox(height: AppDimensions.padM),
                ],
                child,
                if (footer != null) ...[
                  const SizedBox(height: AppDimensions.padM),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
