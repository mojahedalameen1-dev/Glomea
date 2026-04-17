import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/widgets/inputs/app_text_field.dart';
import 'package:kidneytrack_mobile/core/utils/dialogs.dart';
import 'package:kidneytrack_mobile/features/lab_entry/providers/lab_entry_provider.dart';

class LabReviewScreen extends ConsumerStatefulWidget {
  final Map<String, double?> extractedValues;
  final String rawText;
  final DateTime recordedAt;

  const LabReviewScreen({
    super.key,
    required this.extractedValues,
    required this.rawText,
    required this.recordedAt,
  });

  @override
  ConsumerState<LabReviewScreen> createState() => _LabReviewScreenState();
}

class _LabReviewScreenState extends ConsumerState<LabReviewScreen> {
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;
  bool _isDirty = false;

  final List<Map<String, dynamic>> _indicators = [
    {'name': 'الكرياتينين', 'code': 'CREAT', 'unit': 'mg/dL'},
    {'name': 'البوتاسيوم', 'code': 'K', 'unit': 'mEq/L'},
    {'name': 'اليوريا', 'code': 'UREA', 'unit': 'mg/dL'},
    {'name': 'الصوديوم', 'code': 'NA', 'unit': 'mEq/L'},
    {'name': 'الهيموجلوبين', 'code': 'HGB', 'unit': 'g/dL'},
    {'name': 'الفوسفور', 'code': 'PHOS', 'unit': 'mg/dL'},
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (var ind in _indicators) {
      final code = ind['code'] as String;
      final value = widget.extractedValues[code];
      _controllers[code] = TextEditingController(text: value?.toString() ?? '');
    }
    _isDirty = true;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onConfirm() async {
    setState(() => _isSaving = true);

    final Map<String, double> finalValues = {};
    final Map<String, String> units = {};

    for (var ind in _indicators) {
      final code = ind['code'] as String;
      final text = _controllers[code]?.text ?? '';
      final val = double.tryParse(text.replaceAll('،', '.'));

      if (val != null && val > 0) {
        finalValues[code] = val;
        units[code] = ind['unit'] as String;
      }
    }

    try {
      if (finalValues.isEmpty) {
        throw Exception('يرجى التأكد من إدخال قيمة واحدة على الأقل');
      }

      await ref.read(labEntryProvider.notifier).saveLabResults(
            recordedAt: widget.recordedAt,
            indicators: finalValues,
            units: units,
            imageUrl: null,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التحاليل المؤكدة بنجاح'),
          backgroundColor: AppColors.textSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Go back to the main history/dashboard
      context.pop(); // Pop review
      context.pop(); // Pop entry
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.textCritical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await showExitConfirmDialog(context);
        if (shouldPop && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          title: const Text('راجع قيم التحليل'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              if (!_isDirty) {
                context.pop();
                return;
              }
              final shouldPop = await showExitConfirmDialog(context);
              if (shouldPop && context.mounted) context.pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تحقق من كل قيمة قبل الحفظ', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'هذه القيم مستخرجة من ورقة المختبر آلياً. يرجى تعديلها إذا وجد أي خطأ.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ..._indicators.map((ind) => _buildReviewTile(ind)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('تأكيد وحفظ النتائج',
                          style:
                              AppTextStyles.h2.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewTile(Map<String, dynamic> ind) {
    final code = ind['code'] as String;
    final controller = _controllers[code];
    final isMissing = controller?.text.isEmpty ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isMissing
              ? AppColors.textWarning.withValues(alpha: 0.4)
              : AppColors.borderBase.withValues(alpha: 0.5),
          width: isMissing ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                      radius: 4, backgroundColor: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(ind['name'],
                      style: AppTextStyles.label.copyWith(fontSize: 16)),
                ],
              ),
              if (isMissing)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.textWarning, size: 14),
                      SizedBox(width: 4),
                      Text('أدخلها يدوياً',
                          style: TextStyle(
                              color: AppColors.textWarning,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: '',
            hint: '0.0',
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) {
              // Trigger rebuild to update missing state indicator
              setState(() {});
            },
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(ind['unit'],
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}
