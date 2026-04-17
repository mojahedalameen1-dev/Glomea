import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SuccessScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onComplete;

  const SuccessScreen({
    super.key,
    this.title = 'تم بنجاح!',
    this.message = 'تم حفظ بياناتك بنجاح في السجل الطبي 💚',
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.safeGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: AppColors.safeGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0, 0),
                      ),

                  // Halo effect
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.safeGreen, width: 2),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(delay: 400.ms)
                      .scale(
                        duration: 800.ms,
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.5, 1.5),
                      )
                      .fadeOut(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(title, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('المواصلة',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ).animate(delay: 1.seconds).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
