import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class MeasureInputSheet extends StatefulWidget {
  final String label;
  final double initialValue;
  final double min;
  final double max;
  final String unit;
  final bool isInteger;

  const MeasureInputSheet({
    super.key,
    required this.label,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.unit,
    this.isInteger = false,
  });

  @override
  State<MeasureInputSheet> createState() => _MeasureInputSheetState();
}

class _MeasureInputSheetState extends State<MeasureInputSheet> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initialText = widget.isInteger
        ? widget.initialValue.toInt().toString()
        : widget.initialValue.toStringAsFixed(1);

    _controller = TextEditingController(text: initialText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final val = double.tryParse(_controller.text);
    if (val == null) {
      setState(() => _error = 'يرجى إدخال رقم صحيح للمتابعة');
      return;
    }
    if (val < widget.min || val > widget.max) {
      setState(() => _error =
          'القيمة يجب أن تكون بين ${widget.min.toInt()} و ${widget.max.toInt()} كحد أقصى');
      return;
    }

    Navigator.pop(context, val);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FocusScope(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: 'ورقة إدخال القياس لـ ${widget.label}',
        child: Container(
          padding: EdgeInsets.fromLTRB(
              24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: isDark
                ? const Border(top: BorderSide(color: AppColors.borderBaseDark))
                : null,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Bar with Drag handle and Close button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.borderBaseDark
                                : AppColors.borderBase)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Align(
                      alignment: Alignment
                          .centerLeft, // Arabic LTR for close button if needed, but here it's RTL context
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'إغلاق',
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  'أدخل ${widget.label} يدوياً',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(4),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'مطلوب',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Gap(24),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: !widget.isInteger),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.metricValue.copyWith(
                    fontSize: 48,
                    color:
                        isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    suffixText: widget.unit,
                    suffixStyle: AppTextStyles.h3.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    errorText: _error,
                    errorMaxLines: 2,
                    errorStyle: AppTextStyles.bodyS
                        .copyWith(color: AppColors.textCritical),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.borderBaseDark
                              : AppColors.borderBase),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.borderBaseDark
                              : AppColors.borderBase),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _onConfirm(),
                ),
                const Gap(32),
                ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    minimumSize: const Size(
                        double.infinity, 56), // Large touch target for seniors
                  ),
                  child: Text(
                    'تأكيد القيمة',
                    style: AppTextStyles.h3.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
