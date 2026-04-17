import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

class AchievementCelebrationOverlay extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementCelebrationOverlay({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  static void show(BuildContext context, Achievement achievement) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, _, __) => AchievementCelebrationOverlay(
        achievement: achievement,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        onTap: onDismiss,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✨ Particles (Simulated with icons)
              const Text('✨ 🌟 ✨', style: TextStyle(fontSize: 24))
                  .animate(onPlay: (c) => c.repeat())
                  .scale(begin: const Offset(1,1), end: const Offset(2,2), duration: 1.seconds)
                  .fadeOut(),
              
              const Gap(20),
              
              // Achievement Badge
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
                child: Center(
                  child: Text(achievement.icon, style: const TextStyle(fontSize: 80)),
                ),
              ).animate()
               .scale(duration: 600.ms, curve: Curves.elasticOut)
               .rotate(begin: -0.2, end: 0, duration: 600.ms),
              
              const Gap(32),
              
              Text(
                'إنجاز جديد!',
                style: AppTextStyles.h1.copyWith(color: AppColors.warningAmber, fontSize: 24),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              
              const Gap(12),
              
              Text(
                achievement.title,
                style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32),
              ).animate().fadeIn(delay: 600.ms).scale(),
              
              const Gap(16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyM.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 18),
                ),
              ).animate().fadeIn(delay: 800.ms),
              
              const Gap(64),
              
              Text(
                'انقر للإغلاق',
                style: AppTextStyles.bodyS.copyWith(color: Colors.white54),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
