import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class BmiLiveCard extends StatefulWidget {
  final double heightCm;
  final double weightKg;
  final double? dryWeightKg;
  final bool isDialysis;
  final bool showPulse;

  const BmiLiveCard({
    super.key,
    required this.heightCm,
    required this.weightKg,
    this.dryWeightKg,
    this.isDialysis = false,
    this.showPulse = false,
  });

  @override
  State<BmiLiveCard> createState() => _BmiLiveCardState();
}

class _BmiLiveCardState extends State<BmiLiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(BmiLiveCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !oldWidget.showPulse) {
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double get _bmi =>
      widget.weightKg / ((widget.heightCm / 100) * (widget.heightCm / 100));

  (String, Color) get _bmiStatus {
    if (_bmi < 18.5) return ('وزن منخفض', Colors.blue);
    if (_bmi < 25.0) return ('وزن طبيعي ✓', AppColors.safeGreen);
    if (_bmi < 30.0) return ('وزن مرتفع قليلاً', AppColors.warningAmber);
    return ('يحتاج اهتمام', AppColors.textWarning);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.heightCm <= 0 || widget.weightKg <= 0)
      return const SizedBox.shrink();

    final status = _bmiStatus;
    final diff = widget.dryWeightKg != null
        ? (widget.weightKg - widget.dryWeightKg!)
        : 0.0;
    final closeToDry = diff.abs() < 0.5;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: status.$2.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: status.$2.withValues(alpha: 0.2), width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('مؤشر كتلة الجسم',
                        style: AppTextStyles.bodyS
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                          begin: _bmi,
                          end: _bmi), // Dummy for initial, we react to changes
                      duration: const Duration(milliseconds: 500),
                      builder: (context, val, _) {
                        return Text(
                          val.toStringAsFixed(1),
                          style: AppTextStyles.h1
                              .copyWith(fontSize: 48, color: status.$2),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Container(
                  height: 60,
                  width: 2,
                  color: status.$2.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          status.$1,
                          key: ValueKey(status.$1),
                          style: AppTextStyles.h3
                              .copyWith(color: status.$2, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مؤشر استرشادي لوزنك وتوزيعه',
                        style: AppTextStyles.bodyS.copyWith(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.dryWeightKg != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    closeToDry
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 16,
                    color: closeToDry
                        ? AppColors.safeGreen
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    closeToDry
                        ? 'أنت قريب جداً من وزنك الجاف'
                        : 'أنت أعلى من وزنك الجاف بـ ${diff.toStringAsFixed(1)} كجم',
                    style: AppTextStyles.bodyS.copyWith(
                      color: closeToDry
                          ? AppColors.safeGreen
                          : AppColors.textSecondary,
                      fontWeight:
                          closeToDry ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
