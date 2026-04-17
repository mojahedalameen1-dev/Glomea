import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CountUpText extends StatefulWidget {
  final double endValue;
  final int decimals;
  final TextStyle? style;
  final Duration duration;
  final bool useArabicNumerals;

  const CountUpText({
    super.key,
    required this.endValue,
    this.decimals = 0,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.useArabicNumerals = false,
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endValue != widget.endValue) {
      _animation = Tween<double>(begin: _animation.value, end: widget.endValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    final formatter = NumberFormat.decimalPattern();
    formatter.minimumFractionDigits = widget.decimals;
    formatter.maximumFractionDigits = widget.decimals;
    
    String text = formatter.format(value);
    
    if (widget.useArabicNumerals) {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      for (int i = 0; i < english.length; i++) {
        text = text.replaceAll(english[i], arabic[i]);
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _formatNumber(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}
