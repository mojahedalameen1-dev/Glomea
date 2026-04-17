import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/providers/localization_provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen1 extends ConsumerStatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  ConsumerState<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends ConsumerState<OnboardingScreen1> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _physicianController;
  bool _stageError = false;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingNotifierProvider).data;
    _nameController = TextEditingController(text: data.fullName);
    _ageController = TextEditingController(text: data.age?.toString());
    _physicianController = TextEditingController(text: data.physicianName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _physicianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingNotifierProvider);
    final activeLocale = ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: FocusScope(
          child: Column(
            children: [
              _buildProgressHeader(context, 1),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLanguageToggle(ref, activeLocale),
                        const SizedBox(height: 32),
                        Text(
                          activeLocale.languageCode == 'en'
                              ? 'Welcome to KidneyTrack'
                              : 'مرحباً بك في KidneyTrack',
                          style: AppTextStyles.h1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeLocale.languageCode == 'en'
                              ? 'Let\'s set up your profile to start tracking your health.'
                              : 'لنقم بإعداد ملفك الشخصي لبدء متابعة صحتك.',
                          style: AppTextStyles.bodyM
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: activeLocale.languageCode == 'en'
                              ? 'Full Name'
                              : 'الاسم الكامل',
                          hint: activeLocale.languageCode == 'en'
                              ? 'Enter your name'
                              : 'أدخل اسمك',
                          controller: _nameController,
                          validator: (v) => (v == null || v.isEmpty)
                              ? (activeLocale.languageCode == 'en'
                                  ? 'Please enter your name'
                                  : 'يرجى إدخال اسمك')
                              : null,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: activeLocale.languageCode == 'en'
                              ? 'Age'
                              : 'العمر',
                          hint: 'e.g. 65',
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return activeLocale.languageCode == 'en'
                                  ? 'Age is required'
                                  : 'العمر مطلوب';
                            final age = int.tryParse(v);
                            if (age == null || age <= 0 || age > 120)
                              return activeLocale.languageCode == 'en'
                                  ? 'Invalid age'
                                  : 'عمر غير صالح';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: activeLocale.languageCode == 'en'
                              ? 'Primary Physician'
                              : 'اسم الطبيب المعالج',
                          hint: activeLocale.languageCode == 'en'
                              ? 'Dr. Smith'
                              : 'د. محمد',
                          controller: _physicianController,
                          validator: (v) => (v == null || v.isEmpty)
                              ? (activeLocale.languageCode == 'en'
                                  ? 'Physician name is required'
                                  : 'يرجى إدخال اسم الطبيب')
                              : null,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '${activeLocale.languageCode == 'en' ? 'CKD Stage' : 'مرحلة القصور الكلوي'} *',
                          style: AppTextStyles.label.copyWith(
                            color: _stageError
                                ? AppColors.criticalRed
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_stageError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              activeLocale.languageCode == 'en'
                                  ? '⚠ Please select your CKD stage'
                                  : '⚠ يرجى اختيار مرحلة القصور الكلوي',
                              style: AppTextStyles.bodyS
                                  .copyWith(color: AppColors.criticalRed),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _buildStageSelector(context, ref, state, l10n),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomAction(context, activeLocale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, int step) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Text(
            '$step / 2',
            style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
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
                    alignment: Alignment.centerLeft,
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
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(WidgetRef ref, Locale activeLocale) {
    final isEn = activeLocale.languageCode == 'en';
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.borderBase.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton(ref, 'English', const Locale('en'), isEn),
          _buildLanguageButton(ref, 'العربية', const Locale('ar'), !isEn),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
      WidgetRef ref, String label, Locale locale, bool isActive) {
    return GestureDetector(
      onTap: () {
        ref.read(localizationProvider.notifier).setLocale(locale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? AppShadows.elev1 : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStageSelector(BuildContext context, WidgetRef ref,
      OnboardingState state, AppLocalizations l10n) {
    final stages = [
      ('Stage 1', 'STAGE_1', l10n.stage1),
      ('Stage 2', 'STAGE_2', l10n.stage2),
      ('Stage 3', 'STAGE_3', l10n.stage3),
      ('Stage 4', 'STAGE_4', l10n.stage4),
      ('Stage 5', 'STAGE_5', l10n.stage5),
      ('Dialysis', 'DIALYSIS', l10n.dialysis),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final isSelected = state.data.kidneyStage == stage.$2;

        return GestureDetector(
          onTap: () {
            setState(() => _stageError = false);
            ref.read(onboardingNotifierProvider.notifier).updateData(
                  state.data.copyWith(
                    kidneyStage: stage.$2,
                    dialysisStatus: stage.$2 == 'DIALYSIS'
                        ? 'HEMODIALYSIS'
                        : 'NON_DIALYSIS',
                  ),
                );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderBase.withValues(alpha: 0.2),
              ),
              boxShadow: isSelected ? AppShadows.elev1 : [],
            ),
            alignment: Alignment.center,
            child: Text(
              stage.$3,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction(BuildContext context, Locale activeLocale) {
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
          onPressed: () {
            debugPrint('Next Step button pressed');
            final stage = ref.read(onboardingNotifierProvider).data.kidneyStage;
            debugPrint('Current kidneyStage: $stage');

            final isFormValid = _formKey.currentState!.validate();
            final isStageSelected = stage != null;

            setState(() => _stageError = !isStageSelected);

            if (!isFormValid || !isStageSelected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(activeLocale.languageCode == 'ar'
                      ? 'يرجى إكمال جميع الحقول المطلوبة واختيار المرحلة'
                      : 'Please complete all required fields and select a stage'),
                  backgroundColor: AppColors.criticalRed,
                ),
              );
              return;
            }

            debugPrint('Updating onboarding data...');
            ref.read(onboardingNotifierProvider.notifier).updateData(
                  ref.read(onboardingNotifierProvider).data.copyWith(
                        fullName: _nameController.text.trim(),
                        age: int.tryParse(_ageController.text),
                        physicianName: _physicianController.text.trim(),
                      ),
                );

            // Navigate AFTER the current frame completes.
            // updateData() triggers ref.watch rebuild which would
            // cancel a synchronous context.go(). Deferring to
            // post-frame guarantees the widget tree is stable.
            debugPrint('Scheduling navigation to /onboarding/step2');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                debugPrint('PostFrame: executing go(/onboarding/step2)');
                context.go('/onboarding/step2');
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            activeLocale.languageCode == 'en' ? 'Next Step' : 'الخطوة التالية',
            style: AppTextStyles.h3
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
