import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'dart:math';

import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

class FluidCupsWidget extends StatefulWidget {
  final int totalCups;
  final int completedCups;
  final double partialFill;
  final ValueChanged<int>? onAddCup;

  const FluidCupsWidget({
    super.key,
    this.totalCups = 6,
    this.completedCups = 0,
    this.partialFill = 0.0,
    this.onAddCup,
  });

  @override
  State<FluidCupsWidget> createState() => _FluidCupsWidgetState();
}

class _FluidCupsWidgetState extends State<FluidCupsWidget> {
  int _localCompleted = 0;
  int? _animatingIndex;
  int _lastCupSize = 250; // Dynamic cup size

  @override
  void initState() {
    super.initState();
    _localCompleted = widget.completedCups;
  }

  @override
  void didUpdateWidget(FluidCupsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedCups != oldWidget.completedCups) {
      setState(() {
        _localCompleted = widget.completedCups;
      });
    }
  }

  void _onAddIntakeRequest() {
    if (_localCompleted >= widget.totalCups) {
      // Allow overflow or restrict? Usually better to allow overflow but show completion
      // For now, let's allow up to totalCups + 4 overflow
      if (_localCompleted >= widget.totalCups + 4) return;
    }

    HapticFeedback.lightImpact();

    // 1. Optimistic UI update
    setState(() {
      _localCompleted++;
      _animatingIndex = _localCompleted - 1;
    });

    // 2. Clear animating index after visual fill
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _animatingIndex = null);
    });

    // 3. Show Undo SnackBar
    _showUndoSnackBar();
  }

  void _showUndoSnackBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('تم إضافة كوب ($_lastCupSize مل)'),
              ],
            ),
            action: SnackBarAction(
              label: 'تراجع',
              textColor: Colors.orangeAccent,
              onPressed: () {
                setState(() {
                  _localCompleted--;
                });
                // Don't call backend
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        )
        .closed
        .then((reason) {
      // 4. Persistence call (only if not undone)
      if (reason != SnackBarClosedReason.action && mounted) {
        if (widget.onAddCup != null) {
          widget.onAddCup!(_lastCupSize);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isCompleted = _localCompleted >= widget.totalCups;
    int mlGoal = widget.totalCups * 250;
    int currentMl = _localCompleted * 250;
    int remaining = mlGoal - currentMl;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'هدفك اليومي: ${widget.totalCups} أكواب',
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
              if (isCompleted && _localCompleted <= widget.totalCups)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.borderBase.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.textSuccess, size: 16),
                      const Gap(4),
                      Text('مكتمل',
                          style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.textSuccess,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
            ],
          ),
          const Gap(16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: min(1.0, _localCompleted / widget.totalCups),
              minHeight: 6,
              backgroundColor: AppColors.borderBase.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                  (_localCompleted > widget.totalCups)
                      ? AppColors.textCritical
                      : AppColors.primary),
            ),
          ),

          const Gap(24),

          Wrap(
            spacing: 12,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children:
                List.generate(max(widget.totalCups, _localCompleted), (index) {
              bool isFull = index < _localCompleted;
              bool isAnimating = index == _animatingIndex;
              bool isNext = index == _localCompleted && !isCompleted;
              bool isDanger = index >= widget.totalCups && isFull;

              return GestureDetector(
                onTap: (index == _localCompleted && !isAnimating)
                    ? _onAddIntakeRequest
                    : null,
                child: AnimatedWaterCup(
                  isFull: isFull,
                  fillLevel: isFull ? 1.0 : (isAnimating ? 1.0 : 0.0),
                  isAnimating: isAnimating,
                  shouldPulse: isNext,
                  isDanger: isDanger,
                )
                    .animate(
                      target: isNext ? 1 : 0,
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 800.ms,
                      curve: Curves.easeInOut,
                    ),
              );
            }),
          ),

          const Gap(24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'شربت $_localCompleted أكواب من أصل ${widget.totalCups}',
                        style: AppTextStyles.bodyM),
                    if (!isCompleted)
                      Text('باقي $remaining مل لإنهاء هدفك 💪',
                          style: AppTextStyles.bodyS
                              .copyWith(color: AppColors.textSecondary)),
                    if (isCompleted && _localCompleted == widget.totalCups)
                      Text('رائع! أنهيت هدفك المائي اليوم 🎉',
                              style: AppTextStyles.bodyS.copyWith(
                                  color: AppColors.textSuccess,
                                  fontWeight: FontWeight.bold))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(duration: 2.seconds),
                    if (_localCompleted > widget.totalCups)
                      Text('تجاوزت الحد المسموح به!',
                          style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.textCritical,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Cup Size Selector
              _buildSizeToggle(),
            ],
          ),

          if (_localCompleted > widget.totalCups) ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCriticalDark : AppColors.bgCritical,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark
                        ? AppColors.borderCriticalDark
                        : AppColors.borderCritical.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.report_problem_rounded,
                      color: isDark
                          ? AppColors.textCriticalDark
                          : AppColors.textCritical),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ تحذير: احتباس السوائل',
                          style: AppTextStyles.label.copyWith(
                            color: isDark
                                ? AppColors.textCriticalDark
                                : AppColors.textCritical,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'لقد تجاوزت الحد اليومي المسموح به من السوائل. يرجى الانتباه لأي تورم في الأطراف واستشارة الطبيب.',
                          style: AppTextStyles.bodyS.copyWith(
                            color: isDark
                                ? AppColors.textCriticalDark
                                : AppColors.textCritical,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().flipV(duration: 500.ms).shake(),
          ],

          const Gap(24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _animatingIndex == null ? _onAddIntakeRequest : null,
              icon: const Icon(Icons.add),
              label: Text('إضافة كوب ($_lastCupSize مل)'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeToggle() {
    return PopupMenuButton<int>(
      initialValue: _lastCupSize,
      onSelected: (size) => setState(() => _lastCupSize = size),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 200, child: Text('كوب صغير (200 مل)')),
        const PopupMenuItem(value: 250, child: Text('كوب قياسي (250 مل)')),
        const PopupMenuItem(value: 330, child: Text('عبوة صغيرة (330 مل)')),
        const PopupMenuItem(value: 500, child: Text('عبوة كبيرة (500 مل)')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_drink_outlined,
                size: 16, color: AppColors.primary),
            const Gap(4),
            Text('$_lastCupSize مل', style: AppTextStyles.bodyS),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class AnimatedWaterCup extends StatefulWidget {
  final bool isFull;
  final double fillLevel;
  final bool isAnimating;
  final bool shouldPulse;
  final bool isDanger;

  const AnimatedWaterCup({
    super.key,
    required this.isFull,
    required this.fillLevel,
    this.isAnimating = false,
    this.shouldPulse = false,
    this.isDanger = false,
  });

  @override
  State<AnimatedWaterCup> createState() => _AnimatedWaterCupState();
}

class _AnimatedWaterCupState extends State<AnimatedWaterCup>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: widget.fillLevel),
      duration: widget.isAnimating
          ? const Duration(milliseconds: 1500)
          : const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      builder: (context, fillValue, child) {
        return Container(
          width: 44,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDanger
                  ? AppColors.textCritical
                  : (widget.isFull ? AppColors.primary : AppColors.borderBase),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (fillValue > 0)
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WaterWavePainter(
                          fillLevel: fillValue,
                          waveOffset: _waveController.value * 2 * pi,
                          isDanger: widget.isDanger,
                        ),
                        child: Container(),
                      );
                    },
                  ),
                if (widget.isFull && !widget.isAnimating)
                  const Icon(Icons.check, color: Colors.white, size: 20)
                      .animate()
                      .scale(curve: Curves.elasticOut),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaterWavePainter extends CustomPainter {
  final double fillLevel;
  final double waveOffset;
  final bool isDanger;

  WaterWavePainter({
    required this.fillLevel,
    required this.waveOffset,
    this.isDanger = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillLevel <= 0.0) return;

    final waterHeight = size.height * (1 - fillLevel);

    final path = Path();
    path.moveTo(0, waterHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = waterHeight + sin((x / size.width * 2 * pi) + waveOffset) * 4;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDanger
          ? [
              const Color(0xFFE57373).withValues(alpha: 0.8),
              const Color(0xFFD32F2F).withValues(alpha: 0.95),
            ]
          : [
              const Color(0xFF4FC3F7).withValues(alpha: 0.8),
              const Color(0xFF0288D1).withValues(alpha: 0.95),
            ],
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    _drawBubbles(canvas, size, fillLevel);
  }

  void _drawBubbles(Canvas canvas, Size size, double fillLevel) {
    if (fillLevel < 0.2) return;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.3);

    final b1Y = size.height - ((waveOffset * 10) % (size.height * fillLevel));
    canvas.drawCircle(Offset(size.width * 0.3, b1Y), 2, paint);

    final b2Y =
        size.height - (((waveOffset + 1) * 15) % (size.height * fillLevel));
    canvas.drawCircle(Offset(size.width * 0.7, b2Y), 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant WaterWavePainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.waveOffset != waveOffset;
  }
}
