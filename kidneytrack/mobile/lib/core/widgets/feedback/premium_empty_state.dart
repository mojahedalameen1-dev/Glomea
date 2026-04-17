import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color baseColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.baseColor = AppColors.primary,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Visual Header
            Stack(
              alignment: Alignment.center,
              children: [
                // Background Glowing Halo
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        baseColor.withValues(alpha: 0.15),
                        baseColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: 3.seconds,
                        curve: Curves.easeInOut)
                    .fade(begin: 0.6, end: 0.2),

                // Secondary Rotating Halo
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: baseColor.withValues(alpha: 0.1),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 10.seconds),

                // The Central Icon with specific animations
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: baseColor,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .shimmer(
                        delay: 1.seconds,
                        duration: 2.seconds,
                        color: baseColor.withValues(alpha: 0.2))
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .moveY(
                        begin: -8,
                        end: 8,
                        duration: 2.seconds,
                        curve: Curves.easeInOut),
              ],
            ),

            const Gap(40),

            // Text content with staggered animation
            Text(
              title,
              style: AppTextStyles.h1.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .moveY(begin: 20, end: 0),

            const Gap(12),

            Text(
              subtitle,
              style:
                  AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms)
                .moveY(begin: 15, end: 0),

            if (onAction != null && actionLabel != null) ...[
              const Gap(40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(actionLabel!,
                      style: AppTextStyles.h2.copyWith(color: Colors.white)),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms)
                  .scale(delay: 800.ms, curve: Curves.easeOutBack),
            ],
          ],
        ),
      ),
    );
  }
}
