import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/widgets/inputs/app_text_field.dart';
import 'package:kidneytrack_mobile/core/widgets/indicators/threshold_bar.dart';
import 'package:kidneytrack_mobile/core/widgets/inputs/date_picker_field.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/core/utils/lab_ocr_parser.dart';
import 'package:kidneytrack_mobile/core/router/app_router.dart';
import 'package:kidneytrack_mobile/features/lab_entry/providers/lab_entry_provider.dart';
import 'package:kidneytrack_mobile/core/utils/dialogs.dart';
import 'package:kidneytrack_mobile/core/utils/lab_unit_converter.dart';
import 'package:kidneytrack_mobile/core/data/lab_indicators.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

// ─── Indicator registry ─────────────────────────────────────────────────────
// Each entry: code, min/max for slider, safeMin/safeMax for bar.
// Values here are always in mg/dL (or native unit for non-convertible ones).
const List<Map<String, dynamic>> _allIndicators = [
  // ── Existing ──────────────────────────────────────────────────────────────
  {
    'code': 'CREAT',
    'unit': 'mg/dL',
    'min': 0.5,
    'max': 15.0,
    'safeMin': 0.7,
    'safeMax': 1.3,
    'convertible': true,
  },
  {
    'code': 'K',
    'unit': 'mEq/L',
    'min': 2.0,
    'max': 8.0,
    'safeMin': 3.5,
    'safeMax': 5.0,
    'convertible': false,
  },
  {
    'code': 'UREA',
    'unit': 'mg/dL',
    'min': 5.0,
    'max': 200.0,
    'safeMin': 10.0,
    'safeMax': 50.0,
    'convertible': true,
  },
  {
    'code': 'NA',
    'unit': 'mEq/L',
    'min': 110.0,
    'max': 170.0,
    'safeMin': 135.0,
    'safeMax': 145.0,
    'convertible': false,
  },
  {
    'code': 'HGB',
    'unit': 'g/dL',
    'min': 5.0,
    'max': 20.0,
    'safeMin': 12.0,
    'safeMax': 16.0,
    'convertible': false,
  },
  {
    'code': 'PHOS',
    'unit': 'mg/dL',
    'min': 1.0,
    'max': 15.0,
    'safeMin': 3.0,
    'safeMax': 4.5,
    'convertible': true,
  },
  // ── New indicators ────────────────────────────────────────────────────────
  {
    'code': 'hba1c',
    'unit': '%',
    'min': 4.0,
    'max': 14.0,
    'safeMin': 4.0,
    'safeMax': 7.0,
    'convertible': false,
  },
  {
    'code': 'total_cholesterol',
    'unit': 'mg/dL',
    'min': 100.0,
    'max': 400.0,
    'safeMin': 0.0,
    'safeMax': 200.0,
    'convertible': true,
  },
  {
    'code': 'ldl',
    'unit': 'mg/dL',
    'min': 0.0,
    'max': 300.0,
    'safeMin': 0.0,
    'safeMax': 100.0,
    'convertible': true,
  },
  {
    'code': 'triglycerides',
    'unit': 'mg/dL',
    'min': 0.0,
    'max': 500.0,
    'safeMin': 0.0,
    'safeMax': 150.0,
    'convertible': true,
  },
  {
    'code': 'calcium',
    'unit': 'mg/dL',
    'min': 5.0,
    'max': 15.0,
    'safeMin': 8.4,
    'safeMax': 10.2,
    'convertible': true,
  },
  {
    'code': 'vitamin_d',
    'unit': 'ng/mL',
    'min': 0.0,
    'max': 100.0,
    'safeMin': 30.0,
    'safeMax': 100.0,
    'convertible': false,
  },
  {
    'code': 'phosphorus_blood',
    'unit': 'mg/dL',
    'min': 1.0,
    'max': 10.0,
    'safeMin': 2.5,
    'safeMax': 4.5,
    'convertible': true,
  },
  {
    'code': 'urine_acr',
    'unit': 'mg/g',
    'min': 0.0,
    'max': 1000.0,
    'safeMin': 0.0,
    'safeMax': 30.0,
    'convertible': false,
  },
];

