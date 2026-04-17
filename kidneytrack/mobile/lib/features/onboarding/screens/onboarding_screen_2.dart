import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/constants/health_constants.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen2 extends ConsumerStatefulWidget {
  const OnboardingScreen2({super.key});

  @override
  ConsumerState<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends ConsumerState<OnboardingScreen2> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fluidController;
  late TextEditingController _potassiumController;
  late TextEditingController _sodiumController;
  late TextEditingController _proteinController;
  late TextEditingController _phosphorusController;
  late TextEditingController _physicianController;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingNotifierProvider).data;

    _fluidController = TextEditingController(
        text: (data.fluidLimitMl ?? HealthConstants.defaultFluidLimitMl)
            .toString());
    _potassiumController = TextEditingController(
        text: (data.potassiumLimitMg ?? HealthConstants.defaultPotassiumLimitMg)
            .toString());
    _sodiumController = TextEditingController(
        text: (data.sodiumLimitMg ?? HealthConstants.defaultSodiumLimitMg)
            .toString());
    _proteinController = TextEditingController(
        text: (data.proteinLimitG ?? HealthConstants.defaultProteinLimitG)
            .toString());
    _phosphorusController = TextEditingController(
        text:
            (data.phosphorusLimitMg ?? HealthConstants.defaultPhosphorusLimitMg)
                .toString());
    _physicianController = TextEditingController(text: data.physicianName);
    _notificationsEnabled = data.notificationsEnabled;
  }

  @override
  void dispose() {
    _fluidController.dispose();
    _potassiumController.dispose();
    _sodiumController.dispose();
    _proteinController.dispose();
    _phosphorusController.dispose();
    _physicianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(localizationProvider);
    final state = ref.watch(onboardingNotifierProvider);
    final isAr = activeLocale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(context, 2),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'خطة العناية الطبية' : 'Medical Setup',
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr
                            ? 'حدد أهدافك اليومية للتحكم في صحة كليتيك.'
                            : 'Set your daily limits to manage your kidney health.',
                        style: AppTextStyles.bodyM
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                          isAr ? 'الحد اليومي للسوائل' : 'Daily Fluid Limit'),
                      AppTextField(
                        label: isAr ? 'السوائل (مل)' : 'Fluid Limit (mL)',
                        hint: '1500',
                        controller: _fluidController,
                        keyboardType: TextInputType.number,
                        suffixText: 'mL',
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return isAr ? 'هذا الحقل مطلوب' : 'Required';
                          final val = int.tryParse(v);
                          if (val == null || val < 500 || val > 3000) {
                            return isAr
                                ? 'يجب أن تكون بين 500 و 3000 مل'
                                : 'Must be between 500 and 3000 mL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                          isAr ? 'حدود العناصر الغذائية' : 'Nutrient Limits'),
                      _buildTwoColumnFields([
                        (
                          isAr ? 'بوتاسيوم (ملجم)' : 'Potassium (mg)',
                          _potassiumController,
                          (v) {
                            if (v == null || v.isEmpty)
                              return isAr ? 'مطلوب' : 'Required';
                            final val = int.tryParse(v);
                            if (val == null || val < 1000 || val > 3500) {
                              return isAr ? 'بين 1000-3500' : '1000-3500';
                            }
                            return null;
                          }
                        ),
                        (
                          isAr ? 'صوديوم (ملجم)' : 'Sodium (mg)',
                          _sodiumController,
                          (v) {
                            if (v == null || v.isEmpty)
                              return isAr ? 'مطلوب' : 'Required';
                            final val = int.tryParse(v);
                            if (val == null || val < 500 || val > 3000) {
                              return isAr ? 'بين 500-3000' : '500-3000';
                            }
                            return null;
                          }
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildTwoColumnFields([
                        (
                          isAr ? 'بروتين (جم)' : 'Protein (g)',
                          _proteinController,
                          (v) {
                            if (v == null || v.isEmpty)
                              return isAr ? 'مطلوب' : 'Required';
                            final val = int.tryParse(v);
                            if (val == null || val < 30 || val > 120) {
                              return isAr ? 'بين 30-120' : '30-120';
                            }
                            return null;
                          }
                        ),
                        (
                          isAr ? 'فوسفور (ملجم)' : 'Phosphorus (mg)',
                          _phosphorusController,
                          (v) {
                            if (v == null || v.isEmpty)
                              return isAr ? 'مطلوب' : 'Required';
                            final val = int.tryParse(v);
                            if (val == null || val < 500 || val > 1500) {
                              return isAr ? 'بين 500-1500' : '500-1500';
                            }
                            return null;
                          }
                        ),
                      ]),
                      const SizedBox(height: 32),
                      _buildNotificationToggle(isAr),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomAction(context, activeLocale, state),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, int step) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_right
                  : Icons.chevron_left,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.borderBase.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: step / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$step / 2',
            style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTwoColumnFields(
      List<(String, TextEditingController, String? Function(String?)?)>
          fields) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          Expanded(
            child: AppTextField(
              label: fields[i].$1,
              controller: fields[i].$2,
              keyboardType: TextInputType.number,
              validator: fields[i].$3,
            ),
          ),
          if (i < fields.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildNotificationToggle(bool isAr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.elev1,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_outlined,
                color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'تنبيهات المتابعة' : 'Follow-up Alerts',
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                Text(
                  isAr
                      ? 'تلقي تذكيرات يومية لتسجيل مؤشراتك'
                      : 'Get daily reminders for tracking',
                  style: AppTextStyles.bodyS,
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
      BuildContext context, Locale activeLocale, OnboardingState state) {
    final isAr = activeLocale.languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final notifier =
                        ref.read(onboardingNotifierProvider.notifier);

                    notifier.updateData(
                      state.data.copyWith(
                        fluidLimitMl: int.tryParse(_fluidController.text),
                        potassiumLimitMg:
                            int.tryParse(_potassiumController.text),
                        sodiumLimitMg: int.tryParse(_sodiumController.text),
                        proteinLimitG: int.tryParse(_proteinController.text),
                        phosphorusLimitMg:
                            int.tryParse(_phosphorusController.text),
                        physicianName: _physicianController.text.trim(),
                        notificationsEnabled: _notificationsEnabled,
                      ),
                    );

                    final success = await notifier.completeOnboarding();

                    if (success && context.mounted) {
                      // Done. AppRouter will handle the redirect because onboardingComplete is true.
                      // But we use context.go to be safe and clean the stack.
                      context.go('/dashboard');
                    } else if (context.mounted && state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error!),
                          backgroundColor: AppColors.criticalRed,
                        ),
                      );
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: state.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  isAr ? 'إكمال الإعداد' : 'Complete Setup',
                  style: AppTextStyles.h3.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
