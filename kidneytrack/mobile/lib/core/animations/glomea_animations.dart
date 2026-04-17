import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class GlomeaAnimations {
  // ── دخول العناصر ──────────────────────────
  static Widget fadeSlideIn({
    required Widget child,
    Duration delay = Duration.zero,
    Offset from = const Offset(0, 0.3),
  }) =>
      child
          .animate(delay: delay)
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideY(begin: from.dy, curve: Curves.easeOutCubic);

  // ── Stagger لمجموعة عناصر ──────────────────
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration interval = const Duration(milliseconds: 80),
  }) =>
      children
          .asMap()
          .entries
          .map((e) => e.value
              .animate(delay: interval * e.key)
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutBack)
              .scaleX(
                  begin: 0.98,
                  end: 1.0,
                  duration: 600.ms,
                  curve: Curves.easeOutCirc))
          .toList();

  // ── تأثير لمعان "بريميوم" ──────────────────
  static Widget premiumShimmer(Widget child, {Color? color}) =>
      child.animate(onPlay: (c) => c.repeat()).shimmer(
            duration: 3.seconds,
            color: color ?? Colors.white.withValues(alpha: 0.1),
            angle: 0.5,
          );

  // ── نبضة حالة CRITICAL ─────────────────────
  static Widget criticalPulse(Widget child) => child
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.03, 1.03),
        duration: 1500.ms,
        curve: Curves.easeInOut,
      )
      .shimmer(color: AppColors.criticalRed.withValues(alpha: 0.3));

  // ── إدخال رقم (Count-up) ───────────────────
  static Widget countUp({
    required double value,
    required TextStyle style,
    int decimals = 1,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Text(
          v.toStringAsFixed(decimals),
          style: style,
        ),
      );

  // ── الانتقال بين الشاشات ───────────────────
  static Page heroPage(Widget child) => CustomTransitionPage(
        child: child,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        ),
      );
}
