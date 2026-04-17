import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_types.dart';

class StatusBadge extends StatelessWidget {
  final IndicatorStatus status;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  Color get color {
    switch (status) {
      case IndicatorStatus.safe:
        return AppColors.safeGreen;
      case IndicatorStatus.warning:
        return AppColors.warningAmber;
      case IndicatorStatus.critical:
        return AppColors.criticalRed;
    }
  }

  String get label {
    switch (status) {
      case IndicatorStatus.safe:
        return 'آمن';
      case IndicatorStatus.warning:
        return 'تحذير';
      case IndicatorStatus.critical:
        return 'خطر';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 8,
        vertical: isLarge ? 6 : 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          fontSize: isLarge ? 14 : 10,
        ),
      ),
    );
  }
}
