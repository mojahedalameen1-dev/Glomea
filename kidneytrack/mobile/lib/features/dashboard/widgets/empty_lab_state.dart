import 'package:flutter/material.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

class EmptyLabState extends StatelessWidget {
  final VoidCallback onAction;

  const EmptyLabState({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderBase.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.analytics_outlined,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'لا توجد تحاليل طبية بعد',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف أول نتائجك ليتمكن التطبيق من تحليل حالتك وتقديم تنبيهات ذكية 💚',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إضافة أول تحليل'),
          ),
        ],
      ),
    );
  }
}
