import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:kidneytrack_mobile/core/models/food_item.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_shadows.dart';
import 'package:kidneytrack_mobile/core/widgets/ai/ai_food_analysis_card.dart';
import 'package:kidneytrack_mobile/core/models/food_consumption.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kidneytrack_mobile/features/auth/providers/auth_provider.dart';
import 'package:kidneytrack_mobile/core/widgets/medical_disclaimer.dart';
import 'package:kidneytrack_mobile/core/services/medication_warning_engine.dart';
import 'package:kidneytrack_mobile/core/providers/interaction_provider.dart';
import 'package:kidneytrack_mobile/features/daily_entry/providers/daily_entry_provider.dart';
import 'package:kidneytrack_mobile/features/history/providers/history_provider.dart';
import 'package:kidneytrack_mobile/core/providers/food_consumption_provider.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

class KidneyResultModal extends ConsumerStatefulWidget {
  final FoodItem food;

  const KidneyResultModal({super.key, required this.food});

  @override
  ConsumerState<KidneyResultModal> createState() => _KidneyResultModalState();
}

class _KidneyResultModalState extends ConsumerState<KidneyResultModal> {
  late FoodItem _currentProduct;
  double _selectedGrams = 100;
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.food;
    _selectedGrams = widget.food.servingSize ?? 100;
    _checkBannerStatus();
  }

  Future<void> _checkBannerStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final weekKey = 'banner_dismissed_${DateTime.now().day ~/ 7}';
    if (mounted) {
      setState(() {
        _bannerDismissed = prefs.getBool(weekKey) ?? false;
      });
    }
  }

  Future<void> _dismissBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final weekKey = 'banner_dismissed_${DateTime.now().day ~/ 7}';
    await prefs.setBool(weekKey, true);
    if (mounted) {
      setState(() {
        _bannerDismissed = true;
      });
    }
  }

  double? _calc(double? per100g) =>
      per100g == null ? null : (per100g / 100) * _selectedGrams;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return FocusScope(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: l10n.productAnalysisResults(_currentProduct.name),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: isDark
                ? const Border(top: BorderSide(color: AppColors.borderBaseDark))
                : null,
          ),
          child: Column(
            children: [
              // Header Bar with Close Action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Stack(
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
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                        tooltip: l10n.close,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildProductHeader(isDark, l10n),
                    const Gap(24),
                    _buildQuantityPicker(isDark, l10n),
                    const Gap(16),
                    if (!_bannerDismissed) _buildWarningBanner(isDark, l10n),
                    const Gap(16),
                    _buildMedicationInteractions(isDark, l10n),
                    const Gap(16),
                    _buildVerdictBanner(isDark, l10n),
                    const Gap(16),
                    const MedicalDisclaimer(),
                    const Gap(24),
                    _buildSectionTitle(
                        l10n.nutritionalAnalysisPerGrams(_selectedGrams.toStringAsFixed(0)),
                        isDark),
                    const Gap(12),
                    _buildNutrientRow(
                        l10n.nutrientSodium,
                        _currentProduct.sodium,
                        _calc(_currentProduct.sodium),
                        l10n.unitMg,
                        300,
                        200,
                        Icons.water_drop_outlined,
                        (val) => setState(() => _currentProduct =
                            _currentProduct.copyWith(sodium: val)),
                        isDark,
                        l10n),
                    _buildNutrientRow(
                        l10n.nutrientPotassium,
                        _currentProduct.potassium,
                        _calc(_currentProduct.potassium),
                        l10n.unitMg,
                        200,
                        150,
                        Icons.bolt_outlined,
                        (val) => setState(() => _currentProduct =
                            _currentProduct.copyWith(potassium: val)),
                        isDark,
                        l10n),
                    _buildNutrientRow(
                        l10n.nutrientPhosphorus,
                        _currentProduct.phosphorus,
                        _calc(_currentProduct.phosphorus),
                        l10n.unitMg,
                        150,
                        100,
                        Icons.science_outlined,
                        (val) => setState(() => _currentProduct =
                            _currentProduct.copyWith(phosphorus: val)),
                        isDark,
                        l10n),
                    _buildNutrientRow(
                        l10n.nutrientProtein,
                        _currentProduct.protein,
                        _calc(_currentProduct.protein),
                        l10n.unitG,
                        20,
                        10,
                        Icons.fitness_center_outlined,
                        (val) => setState(() => _currentProduct =
                            _currentProduct.copyWith(protein: val)),
                        isDark,
                        l10n),
                    _buildNutrientRow(
                        l10n.nutrientSugars,
                        _currentProduct.sugars,
                        _calc(_currentProduct.sugars),
                        l10n.unitG,
                        15,
                        10,
                        Icons.icecream_outlined,
                        (val) => setState(() => _currentProduct =
                            _currentProduct.copyWith(sugars: val)),
                        isDark,
                        l10n),
                    _buildNutrientRow(
                        l10n.nutrientCalories,
                        _currentProduct.calories,
                        _calc(_currentProduct.calories),
                        l10n.unitCalorie,
                        500,
                        300,
                        Icons.local_fire_department_outlined,
                        (val) => setState(() => _currentProduct =
                            _currentProduct.copyWith(calories: val)),
                        isDark,
                        l10n),
                    const Gap(20),
                    AiFoodAnalysisCard(nutrients: {
                      'sodium': _currentProduct.sodium,
                      'potassium': _currentProduct.potassium,
                      'phosphorus': _currentProduct.phosphorus,
                      'calcium': _currentProduct.calcium,
                      'protein': _currentProduct.protein,
                    }),
                    const Gap(32),
                    _buildSaveButton(isDark, l10n),
                    const Gap(48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(bool isDark, AppLocalizations l10n) {
    return Row(children: [
      Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgSurfaceDark : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark
                  ? AppColors.borderBaseDark
                  : AppColors.borderBase.withValues(alpha: 0.1)),
        ),
        child: _currentProduct.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    Image.network(_currentProduct.imageUrl!, fit: BoxFit.cover))
            : Icon(Icons.fastfood, color: Colors.grey[400], size: 32),
      ),
      const Gap(16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _currentProduct.name,
                style: AppTextStyles.h2.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ),
            _buildSourceBadge(_currentProduct.dataSource, isDark, l10n),
          ],
        ),
        Text(
          _currentProduct.brand,
          style: AppTextStyles.bodyS.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ])),
    ]);
  }

  Widget _buildSourceBadge(String source, bool isDark, AppLocalizations l10n) {
    Color color;
    String label;
    IconData icon;

    switch (source.toLowerCase()) {
      case 'sfda':
      case 'off':
        color = isDark ? AppColors.textSuccessDark : AppColors.textSuccess;
        label = l10n.verifiedChoice;
        icon = Icons.verified_user;
        break;
      case 'manual':
        color = isDark ? AppColors.textWarningDark : AppColors.textWarning;
        label = l10n.manualEntry;
        icon = Icons.edit_note;
        break;
      case 'ai':
        color = AppColors.primary;
        label = l10n.smartEstimation;
        icon = Icons.auto_awesome;
        break;
      default:
        color = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
        label = l10n.unknown;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const Gap(6),
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityPicker(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.scale_outlined, color: AppColors.primary, size: 20),
          const Gap(10),
          Text(
            l10n.howMuchWillYouConsume,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
        ]),
        const Gap(20),
        Row(children: [
          _buildQtyBtn(
              Icons.remove,
              () => setState(() {
                    if (_selectedGrams > 10) _selectedGrams -= 10;
                  })),
          Expanded(
            child: Center(
              child: Text(
                '${_selectedGrams.toStringAsFixed(0)} جم',
                style: AppTextStyles.metricValue.copyWith(
                  fontSize: 28,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          _buildQtyBtn(Icons.add, () => setState(() => _selectedGrams += 10)),
        ]),
      ]),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback tap) => Material(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
      );

  Widget _buildWarningBanner(bool isDark, AppLocalizations l10n) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.textWarningDark : AppColors.textWarning)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  (isDark ? AppColors.textWarningDark : AppColors.textWarning)
                      .withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: isDark ? AppColors.textWarningDark : AppColors.textWarning,
              size: 22),
          const Gap(12),
          Expanded(
            child: Text(
              l10n.valuesMayDifferWarning,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          IconButton(
            onPressed: _dismissBanner,
            icon: Icon(Icons.close,
                color:
                    isDark ? AppColors.textWarningDark : AppColors.textWarning,
                size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: l10n.dismissWarning,
          ),
        ]),
      );

  Widget _buildVerdictBanner(bool isDark, AppLocalizations l10n) {
    final vSod = _calc(_currentProduct.sodium);
    final vPot = _calc(_currentProduct.potassium);
    final vPho = _calc(_currentProduct.phosphorus);

    final isDanger = (vSod != null && vSod >= 300) ||
        (vPot != null && vPot >= 200) ||
        (vPho != null && vPho >= 150);
    final isWarning = (vSod != null && vSod >= 200) ||
        (vPot != null && vPot >= 150) ||
        (vPho != null && vPho >= 100);

    final Color color = isDanger
        ? (isDark ? AppColors.textCriticalDark : AppColors.textCritical)
        : (isWarning
            ? (isDark ? AppColors.textWarningDark : AppColors.textWarning)
            : (isDark ? AppColors.textSuccessDark : AppColors.textSuccess));

    final icon = isDanger
        ? Icons.dangerous
        : (isWarning ? Icons.error_outline : Icons.check_circle_outline);
    final String text = isDanger
        ? l10n.avoidThisProduct
        : (isWarning ? l10n.consumeWithCaution : l10n.relativelySafeChoice);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 32),
        const Gap(16),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.h2.copyWith(color: color, fontSize: 18),
          ),
        ),
      ]),
    );
  }

  Widget _buildMedicationInteractions(bool isDark, AppLocalizations l10n) {
    final patientAsync = ref.watch(authNotifierProvider);
    final activeMedsAsync = ref.watch(activeSystemMedicationsProvider);
    final totalsAsync = ref.watch(dailyNutrientTotalsProvider);
    final totals = totalsAsync.asData?.value ?? {};

    if (patientAsync.valueOrNull == null ||
        activeMedsAsync.valueOrNull == null) {
      return const SizedBox.shrink();
    }

    final projectedTotals = Map<String, double>.from(totals);
    projectedTotals['potassium'] = (projectedTotals['potassium'] ?? 0) +
        (_calc(_currentProduct.potassium) ?? 0);
    projectedTotals['sodium'] =
        (projectedTotals['sodium'] ?? 0) + (_calc(_currentProduct.sodium) ?? 0);
    projectedTotals['phosphorus'] = (projectedTotals['phosphorus'] ?? 0) +
        (_calc(_currentProduct.phosphorus) ?? 0);
    projectedTotals['protein'] = (projectedTotals['protein'] ?? 0) +
        (_calc(_currentProduct.protein) ?? 0);

    final interactions =
        MedicationWarningEngine.evaluateDrugNutrientInteractions(
            activeMedsAsync.value!, projectedTotals, patientAsync.value!, l10n);

    if (interactions.isEmpty) return const SizedBox.shrink();

    return Column(
      children: interactions.map((interaction) {
        final isCritical = interaction.severity == Severity.critical;
        final color = isCritical
            ? (isDark ? AppColors.textCriticalDark : AppColors.textCritical)
            : (isDark ? AppColors.textWarningDark : AppColors.textWarning);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_rounded, color: color, size: 32),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.foodDrugInteraction,
                      style: AppTextStyles.h3
                          .copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                    const Gap(6),
                    Text(
                      interaction.safetyMessage,
                      style: AppTextStyles.bodyS
                          .copyWith(color: color, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      );

  Widget _buildNutrientRow(
      String label,
      double? per100g,
      double? total,
      String unit,
      double danger,
      double warn,
      IconData icon,
      Function(double) onEdit,
      bool isDark,
      AppLocalizations l10n) {
    bool isMissing = per100g == null;
    bool isOverridden = !isMissing &&
        per100g !=
            (label == 'البوتاسيوم'
                ? widget.food.potassium
                : label == 'الفوسفور'
                    ? widget.food.phosphorus
                    : label == 'الصوديوم'
                        ? widget.food.sodium
                        : label == 'البروتين'
                            ? widget.food.protein
                            : null);

    final currentTotal = total ?? 0;
    final sevColor = currentTotal >= danger
        ? (isDark ? AppColors.textCriticalDark : AppColors.textCritical)
        : (currentTotal >= warn
            ? (isDark ? AppColors.textWarningDark : AppColors.textWarning)
            : AppColors.primary);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? AppColors.borderBaseDark
                : AppColors.borderBase.withValues(alpha: 0.1)),
        boxShadow: isDark ? null : AppShadows.elev1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditDialog(label, per100g, unit, onEdit, isDark),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon,
                  color: isMissing ? Colors.grey : AppColors.primary, size: 24),
              const Gap(16),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontWeight:
                              isMissing ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      if (isOverridden) ...[
                        const Gap(6),
                        const Icon(Icons.edit,
                            size: 14, color: AppColors.primary),
                      ],
                    ],
                  ),
                  if (isMissing)
                    Text(l10n.missingData,
                        style: const TextStyle(
                            color: AppColors.textWarning,
                            fontSize: 11,
                            fontWeight: FontWeight.bold))
                  else
                    Text(
                      '${per100g.toStringAsFixed(1)} $unit / 100 ${l10n.unitG}',
                      style: AppTextStyles.bodyS.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                ],
              )),
              if (!isMissing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${total?.toStringAsFixed(1) ?? '??'} $unit',
                      style: AppTextStyles.h2.copyWith(
                        color: sevColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(String label, double? current, String unit,
      Function(double) onEdit, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: current?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.editNutrient(label),
          style: AppTextStyles.h2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: AppTextStyles.h2,
              decoration: InputDecoration(
                suffixText: unit,
                labelText: l10n.valuePer100g,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                onEdit(val);
                setState(() => _currentProduct =
                    _currentProduct.copyWith(dataSource: 'manual'));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) => ElevatedButton(
        onPressed: () => _saveConsumption(l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          l10n.saveToDailyLog,
          style: AppTextStyles.h3
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );

  Future<void> _saveConsumption(AppLocalizations l10n) async {
    HapticFeedback.mediumImpact();

    final patientId = ref.read(authNotifierProvider).valueOrNull?.id;
    if (patientId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pleaseLoginFirst)));
      }
      return;
    }

    final consumption = FoodConsumption(
      id: const Uuid().v4(),
      patientId: patientId,
      foodName: _currentProduct.name,
      brand: _currentProduct.brand,
      gramsConsumed: _selectedGrams,
      potassium: _calc(_currentProduct.potassium) ?? 0.0,
      phosphorus: _calc(_currentProduct.phosphorus) ?? 0.0,
      sodium: _calc(_currentProduct.sodium) ?? 0.0,
      protein: _calc(_currentProduct.protein) ?? 0.0,
      calories: _calc(_currentProduct.calories) ?? 0.0,
      calcium: _calc(_currentProduct.calcium),
      sugars: _calc(_currentProduct.sugars),
      carbohydrates: _calc(_currentProduct.carbohydrates),
      totalFat: _calc(_currentProduct.totalFat),
      consumedAt: DateTime.now(),
      dataSource: _currentProduct.dataSource,
    );

    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // 1. Fetch existing totals for today to perform atomic-like update on mobile
      final existingResponse = await supabase
          .from('daily_readings')
          .select()
          .eq('patient_id', patientId)
          .eq('reading_date', today)
          .maybeSingle();

      int currentK = 0;
      int currentNa = 0;
      double currentProt = 0;
      int currentPho = 0;

      if (existingResponse != null) {
        currentK = existingResponse['potassium_mg'] ?? 0;
        currentNa = existingResponse['sodium_mg'] ?? 0;
        currentProt = (existingResponse['protein_g'] ?? 0).toDouble();
        currentPho = existingResponse['phosphorus_mg'] ?? 0;
      }

      // 2. Update Daily Reading Totals
      await ref.read(dailyEntryProvider.notifier).saveReading(
            patientId: patientId,
            potassiumMg: currentK + consumption.potassium.toInt(),
            sodiumMg: currentNa + consumption.sodium.toInt(),
            proteinG: currentProt + consumption.protein,
            phosphorusMg: currentPho + consumption.phosphorus.toInt(),
            // Keep other existing clinical values if they exist
            weightKg: existingResponse?['weight_kg']?.toDouble(),
            systolic: existingResponse?['systolic']?.toInt(),
            diastolic: existingResponse?['diastolic']?.toInt(),
            bloodSugar: existingResponse?['blood_sugar']?.toDouble(),
            fluidIntakeMl: existingResponse?['fluid_intake_ml']?.toInt(),
            notes: existingResponse?['notes'],
          );

      // 3. Add individual consumption record for history
      await ref
          .read(foodConsumptionProvider.notifier)
          .addConsumption(consumption);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ تم إضافة الطعام وتحديث سجلك اليومي بنجاح'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ فشل الحفظ: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}
