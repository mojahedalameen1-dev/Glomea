import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String lottieAsset;
  final String titleAr;
  final String subtitleAr;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.lottieAsset,
    required this.titleAr,
    required this.subtitleAr,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottieAsset,
            height: 200,
            repeat: true,
          ),
          const SizedBox(height: 24),
          Text(
            titleAr,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitleAr,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
// Note: asset paths like 'assets/lottie/empty_chart.json' are expected.
