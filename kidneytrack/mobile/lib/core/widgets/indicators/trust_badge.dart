import 'package:flutter/material.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_dimensions.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

class TrustBadge extends StatelessWidget {
  final String label;
  final bool verified;

  const TrustBadge({
    super.key,
    required this.label,
    this.verified = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padS,
        vertical: AppDimensions.padXS,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.borderBaseDark : AppColors.borderBase).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(
          color: (isDark ? AppColors.borderBaseDark : AppColors.borderBase).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_user : Icons.info_outline,
            size: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.padXS),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              fontSize: 10,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
