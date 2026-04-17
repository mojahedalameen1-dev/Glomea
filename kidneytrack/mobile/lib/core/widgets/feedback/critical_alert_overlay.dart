import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../animations/glomea_animations.dart';

class CriticalAlertOverlay extends StatefulWidget {
  final String indicatorName;
  final double value;
  final String unit;
  final String message;
  final VoidCallback onDismiss;

  const CriticalAlertOverlay({
    super.key,
    required this.indicatorName,
    required this.value,
    required this.unit,
    required this.message,
    required this.onDismiss,
  });

  static void show(BuildContext context, {
    required String indicatorName,
    required double value,
    required String unit,
    required String message,
    required VoidCallback onDismiss,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CriticalAlertOverlay(
          indicatorName: indicatorName,
          value: value,
          unit: unit,
          message: message,
          onDismiss: onDismiss,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
          child: child,
        );
      },
    );
  }

  @override
  State<CriticalAlertOverlay> createState() => _CriticalAlertOverlayState();
}

class _CriticalAlertOverlayState extends State<CriticalAlertOverlay> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.criticalRed.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing Kidney Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.criticalRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('🫁', style: TextStyle(fontSize: 48)),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1,1), end: const Offset(1.15, 1.15), duration: 800.ms)
               .shimmer(color: AppColors.criticalRed.withValues(alpha: 0.3)),
              
              const Gap(24),
              Text(
                '⚡ تنبيه عاجل',
                style: AppTextStyles.h1.copyWith(color: AppColors.criticalRed, fontSize: 24),
              ).animate().shake(hz: 4),
              
              const Gap(16),
              Text(
                'مستوى ${widget.indicatorName}',
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
              ),
              
              const Gap(16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.criticalRed, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlomeaAnimations.countUp(
                      value: widget.value, 
                      style: AppTextStyles.h1.copyWith(fontSize: 32, color: AppColors.criticalRed),
                    ),
                    const Gap(8),
                    Text(widget.unit, style: AppTextStyles.bodyS),
                    const Gap(8),
                    const Icon(Icons.arrow_upward, color: AppColors.criticalRed),
                  ],
                ),
              ),

              const Gap(24),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.criticalRed,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .shimmer(color: Colors.white.withValues(alpha: 0.5), duration: 1.seconds),

              const Gap(24),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM.copyWith(height: 1.5),
              ),

              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                    widget.onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.criticalRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('فهمت وسأتابع وضعي ✓', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
