import 'package:flutter/material.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_dimensions.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

enum ActionButtonStyle {
  primary,
  secondary,
  critical,
}

class SafeActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ActionButtonStyle style;
  final bool isLoading;
  final Widget? icon;

  const SafeActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = ActionButtonStyle.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    BorderSide border = BorderSide.none;

    switch (style) {
      case ActionButtonStyle.critical:
        bgColor = (isDark ? AppColors.bgCriticalDark : AppColors.bgCritical)
            .withValues(alpha: 0.8);
        textColor =
            isDark ? AppColors.textCriticalDark : AppColors.textCritical;
        border = BorderSide(
            color:
                (isDark ? AppColors.borderCritical : AppColors.borderCritical)
                    .withValues(alpha: 0.5));
        break;
      case ActionButtonStyle.secondary:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        border = BorderSide(
            color: isDark ? AppColors.borderBaseDark : AppColors.borderBase);
        break;
      case ActionButtonStyle.primary:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 56, // Senior Accessibility Target
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            side: border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padM),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppDimensions.padS),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
