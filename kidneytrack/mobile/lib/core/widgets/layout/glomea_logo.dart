import 'package:flutter/material.dart';

class GlomeaLogo extends StatefulWidget {
  final double size;
  final Color? color;
  final bool animate;
  final Duration duration;

  const GlomeaLogo({
    super.key,
    this.size = 100,
    this.color,
    this.animate = true,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<GlomeaLogo> createState() => _GlomeaLogoState();
}

class _GlomeaLogoState extends State<GlomeaLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _kidneyAnimation;
  late Animation<double> _leafAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _kidneyAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _leafAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GlomeaLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.forward();
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: LogoPathPainter(
              kidneyProgress: _kidneyAnimation.value,
              leafProgress: _leafAnimation.value,
              color: widget.color ?? Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class LogoPathPainter extends CustomPainter {
  final double kidneyProgress;
  final double leafProgress;
  final Color color;

  LogoPathPainter({
    required this.kidneyProgress,
    required this.leafProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Main Kidney (Glomea C-Shape)
    final kidneyPath = Path();
    kidneyPath.moveTo(w * 0.75, h * 0.25);
    kidneyPath.cubicTo(w * 0.95, h * 0.45, w * 0.85, h * 0.85, w * 0.5, h * 0.95);
    kidneyPath.cubicTo(w * 0.1, h * 0.85, w * 0.05, h * 0.4, w * 0.3, h * 0.2);
    kidneyPath.cubicTo(w * 0.45, h * 0.05, w * 0.65, h * 0.1, w * 0.75, h * 0.25);

    _drawProgressPath(canvas, kidneyPath, kidneyProgress, paint);

    // Simulate leaf path (The inner part)
    if (leafProgress > 0) {
      final leafPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = size.width * 0.04
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final leafPath = Path();
      leafPath.moveTo(w * 0.5, h * 0.45);
      leafPath.quadraticBezierTo(w * 0.65, h * 0.35, w * 0.7, h * 0.55);
      leafPath.quadraticBezierTo(w * 0.55, h * 0.7, w * 0.5, h * 0.45);
      
      _drawProgressPath(canvas, leafPath, leafProgress, leafPaint);
    }
  }

  void _drawProgressPath(Canvas canvas, Path path, double progress, Paint paint) {
    for (final pathMetric in path.computeMetrics()) {
      final extractPath = pathMetric.extractPath(0.0, pathMetric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LogoPathPainter oldDelegate) {
    return oldDelegate.kidneyProgress != kidneyProgress || 
           oldDelegate.leafProgress != leafProgress ||
           oldDelegate.color != color;
  }
}
