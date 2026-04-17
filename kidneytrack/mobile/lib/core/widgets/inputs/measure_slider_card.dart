import 'package:flutter/material.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

class MeasureSliderCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final VoidCallback onTapValue;

  const MeasureSliderCard({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
    this.onChangeEnd,
    required this.onTapValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderBase.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.h3),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!, 
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              InkWell(
                onTap: onTapValue,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatValue(value),
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 32, 
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit, 
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 16,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 24),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 36),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.borderBase.withValues(alpha: 0.1),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${min.toInt()} $unit', style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
                Text('${max.toInt()} $unit', style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }
}