class LabEntryScreen extends ConsumerStatefulWidget {
  const LabEntryScreen({super.key});

  @override
  ConsumerState<LabEntryScreen> createState() => _LabEntryScreenState();
}

class _LabEntryScreenState extends ConsumerState<LabEntryScreen> {
  bool _isUploading = false;
  bool _showSuccess = false;
  bool _isDirty = false;
  DateTime _selectedDate = DateTime.now();

  /// Values keyed by indicatorCode — always stored in mg/dL internally.
  final Map<String, double> _values = {};

  /// Current unit preference: 'mg' or 'mmol'
  String _unitPref = 'mg';

  @override
  void initState() {
    super.initState();
    _loadUnitPref();
  }

  Future<void> _loadUnitPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unitPref = prefs.getString('lab_unit_preference') ?? 'mg';
    });
  }

  Future<void> _saveUnitPref(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lab_unit_preference', value);
    setState(() => _unitPref = value);
  }

  void _onSave() async {
    setState(() => _isUploading = true);

    final Map<String, String> units = {};
    for (var ind in _allIndicators) {
      units[ind['code'] as String] = ind['unit'] as String;
    }

    try {
      await ref.read(labEntryProvider.notifier).saveLabResults(
            recordedAt: _selectedDate,
            indicators: _values, // Already in mg/dL
            units: units,
            imageUrl: null,
          );

      if (!mounted) return;
      setState(() => _showSuccess = true);
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.errorSavingExt('$e')),
              backgroundColor: AppColors.textCritical),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _startOcrScan() async {
    try {
      final options =
          DocumentScannerOptions(mode: ScannerMode.filter, pageLimit: 1);
      final documentScanner = DocumentScanner(options: options);
      final result = await documentScanner.scanDocument();
      final images = result.images;
      if (images == null || images.isEmpty) return;

      final String imagePath = images.first;
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
      final String rawText = recognizedText.text;
      await textRecognizer.close();
      await documentScanner.close();

      final extracted = LabOcrParser.parseLabResults(rawText);
      if (!mounted) return;

      context.push(AppRouter.labReview, extra: {
        'extractedValues': extracted,
        'rawText': rawText,
        'recordedAt': _selectedDate,
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.errorScanningExt('$e')),
              backgroundColor: AppColors.textCritical),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await showExitConfirmDialog(context);
        if (shouldPop && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.enterLabResults),
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
        body: Stack(children: [
          _buildForm(context, l10n),
          if (_showSuccess) _buildSuccessOverlay(l10n),
        ]),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date picker ────────────────────────────────────────────────────
          Text(l10n.labDateTitle, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          DatePickerField(
            label: l10n.labDateLabel,
            selectedDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            onDateSelected: (date) => setState(() {
              _selectedDate = date;
              _isDirty = true;
            }),
          ),
          const SizedBox(height: 20),

          // ── Unit toggle ────────────────────────────────────────────────────
          _buildUnitToggle(l10n),
          const SizedBox(height: 20),

          // ── Indicator cards ────────────────────────────────────────────────
          ..._allIndicators.map((ind) => _buildIndicatorCard(ind, l10n)),
          const SizedBox(height: 24),

          // ── Save button ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.saveResultsManually,
                      style: AppTextStyles.h2.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),

          // ── OCR button ─────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _isUploading ? null : _startOcrScan,
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text(l10n.scanLabPaperOCR),
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: AppTextStyles.h3,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUnitToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBase.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.measurementUnit, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  _unitPref == 'mg'
                      ? l10n.unitStoredAsIsMg
                      : l10n.unitConvertedAutomaticallyMmol,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'mg', label: Text('mg/dL')),
              ButtonSegment(value: 'mmol', label: Text('mmol/L')),
            ],
            selected: {_unitPref},
            onSelectionChanged: (sel) {
              final newPref = sel.first;
              // Convert already-entered values
              setState(() {
                for (final code in _values.keys.toList()) {
                  final isConvertible = _allIndicators.any(
                      (i) => i['code'] == code && i['convertible'] == true);
                  if (!isConvertible) continue;
                  if (newPref == 'mmol' && _unitPref == 'mg') {
                    _values[code] = convertToMmol(code, _values[code]!);
                  } else if (newPref == 'mg' && _unitPref == 'mmol') {
                    _values[code] = convertToMg(code, _values[code]!);
                  }
                }
              });
              _saveUnitPref(newPref);
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay(AppLocalizations l10n) {
    return Animate(
      child: Container(
        color: AppColors.bgSurface.withValues(alpha: 0.9),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Animate(
              onPlay: (c) => c.repeat(reverse: true),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                    color: AppColors.textSuccess, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),
            )
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then()
                .shake(duration: 400.ms),
            const SizedBox(height: 24),
            Animate(
                    child: Text(l10n.dataSavedSuccessfully,
                        style: AppTextStyles.h2
                            .copyWith(color: AppColors.textPrimary)))
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.5, end: 0),
            const SizedBox(height: 8),
            Animate(
                    child: Text(l10n.updatingDashboard,
                        style: AppTextStyles.bodyM
                            .copyWith(color: AppColors.textSecondary)))
                .fadeIn(delay: 600.ms),
          ],
        ),
      ),
    ).fadeIn();
  }

  Widget _buildIndicatorCard(Map<String, dynamic> ind, AppLocalizations l10n) {
    final code = ind['code'] as String;
    final bool convertible = ind['convertible'] as bool? ?? false;
    final bool inMmol = _unitPref == 'mmol' && convertible;

    // Display unit
    final displayUnit = inMmol ? 'mmol/L' : ind['unit'] as String;

    // Safe range for bar — always in mg, but displayed scaled if mmol
    final double safeMinMg = (ind['safeMin'] as num).toDouble();
    final double safeMaxMg = (ind['safeMax'] as num).toDouble();
    final double minMg = (ind['min'] as num).toDouble();
    final double maxMg = (ind['max'] as num).toDouble();

    final double displaySafeMin =
        inMmol ? convertToMmol(code, safeMinMg) : safeMinMg;
    final double displaySafeMax =
        inMmol ? convertToMmol(code, safeMaxMg) : safeMaxMg;
    final double displayMin = inMmol ? convertToMmol(code, minMg) : minMg;
    final double displayMax = inMmol ? convertToMmol(code, maxMg) : maxMg;

    // Current display value (stored in mg internally)
    final double storedMg = _values[code] ?? 0.0;
    final double displayValue =
        inMmol ? convertToMmol(code, storedMg) : storedMg;

    // Warning message
    final String? warning = getLabWarning(code, storedMg, l10n);
    final String? note =
        code == 'hba1c' ? l10n.noteImportantForDiabeticCKD : null;
    final String labelName = getLocalizedLabName(code, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: AppColors.borderBase.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            const CircleAvatar(radius: 4, backgroundColor: Colors.blue),
            const SizedBox(width: 8),
            Text('$labelName ($code)', style: AppTextStyles.label),
          ]),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(note,
                style: AppTextStyles.bodyS
                    .copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 16),

          // Input field
          AppTextField(
            label: '',
            hint: '0.0',
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final sanitized = v.replaceAll('،', '.');
              final entered = double.tryParse(sanitized) ?? 0.0;
              setState(() {
                // Always store in mg
                _values[code] = inMmol ? convertToMg(code, entered) : entered;
                _isDirty = true;
              });
            },
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(displayUnit, style: AppTextStyles.bodyS),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            l10n.normalRange(displaySafeMin.toStringAsFixed(1),
                displaySafeMax.toStringAsFixed(1), displayUnit),
            style: AppTextStyles.bodyS,
          ),
          const SizedBox(height: 8),
          ThresholdBar(
            value: displayValue,
            min: displayMin,
            max: displayMax,
            safeMin: displaySafeMin,
            safeMax: displaySafeMax,
          ),

          // Warning
          if (warning != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: warning.startsWith('🔴')
                    ? AppColors.textCritical.withValues(alpha: 0.08)
                    : AppColors.textWarning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                warning,
                style: AppTextStyles.bodyS.copyWith(
                  color: warning.startsWith('🔴')
                      ? AppColors.textCritical
                      : AppColors.textWarning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
