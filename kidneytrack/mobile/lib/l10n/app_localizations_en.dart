// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KidneyTrack';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get initErrorMessage =>
      'Failed to initialize the application. Please check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get stage1 => 'Stage 1';

  @override
  String get stage2 => 'Stage 2';

  @override
  String get stage3 => 'Stage 3';

  @override
  String get stage4 => 'Stage 4';

  @override
  String get stage5 => 'Stage 5';

  @override
  String get dialysis => 'Dialysis';

  @override
  String get dashboardLoadingSummary => 'Loading summary';

  @override
  String get dashboardCalculatingMetrics => 'Calculating metrics';

  @override
  String errorLoadingData(Object task) {
    return 'Sorry, an error occurred while $task';
  }

  @override
  String get checkInternetRetry =>
      'Please check your internet connection and try again.';

  @override
  String get urgentMedicalAlert => 'Urgent Medical Alert';

  @override
  String get deteriorationMessage =>
      'A persistent rise in creatinine levels has been detected — please consult your specialist for evaluation.';

  @override
  String get egfr => 'eGFR';

  @override
  String get kidneyEfficiency => 'Kidney Efficiency (eGFR)';

  @override
  String kidneyStageDisplay(Object label, Object stage) {
    return 'Stage $stage: $label';
  }

  @override
  String get fluidOverload => 'Fluid Overload';

  @override
  String get dryWeight => 'Dry Weight';

  @override
  String get currentWeight => 'Current Weight';

  @override
  String get bpAverage => 'Avg Pressure (Systolic)';

  @override
  String get controlRate => 'Control Rate';

  @override
  String get dailyPotassium => 'Daily Potassium';

  @override
  String get remaining => 'Remaining';

  @override
  String get nutrientPotassium => 'Potassium';

  @override
  String get nutrientPhosphorus => 'Phosphorus';

  @override
  String get nutrientSodium => 'Sodium';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get unitMg => 'mg';

  @override
  String get unitG => 'g';

  @override
  String get unitBpm => 'bpm';

  @override
  String get statusExceeded => 'Exceeded Limit';

  @override
  String get statusApproaching => 'Approaching Limit';

  @override
  String get statusWithin => 'Within Limit';

  @override
  String get drugInteractionWarning => 'Drug-Nutrient Interaction Warning';

  @override
  String get medicalDisclaimer =>
      'For awareness only; does not replace physician consultation.';

  @override
  String get todayNutrition => 'Today\'s Nutrition';

  @override
  String get quickGlance => 'Quick Glance';

  @override
  String get latestLabResults => 'Latest Lab Results';

  @override
  String consecutiveDays(Object days) {
    return '$days Consecutive Days!';
  }

  @override
  String get streakEncouragement =>
      'You are among the most committed patients!';

  @override
  String get heartRate => 'Heart Rate';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get importantAlert => 'Important Alert';

  @override
  String get safetyAlert => 'Safety Alert';

  @override
  String get healthInfo => 'Health Information';

  @override
  String get birthDateAge => 'Birth Date / Age';

  @override
  String get years => 'years';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get targetBp => 'Target Blood Pressure';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get unitCm => 'cm';

  @override
  String get unitKg => 'kg';

  @override
  String get fluidLimit => 'Fluid Limit';

  @override
  String get potassiumLimit => 'Potassium Limit';

  @override
  String get phosphorusLimit => 'Phosphorus Limit';

  @override
  String get sodiumLimit => 'Sodium Limit';

  @override
  String get proteinLimit => 'Protein Limit';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsComingSoon => 'Coming soon in the next update';

  @override
  String get language => 'Language';

  @override
  String get security => 'Security';

  @override
  String get changePassword => 'Change Password';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get patient => 'Patient';

  @override
  String get noDialysis => 'No Dialysis';

  @override
  String get hemodialysis => 'Hemodialysis';

  @override
  String get peritonealDialysis => 'Peritoneal Dialysis';

  @override
  String get kidneyTransplant => 'Kidney Transplant';

  @override
  String get notSpecified => 'Not Specified';

  @override
  String get systolic => 'Systolic';

  @override
  String get diastolic => 'Diastolic';

  @override
  String get editTargetBp => 'Edit Target Blood Pressure';

  @override
  String get healthDataHistory => 'Health Data History';

  @override
  String get showCharts => 'Show Charts';

  @override
  String get showTimeline => 'Show Timeline';

  @override
  String get weightFluid => 'Weight & Fluids';

  @override
  String get weightTrend => 'Weight Trend (kg)';

  @override
  String get bpTrend => 'Blood Pressure (mmHg)';

  @override
  String get kidneyLabs => 'Kidney Labs';

  @override
  String get heartSugar => 'Heart & Sugar';

  @override
  String get mineralsVitamins => 'Minerals & Vitamins';

  @override
  String get nutritionSummary => 'Nutrition Summary';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noResults => 'No results';

  @override
  String get noWeightData => 'No weight data';

  @override
  String get noFluidData => 'No fluid data';

  @override
  String get noBpData => 'No blood pressure data';

  @override
  String goalMl(int value) {
    return 'Goal: ${value}ml';
  }

  @override
  String get targetSystolicLabel => 'Target Systolic';

  @override
  String get targetDiastolicLabel => 'Target Diastolic';

  @override
  String get minLimit => 'Min';

  @override
  String get maxLimit => 'Max';

  @override
  String get potassiumTrend => 'Potassium Trend (mg)';

  @override
  String get phosphorusTrend => 'Phosphorus Trend (mg)';

  @override
  String get sodiumTrend => 'Sodium Trend (mg)';

  @override
  String get proteinTrend => 'Protein Trend (g)';

  @override
  String get totalFluidIntake => 'Total Daily Fluids (ml)';

  @override
  String get unitMl => 'ml';

  @override
  String get myMedications => 'My Medications';

  @override
  String get allMedications => 'All Medications';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterTaken => 'Taken';

  @override
  String get filterMissed => 'Missed';

  @override
  String get noMedicationsAdded => 'You haven\'t added any medications yet';

  @override
  String get noFilteredMedications => 'No medications match this filter';

  @override
  String get resetFilter => 'Reset Filter';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get addNewMedication => 'Add New Medication';

  @override
  String get takeDose => 'Take Dose';

  @override
  String get remindMe => 'Remind Me';

  @override
  String get medicationDetails => 'Medication Details';

  @override
  String get todayDoses => 'Today\'s Doses';

  @override
  String get noScheduledDosesToday => 'No doses scheduled for today';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get searchMedicationHint => 'Search for medication name...';

  @override
  String get medicationNameRequired => 'Please enter medication name';

  @override
  String get dosage => 'Dosage';

  @override
  String get dosageHint => 'Example: 500mg - 2 tablets';

  @override
  String get dosageRequired => 'Please enter dosage';

  @override
  String get doseTimes => 'Dose Times';

  @override
  String get addAnotherTime => 'Add another time';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get notesHint => 'e.g., shortly before meals';

  @override
  String get saveMedication => 'Save Medication';

  @override
  String saveError(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get drugSafetyInfo => 'Drug Safety Information';

  @override
  String get highRiskMedicationWarning => 'Alert: High Risk Medication';

  @override
  String get adjustmentRequired => 'Dose adjustment required';

  @override
  String get completelySafeMedication => 'Completely safe medication';

  @override
  String nephrotoxicWarning(String medName) {
    return 'Important Alert: $medName may negatively affect kidney function. Please review with your physician.';
  }

  @override
  String doseAdjustmentCritical(String medName) {
    return 'Critical Alert: $medName requires a critical dose adjustment based on your severe kidney function decline. Consult physician immediately.';
  }

  @override
  String doseAdjustmentWarning(String medName) {
    return 'Alert: $medName may need dose adjustment based on your kidney function (eGFR). Consult pharmacist or physician.';
  }

  @override
  String potassiumInteractionWarning(String medNames) {
    return 'Important Alert: You are taking potassium-raising medications ($medNames), and you have exceeded your daily potassium limit! Consult physician immediately.';
  }

  @override
  String phosphorusInteractionWarning(String medName) {
    return 'Alert: Taking $medName with a high phosphorus diet may affect levels. Watch your phosphorus intake.';
  }

  @override
  String sodiumInteractionWarning(String medName) {
    return 'Alert: $medName may affect sodium retention. You have exceeded the daily limit. Consult physician.';
  }

  @override
  String get medicalBannerTitleCritical => 'Critical Medical Warning';

  @override
  String get medicalBannerTitleWarning => 'Medical Alert';

  @override
  String get medicalBannerTitleInfo => 'Health Information';

  @override
  String get frequency => 'Frequency';

  @override
  String get instructions => 'Instructions';

  @override
  String get highRisk => 'High Risk';

  @override
  String get medicalWarning => 'Medical Warning';

  @override
  String scheduleLabel(String times) {
    return 'Schedule: $times';
  }

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get pointCameraAtBarcode => 'Point camera at product barcode';

  @override
  String get manualBarcodeEntry => 'Enter Barcode Manually';

  @override
  String get analyzingProduct => 'Analyzing product...';

  @override
  String productNotFound(String barcode) {
    return 'Product not found ($barcode)';
  }

  @override
  String get errorSearching => 'An error occurred during search';

  @override
  String get enterBarcodeNumber => 'Enter Barcode Number';

  @override
  String get barcodeExample => 'Example: 089686120134';

  @override
  String get search => 'Search';

  @override
  String get searchFoods => 'Search Foods';

  @override
  String get searchProductHint =>
      'Search for a product (e.g., Rice, Yogurt...)';

  @override
  String get searchAnyFoodOrBrand => 'Search for any food or brand';

  @override
  String get noMatchingResults => 'No matching results found';

  @override
  String get nutritionalFactsHint =>
      'We will provide you with kidney-friendly nutritional facts';

  @override
  String get ensureCorrectSpelling => 'Make sure the name is spelled correctly';

  @override
  String get dataNotAvailable => 'Data not available';

  @override
  String productAnalysisResults(String product) {
    return 'Product Analysis Results $product';
  }

  @override
  String get close => 'Close';

  @override
  String nutritionalAnalysisPerGrams(String grams) {
    return 'Nutritional Analysis (per $grams g)';
  }

  @override
  String get nutrientSugars => 'Sugars';

  @override
  String get nutrientCalories => 'Calories';

  @override
  String get unitCalorie => 'kcal';

  @override
  String get verifiedChoice => 'Verified Choice';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get smartEstimation => 'Smart Estimation';

  @override
  String get unknown => 'Unknown';

  @override
  String get howMuchWillYouConsume => 'How much will you consume?';

  @override
  String get valuesMayDifferWarning =>
      '⚠️ These values may differ from the actual label; Verify manually before relying on this data.';

  @override
  String get dismissWarning => 'Dismiss Warning';

  @override
  String get avoidThisProduct => 'Avoid this product';

  @override
  String get consumeWithCaution => 'Consume with caution';

  @override
  String get relativelySafeChoice => 'Relatively safe choice';

  @override
  String get foodDrugInteraction => 'Food-Drug Interaction';

  @override
  String editNutrient(String nutrient) {
    return 'Edit $nutrient';
  }

  @override
  String get valuePer100g => 'Value per 100g';

  @override
  String get saveToDailyLog => 'Save to My Daily Log';

  @override
  String get pleaseLoginFirst => 'Please login first';

  @override
  String get missingData => 'Missing Data ⚠️';

  @override
  String get labCreatinine => 'Creatinine';

  @override
  String get labPotassium => 'Potassium';

  @override
  String get labUrea => 'Urea';

  @override
  String get labSodium => 'Sodium';

  @override
  String get labHemoglobin => 'Hemoglobin';

  @override
  String get labPhosphorus => 'Phosphorus';

  @override
  String get labHbA1c => 'HbA1c';

  @override
  String get labTotalCholesterol => 'Total Cholesterol';

  @override
  String get labLDL => 'LDL Cholesterol';

  @override
  String get labTriglycerides => 'Triglycerides';

  @override
  String get labCalcium => 'Calcium';

  @override
  String get labVitaminD => 'Vitamin D';

  @override
  String get labBloodPhosphorus => 'Blood Phosphorus';

  @override
  String get labUrineACR => 'Urine ACR';

  @override
  String get noteImportantForDiabeticCKD =>
      'Important for diabetic CKD patients';

  @override
  String get enterLabResults => 'Enter Lab Results';

  @override
  String get labDateTitle => 'Lab Date';

  @override
  String get labDateLabel => 'Lab Date';

  @override
  String get saveResultsManually => 'Save Results Manually';

  @override
  String get scanLabPaperOCR => 'Scan Lab Paper (OCR)';

  @override
  String get measurementUnit => 'Measurement Unit';

  @override
  String get unitStoredAsIsMg => 'Values entered in mg/dL — saved as is';

  @override
  String get unitConvertedAutomaticallyMmol =>
      'Values entered in mmol/L — converted automatically when saving';

  @override
  String get dataSavedSuccessfully => 'Data saved successfully!';

  @override
  String get updatingDashboard => 'Updating dashboard...';

  @override
  String normalRange(String min, String max, String unit) {
    return 'Normal Range: $min – $max $unit';
  }

  @override
  String errorSavingExt(String error) {
    return 'Error saving: $error';
  }

  @override
  String errorScanningExt(String error) {
    return 'Scan failed: $error';
  }

  @override
  String labWarningCriticalHigh(String name) {
    return '🔴 $name is noticeably high — advising to contact your doctor soon';
  }

  @override
  String labWarningHigh(String name) {
    return '⚠ $name is slightly higher than usual — monitor it and inform your doctor next visit';
  }

  @override
  String labWarningCriticalLow(String name) {
    return '🔴 $name is noticeably low — advising to contact your doctor soon';
  }

  @override
  String labWarningLow(String name) {
    return '⚠ $name is slightly lower than usual — monitor it and inform your doctor next visit';
  }

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';
}
