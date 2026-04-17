// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'KidneyTrack';

  @override
  String get connectionError => 'خطأ في الاتصال بالخدمة';

  @override
  String get initErrorMessage =>
      'تعذر تهيئة التطبيق. يرجى التأكد من اتصال الإنترنت وإعادة المحاولة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get stage1 => 'المرحلة الأولى';

  @override
  String get stage2 => 'المرحلة الثانية';

  @override
  String get stage3 => 'المرحلة الثالثة';

  @override
  String get stage4 => 'المرحلة الرابعة';

  @override
  String get stage5 => 'المرحلة الخامسة';

  @override
  String get dialysis => 'غسيل كلى';

  @override
  String get dashboardLoadingSummary => 'جاري تحميل الملخص';

  @override
  String get dashboardCalculatingMetrics => 'جاري حساب المؤشرات';

  @override
  String errorLoadingData(Object task) {
    return 'عذراً، حدث خطأ أثناء $task';
  }

  @override
  String get checkInternetRetry =>
      'يرجى التأكد من اتصال الإنترنت ثم المحاولة مرة أخرى.';

  @override
  String get urgentMedicalAlert => 'تنبيه طبي عاجل';

  @override
  String get deteriorationMessage =>
      'تم رصد ارتفاع مستمر في نسب الكرياتينين — يرجى مراجعة طبيبك المختص للتقييم.';

  @override
  String get egfr => 'كفاءة الكلى (eGFR)';

  @override
  String get kidneyEfficiency => 'كفاءة الكلى (eGFR)';

  @override
  String kidneyStageDisplay(Object label, Object stage) {
    return 'المرحلة $stage: $label';
  }

  @override
  String get fluidOverload => 'احتباس السوائل';

  @override
  String get dryWeight => 'الوزن الجاف';

  @override
  String get currentWeight => 'الحالي';

  @override
  String get bpAverage => 'متوسط الضغط (الانقباضي)';

  @override
  String get controlRate => 'نسبة الانضباط';

  @override
  String get dailyPotassium => 'البوتاسيوم اليومي';

  @override
  String get remaining => 'المتبقي';

  @override
  String get nutrientPotassium => 'البوتاسيوم';

  @override
  String get nutrientPhosphorus => 'الفوسفور';

  @override
  String get nutrientSodium => 'الصوديوم';

  @override
  String get nutrientProtein => 'البروتين';

  @override
  String get unitMg => 'ملجم';

  @override
  String get unitG => 'جم';

  @override
  String get unitBpm => 'نبضة/د';

  @override
  String get statusExceeded => 'تجاوز الحد';

  @override
  String get statusApproaching => 'اقتراب من الحد';

  @override
  String get statusWithin => 'ضمن الحد';

  @override
  String get drugInteractionWarning => 'تحذير تفاعل دوائي-غذائي';

  @override
  String get medicalDisclaimer => 'للتوعية فقط ولا يغني عن استشارة الطبيب';

  @override
  String get todayNutrition => 'تغذية اليوم';

  @override
  String get quickGlance => 'نظرة سريعة';

  @override
  String get latestLabResults => 'أحدث التحاليل';

  @override
  String consecutiveDays(Object days) {
    return '$days أيام متواصلة!';
  }

  @override
  String get streakEncouragement => 'أنت من أكثر المرضى التزاماً 💪';

  @override
  String get heartRate => 'نبض القلب';

  @override
  String get bloodPressure => 'ضغط الدم';

  @override
  String get importantAlert => 'تنبيه هام';

  @override
  String get safetyAlert => 'تنبيه السلامة';

  @override
  String get healthInfo => 'المعلومات الصحية';

  @override
  String get birthDateAge => 'تاريخ الميلاد / العمر';

  @override
  String get years => 'سنة';

  @override
  String get tapToSelect => 'اضغط للتحديد';

  @override
  String get targetBp => 'ضغط الدم المستهدف';

  @override
  String get height => 'الطول';

  @override
  String get weight => 'الوزن';

  @override
  String get unitCm => 'سم';

  @override
  String get unitKg => 'كجم';

  @override
  String get fluidLimit => 'الحد اليومي للسوائل';

  @override
  String get potassiumLimit => 'الحد اليومي للبوتاسيوم';

  @override
  String get phosphorusLimit => 'الحد اليومي للفوسفور';

  @override
  String get sodiumLimit => 'الحد اليومي للصوديوم';

  @override
  String get proteinLimit => 'الحد اليومي للبروتين';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get notificationsComingSoon => 'قريباً في التحديث القادم';

  @override
  String get language => 'اللغة';

  @override
  String get security => 'الأمان';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get edit => 'تعديل';

  @override
  String get save => 'حفظ';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get patient => 'المريض';

  @override
  String get noDialysis => 'بدون غسيل';

  @override
  String get hemodialysis => 'غسيل دموي';

  @override
  String get peritonealDialysis => 'غسيل بريتوني';

  @override
  String get kidneyTransplant => 'زراعة كلى';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get systolic => 'الانقباضي (Systolic)';

  @override
  String get diastolic => 'الانبساطي (Diastolic)';

  @override
  String get editTargetBp => 'تعديل ضغط الدم المستهدف';

  @override
  String get healthDataHistory => 'سجل البيانات الصحية';

  @override
  String get showCharts => 'عرض الرسوم البيانية';

  @override
  String get showTimeline => 'عرض السجل الزمني';

  @override
  String get weightFluid => 'الوزن والسوائل';

  @override
  String get weightTrend => 'تطور الوزن (كجم)';

  @override
  String get bpTrend => 'ضغط الدم (mmHg)';

  @override
  String get kidneyLabs => 'تحاليل الكلى';

  @override
  String get heartSugar => 'القلب والسكر';

  @override
  String get mineralsVitamins => 'معادن وفيتامينات';

  @override
  String get nutritionSummary => 'الملخص الغذائي';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get noWeightData => 'لا توجد بيانات وزن';

  @override
  String get noFluidData => 'لا توجد بيانات سوائل';

  @override
  String get noBpData => 'لا توجد بيانات ضغط دم';

  @override
  String goalMl(int value) {
    return 'الهدف: $value مل';
  }

  @override
  String get targetSystolicLabel => 'الهدف انقباضي';

  @override
  String get targetDiastolicLabel => 'الهدف انبساطي';

  @override
  String get minLimit => 'أدنى';

  @override
  String get maxLimit => 'أقصى';

  @override
  String get potassiumTrend => 'تطور البوتاسيوم (ملجم)';

  @override
  String get phosphorusTrend => 'تطور الفوسفور (ملجم)';

  @override
  String get sodiumTrend => 'تطور الصوديوم (ملجم)';

  @override
  String get proteinTrend => 'تطور البروتين (جم)';

  @override
  String get totalFluidIntake => 'إجمالي السوائل اليومي (مل)';

  @override
  String get unitMl => 'مل';

  @override
  String get myMedications => 'أدويتي';

  @override
  String get allMedications => 'كل الأدوية';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPending => 'قيد الانتظار';

  @override
  String get filterTaken => 'تم الأخذ';

  @override
  String get filterMissed => 'فاتت الجرعة';

  @override
  String get noMedicationsAdded => 'لم تقم بإضافة أي أدوية بعد';

  @override
  String get noFilteredMedications => 'لا توجد أدوية تطابق هذا الفلتر';

  @override
  String get resetFilter => 'إعادة تعيين الفلتر';

  @override
  String get addMedication => 'إضافة دواء';

  @override
  String get addNewMedication => 'إضافة دواء جديد';

  @override
  String get takeDose => 'أخذ الجرعة';

  @override
  String get remindMe => 'ذكرني';

  @override
  String get medicationDetails => 'تفاصيل الدواء';

  @override
  String get todayDoses => 'جرعات اليوم';

  @override
  String get noScheduledDosesToday => 'لا توجد جرعات مقررة اليوم';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get searchMedicationHint => 'ابحث عن اسم الدواء...';

  @override
  String get medicationNameRequired => 'يرجى إدخال اسم الدواء';

  @override
  String get dosage => 'الجرعة';

  @override
  String get dosageHint => 'مثال: 500mg - قرصان';

  @override
  String get dosageRequired => 'يرجى إدخال الجرعة';

  @override
  String get doseTimes => 'مواعيد الجرعات';

  @override
  String get addAnotherTime => 'إضافة موعد آخر';

  @override
  String get additionalNotes => 'ملاحظات إضافية';

  @override
  String get notesHint => 'مثل: قبل الأكل بفترة قصيرة';

  @override
  String get saveMedication => 'حفظ الدواء';

  @override
  String saveError(Object error) {
    return 'خطأ في الحفظ: $error';
  }

  @override
  String get drugSafetyInfo => 'معلومات السلامة الدوائية';

  @override
  String get highRiskMedicationWarning => 'تنبيه: دواء مرتفع الخطورة';

  @override
  String get adjustmentRequired => 'تعديل الجرعة مطلوب';

  @override
  String get completelySafeMedication => 'دواء آمن كلياً';

  @override
  String nephrotoxicWarning(String medName) {
    return 'تحذير هام: [$medName] قد يؤثر سلباً على وظائف الكلى. يرجى مراجعة طبيبك المعالج لتأكيد الاستخدام.';
  }

  @override
  String doseAdjustmentCritical(String medName) {
    return 'تحذير: [$medName] يتطلب تعديل جرعة حرج بناءً على ضعف وظائف الكلى الشديد لديك. يرجى استشارة الطبيب فوراً.';
  }

  @override
  String doseAdjustmentWarning(String medName) {
    return 'تنبيه: [$medName] قد يحتاج إلى تعديل في الجرعة بناءً على وظائف كليتك (eGFR). يرجى استشارة الصيدلي أو الطبيب.';
  }

  @override
  String potassiumInteractionWarning(String medNames) {
    return 'تحذير هام: أنت تتناول أدوية ترفع البوتاسيوم ($medNames)، وقد تجاوزت حد البوتاسيوم الغذائي اليوم! يرجى مراجعة طبيبك المعالج فوراً.';
  }

  @override
  String phosphorusInteractionWarning(String medName) {
    return 'تنبيه: تناول [$medName] مع نظام غذائي عالي الفوسفور قد يؤثر على مستوياته. يرجى الانتباه لحصتك من الفوسفور.';
  }

  @override
  String sodiumInteractionWarning(String medName) {
    return 'تنبيه: [$medName] قد يؤثر على احتباس الصوديوم. تجاوزت الحد اليومي المسموح. استشر طبيبك.';
  }

  @override
  String get medicalBannerTitleCritical => 'تحذير طبي حرج';

  @override
  String get medicalBannerTitleWarning => 'تنبيه طبي';

  @override
  String get medicalBannerTitleInfo => 'معلومة صحية';

  @override
  String get frequency => 'التكرار';

  @override
  String get instructions => 'التعليمات';

  @override
  String get highRisk => 'خطورة عالية';

  @override
  String get medicalWarning => 'تحذير طبي';

  @override
  String scheduleLabel(String times) {
    return 'المواعيد: $times';
  }

  @override
  String get frequencyDaily => 'يومي';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get pointCameraAtBarcode => 'وجّه الكاميرا نحو باركود المنتج';

  @override
  String get manualBarcodeEntry => 'إدخال الباركود يدوياً';

  @override
  String get analyzingProduct => 'جارٍ تحليل المنتج...';

  @override
  String productNotFound(String barcode) {
    return 'لم يتم العثور على المنتج ($barcode)';
  }

  @override
  String get errorSearching => 'حدث خطأ أثناء البحث';

  @override
  String get enterBarcodeNumber => 'أدخل رقم الباركود';

  @override
  String get barcodeExample => 'مثال: 089686120134';

  @override
  String get search => 'بحث';

  @override
  String get searchFoods => 'بحث عن الأطعمة';

  @override
  String get searchProductHint => 'ابحث عن منتج (مثلاً: أرز، زبادي...)';

  @override
  String get searchAnyFoodOrBrand => 'ابحث عن أي نوع طعام أو ماركة';

  @override
  String get noMatchingResults => 'لم نجد نتائج مطابقة';

  @override
  String get nutritionalFactsHint =>
      'سنزودك بالحقائق الغذائية المناسبة لمرضى الكلى';

  @override
  String get ensureCorrectSpelling => 'تأكد من كتابة الاسم بشكل صحيح';

  @override
  String get dataNotAvailable => 'داتا غير متوفرة';

  @override
  String productAnalysisResults(String product) {
    return 'نتائج تحليل المنتج $product';
  }

  @override
  String get close => 'إغلاق';

  @override
  String nutritionalAnalysisPerGrams(String grams) {
    return 'التحليل الغذائي (لكل $grams جم)';
  }

  @override
  String get nutrientSugars => 'السكريات';

  @override
  String get nutrientCalories => 'السعرات';

  @override
  String get unitCalorie => 'سعرة';

  @override
  String get verifiedChoice => 'خيار موثق';

  @override
  String get manualEntry => 'إدخال يدوي';

  @override
  String get smartEstimation => 'تقدير ذكي';

  @override
  String get unknown => 'غير معروف';

  @override
  String get howMuchWillYouConsume => 'ما هي الكمية التي ستتناولها؟';

  @override
  String get valuesMayDifferWarning =>
      '⚠️ قد تختلف هذه القيم عن الملصق الحالي. تحقق دائماً يدويًا قبل الاعتماد على البيانات.';

  @override
  String get dismissWarning => 'تجاهل التنبيه';

  @override
  String get avoidThisProduct => 'تجنب هذا المنتج';

  @override
  String get consumeWithCaution => 'تناوله بحذر';

  @override
  String get relativelySafeChoice => 'خيار آمن نسبياً';

  @override
  String get foodDrugInteraction => 'تفاعل دوائي مع الطعام';

  @override
  String editNutrient(String nutrient) {
    return 'تعديل $nutrient';
  }

  @override
  String get valuePer100g => 'القيمة لكل 100 جم';

  @override
  String get saveToDailyLog => 'احفظ في سجلي اليومي';

  @override
  String get pleaseLoginFirst => 'الرجاء تسجيل الدخول أولاً';

  @override
  String get missingData => 'بيانات مفقودة ⚠️';

  @override
  String get labCreatinine => 'الكرياتينين';

  @override
  String get labPotassium => 'البوتاسيوم';

  @override
  String get labUrea => 'اليوريا';

  @override
  String get labSodium => 'الصوديوم';

  @override
  String get labHemoglobin => 'الهيموجلوبين';

  @override
  String get labPhosphorus => 'الفوسفور';

  @override
  String get labHbA1c => 'السكر التراكمي (HbA1c)';

  @override
  String get labTotalCholesterol => 'الكوليسترول الكلي';

  @override
  String get labLDL => 'LDL الكوليسترول الضار';

  @override
  String get labTriglycerides => 'الدهون الثلاثية';

  @override
  String get labCalcium => 'الكالسيوم';

  @override
  String get labVitaminD => 'فيتامين D';

  @override
  String get labBloodPhosphorus => 'فوسفور الدم';

  @override
  String get labUrineACR => 'ألبومين/كرياتينين البول';

  @override
  String get noteImportantForDiabeticCKD => 'مهم لمرضى الكلى السكريين';

  @override
  String get enterLabResults => 'إدخال نتائج المختبر';

  @override
  String get labDateTitle => 'تاريخ التحاليل';

  @override
  String get labDateLabel => 'تاريخ التحليل';

  @override
  String get saveResultsManually => 'حفظ النتائج يدوياً';

  @override
  String get scanLabPaperOCR => 'مسح ورقة التحليل آلياً (OCR)';

  @override
  String get measurementUnit => 'وحدة القياس';

  @override
  String get unitStoredAsIsMg => 'القيم المُدخلة بـ mg/dL — تُحفظ كما هي';

  @override
  String get unitConvertedAutomaticallyMmol =>
      'القيم المُدخلة بـ mmol/L — تُحوَّل تلقائياً عند الحفظ';

  @override
  String get dataSavedSuccessfully => 'تم حفظ البيانات بنجاح!';

  @override
  String get updatingDashboard => 'جاري تحديث لوحة التحكم...';

  @override
  String normalRange(String min, String max, String unit) {
    return 'المدى الطبيعي: $min – $max $unit';
  }

  @override
  String errorSavingExt(String error) {
    return 'خطأ في الحفظ: $error';
  }

  @override
  String errorScanningExt(String error) {
    return 'فشل المسح: $error';
  }

  @override
  String labWarningCriticalHigh(String name) {
    return '🔴 $name مرتفع بشكل ملحوظ — يُنصح بالتواصل مع طبيبك قريباً';
  }

  @override
  String labWarningHigh(String name) {
    return '⚠ $name أعلى من المعتاد قليلاً — راقبه وأبلغ طبيبك في الزيارة القادمة';
  }

  @override
  String labWarningCriticalLow(String name) {
    return '🔴 $name منخفض بشكل ملحوظ — يُنصح بالتواصل مع طبيبك قريباً';
  }

  @override
  String labWarningLow(String name) {
    return '⚠ $name أقل من المعتاد قليلاً — راقبه وأبلغ طبيبك في الزيارة القادمة';
  }

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';
}
