import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/charts/fluid_ring_chart.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../auth/providers/auth_provider.dart';
import '../dashboard/providers/medical_insights_provider.dart';
import 'providers/daily_entry_provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/dialogs.dart';
import '../../core/widgets/indicators/threshold_bar.dart';

class DailyEntryScreen extends ConsumerStatefulWidget {
  const DailyEntryScreen({super.key});

  @override
  ConsumerState<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends ConsumerState<DailyEntryScreen> {
  final _weightController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _sugarController = TextEditingController();
  final _fluidController = TextEditingController();
  final _notesController = TextEditingController();

  // Nutrient Controllers
  final _potassiumController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _proteinController = TextEditingController();
  final _phosphorusController = TextEditingController();

  bool _isSaving = false;
  bool _isDirty = false;
  int _fluidCurrent = 0;

  final int _fluidLimit = 1500;

  void _addFluid(int ml) {
    setState(() {
      _fluidCurrent += ml;
      _isDirty = true;
      _fluidController.text = _fluidCurrent.toString();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _sugarController.dispose();
    _fluidController.dispose();
    _notesController.dispose();
    _potassiumController.dispose();
    _sodiumController.dispose();
    _proteinController.dispose();
    _phosphorusController.dispose();
    super.dispose();
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
        appBar: AppBar(
          title: const Text('أضف قياسات اليوم'),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Weight Card
              _buildCard(
                title: 'الوزن',
                child: AppTextField(
                  controller: _weightController,
                  label: 'الوزن الحالي',
                  hint: '75.0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => _isDirty = true),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('كجم'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Blood Pressure
              _buildCard(
                title: 'ضغط الدم',
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _systolicController,
                        label: 'الانقباضي',
                        hint: '120',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() => _isDirty = true),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('mmHg'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _diastolicController,
                        label: 'الانبساطي',
                        hint: '80',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() => _isDirty = true),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('mmHg'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Blood Sugar
              _buildCard(
                title: 'سكر الدم',
                child: AppTextField(
                  controller: _sugarController,
                  label: 'القراءة',
                  hint: '100',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => _isDirty = true),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('mg/dL'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Fluid Card
              _buildCard(
                title: 'السوائل اليوم',
                child: Column(
                  children: [
                    FluidRingChart(
                        currentMl: _fluidCurrent, limitMl: _fluidLimit),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      children: [100, 200, 250, 500]
                          .map((ml) => _buildFluidChip(ml))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _fluidController,
                      label: 'إجمالي السوائل (مل)',
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final val = int.tryParse(v) ?? 0;
                        setState(() {
                          _fluidCurrent = val;
                          _isDirty = true;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notes Card
              _buildCard(
                title: 'ملاحظات (اختياري)',
                child: AppTextField(
                  controller: _notesController,
                  label: 'أي أعراض أو ملاحظات؟',
                  maxLines: 3,
                  onChanged: (_) => setState(() => _isDirty = true),
                ),
              ),

              const SizedBox(height: 24),

              // Dietary Intake Card
              _buildDietaryCard(),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);

                          final patientId =
                              ref.read(authNotifierProvider).value?.id;
                          if (patientId == null) return;

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          final success = await ref
                              .read(dailyEntryProvider.notifier)
                              .saveReading(
                                patientId: patientId,
                                weightKg: _weightController.text.isNotEmpty
                                    ? double.tryParse(_weightController.text)
                                    : null,
                                systolic: _systolicController.text.isNotEmpty
                                    ? int.tryParse(_systolicController.text)
                                    : null,
                                diastolic: _diastolicController.text.isNotEmpty
                                    ? int.tryParse(_diastolicController.text)
                                    : null,
                                bloodSugar: _sugarController.text.isNotEmpty
                                    ? double.tryParse(_sugarController.text)
                                    : null,
                                fluidIntakeMl: _fluidController.text.isNotEmpty
                                    ? int.tryParse(_fluidController.text)
                                    : null,
                                notes: _notesController.text,
                                potassiumMg: _potassiumController
                                        .text.isNotEmpty
                                    ? int.tryParse(_potassiumController.text)
                                    : null,
                                sodiumMg: _sodiumController.text.isNotEmpty
                                    ? int.tryParse(_sodiumController.text)
                                    : null,
                                proteinG: _proteinController.text.isNotEmpty
                                    ? double.tryParse(_proteinController.text)
                                    : null,
                                phosphorusMg: _phosphorusController
                                        .text.isNotEmpty
                                    ? int.tryParse(_phosphorusController.text)
                                    : null,
                              );

                          if (!context.mounted) {
                            return; // Use context.mounted check
                          }

                          setState(() => _isSaving = false);

                          if (success) {
                            ref.invalidate(medicalInsightsProvider);
                            // ref.invalidate(recentReadingsProvider);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('✅ تم حفظ القراءات بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            navigator.pop();
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('❌ فشل الحفظ — تحقق من الاتصال'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('حفظ القياسات',
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildFluidChip(int ml) {
    return ActionChip(
      onPressed: () => _addFluid(ml),
      label: Text('+$ml مل'),
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      labelStyle: const TextStyle(
          color: AppColors.primary, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).animate().scale(duration: 200.ms);
  }

  Widget _buildDietaryCard() {
    final patient = ref.watch(authNotifierProvider).value;
    if (patient == null) return const SizedBox.shrink();

    return _buildCard(
      title: 'المدخلات الغذائية (اختياري)',
      child: Column(
        children: [
          _buildNutrientInput(
            controller: _potassiumController,
            label: 'البوتاسيوم',
            unit: 'ملجم',
            limit: patient.potassiumLimitMg.toDouble(),
            icon: Icons.biotech_outlined,
          ),
          const SizedBox(height: 24),
          _buildNutrientInput(
            controller: _sodiumController,
            label: 'الصوديوم',
            unit: 'ملجم',
            limit: patient.sodiumLimitMg.toDouble(),
            icon: Icons.grain_outlined,
          ),
          const SizedBox(height: 24),
          _buildNutrientInput(
            controller: _proteinController,
            label: 'البروتين',
            unit: 'جم',
            limit: patient.proteinLimitG.toDouble(),
            icon: Icons.egg_outlined,
          ),
          const SizedBox(height: 24),
          _buildNutrientInput(
            controller: _phosphorusController,
            label: 'الفوسفور',
            unit: 'ملجم',
            limit: patient.phosphorusLimitMg.toDouble(),
            icon: Icons.science_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInput({
    required TextEditingController controller,
    required String label,
    required String unit,
    required double limit,
    required IconData icon,
  }) {
    final currentValue = double.tryParse(controller.text) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: controller,
          label: label,
          hint: '0',
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _isDirty = true),
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(unit),
          ),
        ),
        const SizedBox(height: 12),
        ThresholdBar(
          value: currentValue,
          min: 0,
          max: limit * 1.5,
          safeMin: 0,
          safeMax: limit,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الحد اليومي: ${limit.toStringAsFixed(0)} $unit',
                style: AppTextStyles.bodyS),
            if (currentValue > limit)
              Text('⚠️ تجاوزت الحد!',
                  style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textCritical,
                      fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
