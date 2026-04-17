import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class NumericStepper extends StatelessWidget {
  final String label;
  final double value;
  final double step;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String unit;

  const NumericStepper({
    super.key,
    required this.label,
    required this.value,
    this.step = 1.0,
    this.min = 0.0,
    this.max = 10000.0,
    required this.onChanged,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.borderBase.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - step) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              GestureDetector(
                onTap: () => _showManualInputDialog(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value.toStringAsFixed(step == step.toInt() ? 0 : 1),
                      style: AppTextStyles.h2.copyWith(color: AppColors.primary, decoration: TextDecoration.underline),
                    ),
                    const SizedBox(width: 4),
                    Text(unit, style: AppTextStyles.bodyS),
                  ],
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + step) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final controller = TextEditingController(text: value.toStringAsFixed(step == step.toInt() ? 0 : 1));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إدخال $label'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            suffixText: unit,
            hintText: 'أدخل الرقم يدوياً',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null && newValue >= min && newValue <= max) {
                onChanged(newValue);
              }
              Navigator.pop(context);
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }
}
