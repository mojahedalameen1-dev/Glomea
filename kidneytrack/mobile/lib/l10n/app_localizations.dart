import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'KidneyTrack'**
  String get appTitle;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @initErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize the application. Please check your internet connection and try again.'**
  String get initErrorMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @stage1.
  ///
  /// In en, this message translates to:
  /// **'Stage 1'**
  String get stage1;

  /// No description provided for @stage2.
  ///
  /// In en, this message translates to:
  /// **'Stage 2'**
  String get stage2;

  /// No description provided for @stage3.
  ///
  /// In en, this message translates to:
  /// **'Stage 3'**
  String get stage3;

  /// No description provided for @stage4.
  ///
  /// In en, this message translates to:
  /// **'Stage 4'**
  String get stage4;

  /// No description provided for @stage5.
  ///
  /// In en, this message translates to:
  /// **'Stage 5'**
  String get stage5;

  /// Dialysis stage
  ///
  /// In en, this message translates to:
  /// **'Dialysis'**
  String get dialysis;

  /// No description provided for @dashboardLoadingSummary.
  ///
  /// In en, this message translates to:
  /// **'Loading summary'**
  String get dashboardLoadingSummary;

  /// No description provided for @dashboardCalculatingMetrics.
  ///
  /// In en, this message translates to:
  /// **'Calculating metrics'**
  String get dashboardCalculatingMetrics;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred while {task}'**
  String errorLoadingData(Object task);

  /// No description provided for @checkInternetRetry.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkInternetRetry;

  /// No description provided for @urgentMedicalAlert.
  ///
  /// In en, this message translates to:
  /// **'Urgent Medical Alert'**
  String get urgentMedicalAlert;

  /// No description provided for @deteriorationMessage.
  ///
  /// In en, this message translates to:
  /// **'A persistent rise in creatinine levels has been detected — please consult your specialist for evaluation.'**
  String get deteriorationMessage;

  /// No description provided for @egfr.
  ///
  /// In en, this message translates to:
  /// **'eGFR'**
  String get egfr;

  /// No description provided for @kidneyEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Kidney Efficiency (eGFR)'**
  String get kidneyEfficiency;

  /// No description provided for @kidneyStageDisplay.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage}: {label}'**
  String kidneyStageDisplay(Object label, Object stage);

  /// No description provided for @fluidOverload.
  ///
  /// In en, this message translates to:
  /// **'Fluid Overload'**
  String get fluidOverload;

  /// No description provided for @dryWeight.
  ///
  /// In en, this message translates to:
  /// **'Dry Weight'**
  String get dryWeight;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @bpAverage.
  ///
  /// In en, this message translates to:
  /// **'Avg Pressure (Systolic)'**
  String get bpAverage;

  /// No description provided for @controlRate.
  ///
  /// In en, this message translates to:
  /// **'Control Rate'**
  String get controlRate;

  /// No description provided for @dailyPotassium.
  ///
  /// In en, this message translates to:
  /// **'Daily Potassium'**
  String get dailyPotassium;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @nutrientPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get nutrientPotassium;

  /// No description provided for @nutrientPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus'**
  String get nutrientPhosphorus;

  /// No description provided for @nutrientSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutrientSodium;

  /// No description provided for @nutrientProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// No description provided for @unitMg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get unitMg;

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @unitBpm.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get unitBpm;

  /// No description provided for @statusExceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded Limit'**
  String get statusExceeded;

  /// No description provided for @statusApproaching.
  ///
  /// In en, this message translates to:
  /// **'Approaching Limit'**
  String get statusApproaching;

  /// No description provided for @statusWithin.
  ///
  /// In en, this message translates to:
  /// **'Within Limit'**
  String get statusWithin;

  /// No description provided for @drugInteractionWarning.
  ///
  /// In en, this message translates to:
  /// **'Drug-Nutrient Interaction Warning'**
  String get drugInteractionWarning;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'For awareness only; does not replace physician consultation.'**
  String get medicalDisclaimer;

  /// No description provided for @todayNutrition.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Nutrition'**
  String get todayNutrition;

  /// No description provided for @quickGlance.
  ///
  /// In en, this message translates to:
  /// **'Quick Glance'**
  String get quickGlance;

  /// No description provided for @latestLabResults.
  ///
  /// In en, this message translates to:
  /// **'Latest Lab Results'**
  String get latestLabResults;

  /// No description provided for @consecutiveDays.
  ///
  /// In en, this message translates to:
  /// **'{days} Consecutive Days!'**
  String consecutiveDays(Object days);

  /// No description provided for @streakEncouragement.
  ///
  /// In en, this message translates to:
  /// **'You are among the most committed patients!'**
  String get streakEncouragement;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @importantAlert.
  ///
  /// In en, this message translates to:
  /// **'Important Alert'**
  String get importantAlert;

  /// No description provided for @safetyAlert.
  ///
  /// In en, this message translates to:
  /// **'Safety Alert'**
  String get safetyAlert;

  /// No description provided for @healthInfo.
  ///
  /// In en, this message translates to:
  /// **'Health Information'**
  String get healthInfo;

  /// No description provided for @birthDateAge.
  ///
  /// In en, this message translates to:
  /// **'Birth Date / Age'**
  String get birthDateAge;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @targetBp.
  ///
  /// In en, this message translates to:
  /// **'Target Blood Pressure'**
  String get targetBp;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @fluidLimit.
  ///
  /// In en, this message translates to:
  /// **'Fluid Limit'**
  String get fluidLimit;

  /// No description provided for @potassiumLimit.
  ///
  /// In en, this message translates to:
  /// **'Potassium Limit'**
  String get potassiumLimit;

  /// No description provided for @phosphorusLimit.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus Limit'**
  String get phosphorusLimit;

  /// No description provided for @sodiumLimit.
  ///
  /// In en, this message translates to:
  /// **'Sodium Limit'**
  String get sodiumLimit;

  /// No description provided for @proteinLimit.
  ///
  /// In en, this message translates to:
  /// **'Protein Limit'**
  String get proteinLimit;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon in the next update'**
  String get notificationsComingSoon;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @noDialysis.
  ///
  /// In en, this message translates to:
  /// **'No Dialysis'**
  String get noDialysis;

  /// No description provided for @hemodialysis.
  ///
  /// In en, this message translates to:
  /// **'Hemodialysis'**
  String get hemodialysis;

  /// No description provided for @peritonealDialysis.
  ///
  /// In en, this message translates to:
  /// **'Peritoneal Dialysis'**
  String get peritonealDialysis;

  /// No description provided for @kidneyTransplant.
  ///
  /// In en, this message translates to:
  /// **'Kidney Transplant'**
  String get kidneyTransplant;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @editTargetBp.
  ///
  /// In en, this message translates to:
  /// **'Edit Target Blood Pressure'**
  String get editTargetBp;

  /// No description provided for @healthDataHistory.
  ///
  /// In en, this message translates to:
  /// **'Health Data History'**
  String get healthDataHistory;

  /// No description provided for @showCharts.
  ///
  /// In en, this message translates to:
  /// **'Show Charts'**
  String get showCharts;

  /// No description provided for @showTimeline.
  ///
  /// In en, this message translates to:
  /// **'Show Timeline'**
  String get showTimeline;

  /// No description provided for @weightFluid.
  ///
  /// In en, this message translates to:
  /// **'Weight & Fluids'**
  String get weightFluid;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight Trend (kg)'**
  String get weightTrend;

  /// No description provided for @bpTrend.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure (mmHg)'**
  String get bpTrend;

  /// No description provided for @kidneyLabs.
  ///
  /// In en, this message translates to:
  /// **'Kidney Labs'**
  String get kidneyLabs;

  /// No description provided for @heartSugar.
  ///
  /// In en, this message translates to:
  /// **'Heart & Sugar'**
  String get heartSugar;

  /// No description provided for @mineralsVitamins.
  ///
  /// In en, this message translates to:
  /// **'Minerals & Vitamins'**
  String get mineralsVitamins;

  /// No description provided for @nutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Summary'**
  String get nutritionSummary;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noWeightData.
  ///
  /// In en, this message translates to:
  /// **'No weight data'**
  String get noWeightData;

  /// No description provided for @noFluidData.
  ///
  /// In en, this message translates to:
  /// **'No fluid data'**
  String get noFluidData;

  /// No description provided for @noBpData.
  ///
  /// In en, this message translates to:
  /// **'No blood pressure data'**
  String get noBpData;

  /// No description provided for @goalMl.
  ///
  /// In en, this message translates to:
  /// **'Goal: {value}ml'**
  String goalMl(int value);

  /// No description provided for @targetSystolicLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Systolic'**
  String get targetSystolicLabel;

  /// No description provided for @targetDiastolicLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Diastolic'**
  String get targetDiastolicLabel;

  /// No description provided for @minLimit.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minLimit;

  /// No description provided for @maxLimit.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxLimit;

  /// No description provided for @potassiumTrend.
  ///
  /// In en, this message translates to:
  /// **'Potassium Trend (mg)'**
  String get potassiumTrend;

  /// No description provided for @phosphorusTrend.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus Trend (mg)'**
  String get phosphorusTrend;

  /// No description provided for @sodiumTrend.
  ///
  /// In en, this message translates to:
  /// **'Sodium Trend (mg)'**
  String get sodiumTrend;

  /// No description provided for @proteinTrend.
  ///
  /// In en, this message translates to:
  /// **'Protein Trend (g)'**
  String get proteinTrend;

  /// No description provided for @totalFluidIntake.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Fluids (ml)'**
  String get totalFluidIntake;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @myMedications.
  ///
  /// In en, this message translates to:
  /// **'My Medications'**
  String get myMedications;

  /// No description provided for @allMedications.
  ///
  /// In en, this message translates to:
  /// **'All Medications'**
  String get allMedications;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get filterTaken;

  /// No description provided for @filterMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get filterMissed;

  /// No description provided for @noMedicationsAdded.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any medications yet'**
  String get noMedicationsAdded;

  /// No description provided for @noFilteredMedications.
  ///
  /// In en, this message translates to:
  /// **'No medications match this filter'**
  String get noFilteredMedications;

  /// No description provided for @resetFilter.
  ///
  /// In en, this message translates to:
  /// **'Reset Filter'**
  String get resetFilter;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @addNewMedication.
  ///
  /// In en, this message translates to:
  /// **'Add New Medication'**
  String get addNewMedication;

  /// No description provided for @takeDose.
  ///
  /// In en, this message translates to:
  /// **'Take Dose'**
  String get takeDose;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get remindMe;

  /// No description provided for @medicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Medication Details'**
  String get medicationDetails;

  /// No description provided for @todayDoses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Doses'**
  String get todayDoses;

  /// No description provided for @noScheduledDosesToday.
  ///
  /// In en, this message translates to:
  /// **'No doses scheduled for today'**
  String get noScheduledDosesToday;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @searchMedicationHint.
  ///
  /// In en, this message translates to:
  /// **'Search for medication name...'**
  String get searchMedicationHint;

  /// No description provided for @medicationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter medication name'**
  String get medicationNameRequired;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @dosageHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 500mg - 2 tablets'**
  String get dosageHint;

  /// No description provided for @dosageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter dosage'**
  String get dosageRequired;

  /// No description provided for @doseTimes.
  ///
  /// In en, this message translates to:
  /// **'Dose Times'**
  String get doseTimes;

  /// No description provided for @addAnotherTime.
  ///
  /// In en, this message translates to:
  /// **'Add another time'**
  String get addAnotherTime;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., shortly before meals'**
  String get notesHint;

  /// No description provided for @saveMedication.
  ///
  /// In en, this message translates to:
  /// **'Save Medication'**
  String get saveMedication;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String saveError(Object error);

  /// No description provided for @drugSafetyInfo.
  ///
  /// In en, this message translates to:
  /// **'Drug Safety Information'**
  String get drugSafetyInfo;

  /// No description provided for @highRiskMedicationWarning.
  ///
  /// In en, this message translates to:
  /// **'Alert: High Risk Medication'**
  String get highRiskMedicationWarning;

  /// No description provided for @adjustmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Dose adjustment required'**
  String get adjustmentRequired;

  /// No description provided for @completelySafeMedication.
  ///
  /// In en, this message translates to:
  /// **'Completely safe medication'**
  String get completelySafeMedication;

  /// No description provided for @nephrotoxicWarning.
  ///
  /// In en, this message translates to:
  /// **'Important Alert: {medName} may negatively affect kidney function. Please review with your physician.'**
  String nephrotoxicWarning(String medName);

  /// No description provided for @doseAdjustmentCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical Alert: {medName} requires a critical dose adjustment based on your severe kidney function decline. Consult physician immediately.'**
  String doseAdjustmentCritical(String medName);

  /// No description provided for @doseAdjustmentWarning.
  ///
  /// In en, this message translates to:
  /// **'Alert: {medName} may need dose adjustment based on your kidney function (eGFR). Consult pharmacist or physician.'**
  String doseAdjustmentWarning(String medName);

  /// No description provided for @potassiumInteractionWarning.
  ///
  /// In en, this message translates to:
  /// **'Important Alert: You are taking potassium-raising medications ({medNames}), and you have exceeded your daily potassium limit! Consult physician immediately.'**
  String potassiumInteractionWarning(String medNames);

  /// No description provided for @phosphorusInteractionWarning.
  ///
  /// In en, this message translates to:
  /// **'Alert: Taking {medName} with a high phosphorus diet may affect levels. Watch your phosphorus intake.'**
  String phosphorusInteractionWarning(String medName);

  /// No description provided for @sodiumInteractionWarning.
  ///
  /// In en, this message translates to:
  /// **'Alert: {medName} may affect sodium retention. You have exceeded the daily limit. Consult physician.'**
  String sodiumInteractionWarning(String medName);

  /// No description provided for @medicalBannerTitleCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical Medical Warning'**
  String get medicalBannerTitleCritical;

  /// No description provided for @medicalBannerTitleWarning.
  ///
  /// In en, this message translates to:
  /// **'Medical Alert'**
  String get medicalBannerTitleWarning;

  /// No description provided for @medicalBannerTitleInfo.
  ///
  /// In en, this message translates to:
  /// **'Health Information'**
  String get medicalBannerTitleInfo;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @medicalWarning.
  ///
  /// In en, this message translates to:
  /// **'Medical Warning'**
  String get medicalWarning;

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule: {times}'**
  String scheduleLabel(String times);

  /// No description provided for @frequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequencyDaily;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @pointCameraAtBarcode.
  ///
  /// In en, this message translates to:
  /// **'Point camera at product barcode'**
  String get pointCameraAtBarcode;

  /// No description provided for @manualBarcodeEntry.
  ///
  /// In en, this message translates to:
  /// **'Enter Barcode Manually'**
  String get manualBarcodeEntry;

  /// No description provided for @analyzingProduct.
  ///
  /// In en, this message translates to:
  /// **'Analyzing product...'**
  String get analyzingProduct;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found ({barcode})'**
  String productNotFound(String barcode);

  /// No description provided for @errorSearching.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during search'**
  String get errorSearching;

  /// No description provided for @enterBarcodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Barcode Number'**
  String get enterBarcodeNumber;

  /// No description provided for @barcodeExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 089686120134'**
  String get barcodeExample;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search Foods'**
  String get searchFoods;

  /// No description provided for @searchProductHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a product (e.g., Rice, Yogurt...)'**
  String get searchProductHint;

  /// No description provided for @searchAnyFoodOrBrand.
  ///
  /// In en, this message translates to:
  /// **'Search for any food or brand'**
  String get searchAnyFoodOrBrand;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results found'**
  String get noMatchingResults;

  /// No description provided for @nutritionalFactsHint.
  ///
  /// In en, this message translates to:
  /// **'We will provide you with kidney-friendly nutritional facts'**
  String get nutritionalFactsHint;

  /// No description provided for @ensureCorrectSpelling.
  ///
  /// In en, this message translates to:
  /// **'Make sure the name is spelled correctly'**
  String get ensureCorrectSpelling;

  /// No description provided for @dataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Data not available'**
  String get dataNotAvailable;

  /// No description provided for @productAnalysisResults.
  ///
  /// In en, this message translates to:
  /// **'Product Analysis Results {product}'**
  String productAnalysisResults(String product);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @nutritionalAnalysisPerGrams.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Analysis (per {grams} g)'**
  String nutritionalAnalysisPerGrams(String grams);

  /// No description provided for @nutrientSugars.
  ///
  /// In en, this message translates to:
  /// **'Sugars'**
  String get nutrientSugars;

  /// No description provided for @nutrientCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutrientCalories;

  /// No description provided for @unitCalorie.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitCalorie;

  /// No description provided for @verifiedChoice.
  ///
  /// In en, this message translates to:
  /// **'Verified Choice'**
  String get verifiedChoice;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @smartEstimation.
  ///
  /// In en, this message translates to:
  /// **'Smart Estimation'**
  String get smartEstimation;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @howMuchWillYouConsume.
  ///
  /// In en, this message translates to:
  /// **'How much will you consume?'**
  String get howMuchWillYouConsume;

  /// No description provided for @valuesMayDifferWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ These values may differ from the actual label; Verify manually before relying on this data.'**
  String get valuesMayDifferWarning;

  /// No description provided for @dismissWarning.
  ///
  /// In en, this message translates to:
  /// **'Dismiss Warning'**
  String get dismissWarning;

  /// No description provided for @avoidThisProduct.
  ///
  /// In en, this message translates to:
  /// **'Avoid this product'**
  String get avoidThisProduct;

  /// No description provided for @consumeWithCaution.
  ///
  /// In en, this message translates to:
  /// **'Consume with caution'**
  String get consumeWithCaution;

  /// No description provided for @relativelySafeChoice.
  ///
  /// In en, this message translates to:
  /// **'Relatively safe choice'**
  String get relativelySafeChoice;

  /// No description provided for @foodDrugInteraction.
  ///
  /// In en, this message translates to:
  /// **'Food-Drug Interaction'**
  String get foodDrugInteraction;

  /// No description provided for @editNutrient.
  ///
  /// In en, this message translates to:
  /// **'Edit {nutrient}'**
  String editNutrient(String nutrient);

  /// No description provided for @valuePer100g.
  ///
  /// In en, this message translates to:
  /// **'Value per 100g'**
  String get valuePer100g;

  /// No description provided for @saveToDailyLog.
  ///
  /// In en, this message translates to:
  /// **'Save to My Daily Log'**
  String get saveToDailyLog;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get pleaseLoginFirst;

  /// No description provided for @missingData.
  ///
  /// In en, this message translates to:
  /// **'Missing Data ⚠️'**
  String get missingData;

  /// No description provided for @labCreatinine.
  ///
  /// In en, this message translates to:
  /// **'Creatinine'**
  String get labCreatinine;

  /// No description provided for @labPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get labPotassium;

  /// No description provided for @labUrea.
  ///
  /// In en, this message translates to:
  /// **'Urea'**
  String get labUrea;

  /// No description provided for @labSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get labSodium;

  /// No description provided for @labHemoglobin.
  ///
  /// In en, this message translates to:
  /// **'Hemoglobin'**
  String get labHemoglobin;

  /// No description provided for @labPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus'**
  String get labPhosphorus;

  /// No description provided for @labHbA1c.
  ///
  /// In en, this message translates to:
  /// **'HbA1c'**
  String get labHbA1c;

  /// No description provided for @labTotalCholesterol.
  ///
  /// In en, this message translates to:
  /// **'Total Cholesterol'**
  String get labTotalCholesterol;

  /// No description provided for @labLDL.
  ///
  /// In en, this message translates to:
  /// **'LDL Cholesterol'**
  String get labLDL;

  /// No description provided for @labTriglycerides.
  ///
  /// In en, this message translates to:
  /// **'Triglycerides'**
  String get labTriglycerides;

  /// No description provided for @labCalcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get labCalcium;

  /// No description provided for @labVitaminD.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D'**
  String get labVitaminD;

  /// No description provided for @labBloodPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Blood Phosphorus'**
  String get labBloodPhosphorus;

  /// No description provided for @labUrineACR.
  ///
  /// In en, this message translates to:
  /// **'Urine ACR'**
  String get labUrineACR;

  /// No description provided for @noteImportantForDiabeticCKD.
  ///
  /// In en, this message translates to:
  /// **'Important for diabetic CKD patients'**
  String get noteImportantForDiabeticCKD;

  /// No description provided for @enterLabResults.
  ///
  /// In en, this message translates to:
  /// **'Enter Lab Results'**
  String get enterLabResults;

  /// No description provided for @labDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab Date'**
  String get labDateTitle;

  /// No description provided for @labDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Lab Date'**
  String get labDateLabel;

  /// No description provided for @saveResultsManually.
  ///
  /// In en, this message translates to:
  /// **'Save Results Manually'**
  String get saveResultsManually;

  /// No description provided for @scanLabPaperOCR.
  ///
  /// In en, this message translates to:
  /// **'Scan Lab Paper (OCR)'**
  String get scanLabPaperOCR;

  /// No description provided for @measurementUnit.
  ///
  /// In en, this message translates to:
  /// **'Measurement Unit'**
  String get measurementUnit;

  /// No description provided for @unitStoredAsIsMg.
  ///
  /// In en, this message translates to:
  /// **'Values entered in mg/dL — saved as is'**
  String get unitStoredAsIsMg;

  /// No description provided for @unitConvertedAutomaticallyMmol.
  ///
  /// In en, this message translates to:
  /// **'Values entered in mmol/L — converted automatically when saving'**
  String get unitConvertedAutomaticallyMmol;

  /// No description provided for @dataSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully!'**
  String get dataSavedSuccessfully;

  /// No description provided for @updatingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Updating dashboard...'**
  String get updatingDashboard;

  /// No description provided for @normalRange.
  ///
  /// In en, this message translates to:
  /// **'Normal Range: {min} – {max} {unit}'**
  String normalRange(String min, String max, String unit);

  /// No description provided for @errorSavingExt.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSavingExt(String error);

  /// No description provided for @errorScanningExt.
  ///
  /// In en, this message translates to:
  /// **'Scan failed: {error}'**
  String errorScanningExt(String error);

  /// No description provided for @labWarningCriticalHigh.
  ///
  /// In en, this message translates to:
  /// **'🔴 {name} is noticeably high — advising to contact your doctor soon'**
  String labWarningCriticalHigh(String name);

  /// No description provided for @labWarningHigh.
  ///
  /// In en, this message translates to:
  /// **'⚠ {name} is slightly higher than usual — monitor it and inform your doctor next visit'**
  String labWarningHigh(String name);

  /// No description provided for @labWarningCriticalLow.
  ///
  /// In en, this message translates to:
  /// **'🔴 {name} is noticeably low — advising to contact your doctor soon'**
  String labWarningCriticalLow(String name);

  /// No description provided for @labWarningLow.
  ///
  /// In en, this message translates to:
  /// **'⚠ {name} is slightly lower than usual — monitor it and inform your doctor next visit'**
  String labWarningLow(String name);

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
