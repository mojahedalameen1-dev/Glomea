import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';

class WeightDrumPicker extends StatefulWidget {
  final double initialValue;
  final Function(double) onChanged;
  final String label;

  const WeightDrumPicker({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.label,
  });

  @override
  State<WeightDrumPicker> createState() => _WeightDrumPickerState();
}

class _WeightDrumPickerState extends State<WeightDrumPicker> {
  late FixedExtentScrollController _intController;
  late FixedExtentScrollController _decController;

  late int _intPart;
  late int _decPart;

  @override
  void initState() {
    super.initState();
    _intPart = widget.initialValue.toInt();
    _decPart = ((widget.initialValue - _intPart) * 10).round();

    _intController = FixedExtentScrollController(initialItem: _intPart - 30);
    _decController = FixedExtentScrollController(initialItem: _decPart);
  }

  void _update() {
    final val = _intPart + (_decPart / 10.0);
    widget.onChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    // Dynamic height based on text scaling to ensure senior visibility and no clipping
    final double pickerHeight = 200 *
        mediaQuery.textScaler
            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.5)
            .scale(1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const Gap(16),
        Container(
          height: pickerHeight,
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.borderBaseDark
                  : AppColors.borderBase.withValues(alpha: 0.1),
            ),
            boxShadow: isDark ? null : AppShadows.elev1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                child: CupertinoPicker(
                  scrollController: _intController,
                  itemExtent: 48,
                  magnification: 1.2,
                  useMagnifier: true,
                  onSelectedItemChanged: (i) {
                    setState(() => _intPart = i + 30);
                    _update();
                    HapticFeedback.selectionClick();
                  },
                  children: List.generate(
                      220,
                      (i) => Center(
                            child: Text(
                              '${i + 30}',
                              style: AppTextStyles.h2.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          )),
                ),
              ),
              Text(
                '.',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              SizedBox(
                width: 80,
                child: CupertinoPicker(
                  scrollController: _decController,
                  itemExtent: 48,
                  magnification: 1.2,
                  useMagnifier: true,
                  onSelectedItemChanged: (i) {
                    setState(() => _decPart = i);
                    _update();
                    HapticFeedback.selectionClick();
                  },
                  children: List.generate(
                      10,
                      (i) => Center(
                            child: Text(
                              '$i',
                              style: AppTextStyles.h2.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          )),
                ),
              ),
              const Gap(12),
              Text(
                'كجم',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.98, 0.98));
  }
}
