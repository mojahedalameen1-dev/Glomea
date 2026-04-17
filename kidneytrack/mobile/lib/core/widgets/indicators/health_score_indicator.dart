import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'dart:math' as math;
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_shadows.dart';
import 'package:kidneytrack_mobile/core/animations/glomea_animations.dart';

class HealthScoreIndicator extends StatefulWidget {
  final int score;

  const HealthScoreIndicator({
    super.key,
    required this.score,
  });

  @override
  State<HealthScoreIndicator> createState() => _HealthScoreIndicatorState();
}

class _HealthScoreIndicatorState extends State<HealthScoreIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color scoreColor;
    String label;
    if (widget.score >= 80) { 
      scoreColor = isDark ? AppColors.textSuccessDark : AppColors.textSuccess; 
      label = 'ممتاز — استمر على هذا'; 
    }
    else if (widget.score >= 60) { 
      scoreColor = isDark ? AppColors.textInfoDark : AppColors.textInfo; 
      label = 'جيد جداً'; 
    }
    else if (widget.score >= 40) { 
      scoreColor = isDark ? AppColors.textWarningDark : AppColors.textWarning; 
      label = 'حالة متوسطة'; 
    }
    else { 
      scoreColor = isDark ? AppColors.textCriticalDark : AppColors.textCritical; 
      label = 'يحتاج اهتمام طبي'; 
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderBaseDark : AppColors.borderBase.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : AppShadows.elev1,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(220, 180),
                      painter: ArcGaugePainter(
                        progress: _animation.value * (widget.score / 100),
                        color: scoreColor,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  child: Column(
                    children: [
                      GlomeaAnimations.countUp(
                        value: widget.score.toDouble(), 
                        style: AppTextStyles.metricValue.copyWith(
                          fontSize: 48, 
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        decimals: 0,
                      ),
                      Text(
                        'درجة صحتك اليوم', 
                        style: AppTextStyles.bodyS.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: scoreColor, fontSize: 16),
            ),
          ).animate().fadeIn().scale(),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildZoneDot(isDark ? AppColors.textCriticalDark : AppColors.textCritical, 'قلق', isDark),
              const Gap(24),
              _buildZoneDot(isDark ? AppColors.textWarningDark : AppColors.textWarning, 'تحذير', isDark),
              const Gap(24),
              _buildZoneDot(isDark ? AppColors.textSuccessDark : AppColors.textSuccess, 'مثالي', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneDot(Color color, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8, 
          height: 8, 
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(8),
        Text(
          text, 
          style: AppTextStyles.bodyS.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  ArcGaugePainter({
    required this.progress, 
    required this.color, 
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = math.min(size.width / 2, size.height - 30);
    
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final backgroundPaint = Paint()
      ..color = isDark ? AppColors.borderBaseDark : AppColors.borderBase.withValues(alpha: 0.1)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ArcGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}
