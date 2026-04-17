import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionLabel ?? 'الكل',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
