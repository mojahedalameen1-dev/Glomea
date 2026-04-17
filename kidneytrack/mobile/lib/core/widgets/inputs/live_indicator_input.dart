import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_types.dart';

class LiveIndicatorInput extends StatefulWidget {
  final String indicatorName;
  final String unit;
  final ThresholdRange thresholds;
  final ValueChanged<double> onChanged;

  const LiveIndicatorInput({
    super.key,
    required this.indicatorName,
    required this.unit,
    required this.thresholds,
    required this.onChanged,
  });

  @override
  State<LiveIndicatorInput> createState() => _LiveIndicatorInputState();
}

class _LiveIndicatorInputState extends State<LiveIndicatorInput> {
  final TextEditingController _controller = TextEditingController();
  double _value = 0.0;

  Color get _statusColor {
    if (_value == 0) return AppColors.borderBase;
    if (_value > widget.thresholds.warningMax) return AppColors.textCritical;
    if (_value > widget.thresholds.safeMax) return AppColors.textWarning;
    return AppColors.textSuccess;
  }

  void _onInputChanged(String val) {
    final d = double.tryParse(val) ?? 0.0;
    setState(() => _value = d);
    widget.onChanged(d);

    // Vibrate on threshold crossing
    if (d > widget.thresholds.warningMax) {
      HapticFeedback.heavyImpact();
    } else if (d > widget.thresholds.safeMax) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: _statusColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          if (_value > 0)
            BoxShadow(
                color: _statusColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.indicatorName,
                  style: AppTextStyles.h2.copyWith(fontSize: 18)),
              Text(widget.unit,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const Gap(16),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: _onInputChanged,
            style: AppTextStyles.h1.copyWith(
                fontSize: 28,
                color: _statusColor == AppColors.borderBase
                    ? AppColors.textPrimary
                    : _statusColor),
            decoration: InputDecoration(
              hintText: '0.0',
              border: InputBorder.none,
              suffixIcon: _value > 0
                  ? Icon(Icons.check_circle, color: _statusColor)
                  : null,
            ),
          )
              .animate(target: _value > widget.thresholds.warningMax ? 1 : 0)
              .shake(hz: 8, curve: Curves.easeInOut),

          const Gap(12),
          // Threshold Visualization bar
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.textSuccess,
                      AppColors.textWarning,
                      AppColors.textCritical,
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: 400.ms,
                curve: Curves.easeOutCubic,
                left: (MediaQuery.of(context).size.width - 80) *
                    (_value / (widget.thresholds.warningMax * 1.5))
                        .clamp(0.0, 1.0),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(blurRadius: 4, color: Colors.black26)
                      ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
