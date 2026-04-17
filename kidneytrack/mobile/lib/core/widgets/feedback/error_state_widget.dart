import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ErrorStateWidget extends StatelessWidget {
  final String messageAr;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.messageAr,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.criticalRed,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ ما',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              messageAr,
              style: AppTextStyles.bodyM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
