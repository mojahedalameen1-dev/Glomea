import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_types.dart';

class HealthGauge extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final IndicatorStatus status;

  const HealthGauge({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case IndicatorStatus.safe:
        return AppColors.safeGreen;
      case IndicatorStatus.warning:
        return AppColors.warningAmber;
      case IndicatorStatus.critical:
        return AppColors.criticalRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double normalizedValue = (value - min) / (max - min);
    final double clampedValue = normalizedValue.clamp(0.0, 1.0);

    return SizedBox(
      width: 140,
      height: 80,
      child: CustomPaint(
        painter: _GaugePainter(
          percent: clampedValue,
          color: statusColor,
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color color;

  _GaugePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.borderBase.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Active
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * percent,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
