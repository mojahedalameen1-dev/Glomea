import '../constants/health_constants.dart';

class Patient {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;
  final double? dryWeightKg;
  final DateTime? dialysisStartDate;
  final String? kidneyStage;
  final String? dialysisStatus;
  final double? egfrLevel;
  final int fluidLimitMl;
  final int potassiumLimitMg;
  final int phosphorusLimitMg;
  final int sodiumLimitMg;
  final int proteinLimitG;
  final int targetSystolic;
  final int targetDiastolic;
  final bool onboardingComplete;
  final bool notificationsEnabled;
  final String? avatarUrl;

  int get ckdStage {
    if (kidneyStage == null) return 0;
    if (kidneyStage!.contains('1')) return 1;
    if (kidneyStage!.contains('2')) return 2;
    if (kidneyStage!.contains('3')) return 3;
    if (kidneyStage!.contains('4')) return 4;
    if (kidneyStage!.contains('5')) return 5;
    return 0;
  }

  Patient({
    required this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.dryWeightKg,
    this.dialysisStartDate,
    this.kidneyStage,
    this.dialysisStatus,
    this.egfrLevel,
    this.fluidLimitMl = HealthConstants.defaultFluidLimitMl,
    this.potassiumLimitMg = HealthConstants.defaultPotassiumLimitMg,
    this.phosphorusLimitMg = HealthConstants.defaultPhosphorusLimitMg,
    this.sodiumLimitMg = HealthConstants.defaultSodiumLimitMg,
    this.proteinLimitG = HealthConstants.defaultProteinLimitG,
    this.targetSystolic = HealthConstants.defaultTargetSystolic,
    this.targetDiastolic = HealthConstants.defaultTargetDiastolic,
    required this.onboardingComplete,
    this.notificationsEnabled = true,
    this.avatarUrl,
  });

  factory Patient.quick({
    required String id,
    required bool onboardingComplete,
  }) {
    return Patient(
      id: id,
      onboardingComplete: onboardingComplete,
    );
  }

  int get ageYears {
    if (birthDate == null) return 40; // Default or handle appropriately
    return DateTime.now().year - birthDate!.year;
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      heightCm: json['heightCm']?.toDouble(),
      weightKg: json['weightKg']?.toDouble(),
      dryWeightKg: json['dryWeightKg']?.toDouble(),
      dialysisStartDate: json['dialysisStartDate'] != null
          ? DateTime.parse(json['dialysisStartDate'])
          : null,
      kidneyStage: json['kidneyStage'],
      dialysisStatus: json['dialysisStatus'],
      egfrLevel: json['egfrLevel']?.toDouble(),
      fluidLimitMl: json['fluidLimitMl'] ?? HealthConstants.defaultFluidLimitMl,
      potassiumLimitMg:
          json['potassiumLimitMg'] ?? HealthConstants.defaultPotassiumLimitMg,
      phosphorusLimitMg:
          json['phosphorusLimitMg'] ?? HealthConstants.defaultPhosphorusLimitMg,
      sodiumLimitMg:
          json['sodiumLimitMg'] ?? HealthConstants.defaultSodiumLimitMg,
      proteinLimitG:
          json['proteinLimitG'] ?? HealthConstants.defaultProteinLimitG,
      targetSystolic:
          json['targetSystolic'] ?? HealthConstants.defaultTargetSystolic,
      targetDiastolic:
          json['targetDiastolic'] ?? HealthConstants.defaultTargetDiastolic,
      onboardingComplete: json['onboardingComplete'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'dryWeightKg': dryWeightKg,
      'dialysisStartDate': dialysisStartDate?.toIso8601String(),
      'kidneyStage': kidneyStage,
      'dialysisStatus': dialysisStatus,
      'egfrLevel': egfrLevel,
      'fluidLimitMl': fluidLimitMl,
      'potassiumLimitMg': potassiumLimitMg,
      'phosphorusLimitMg': phosphorusLimitMg,
      'sodiumLimitMg': sodiumLimitMg,
      'proteinLimitG': proteinLimitG,
      'targetSystolic': targetSystolic,
      'targetDiastolic': targetDiastolic,
      'onboardingComplete': onboardingComplete,
      'notifications_enabled': notificationsEnabled,
      'avatarUrl': avatarUrl,
    };
  }

  /// Payload آمن للإرسال في UPDATE على جدول Patient.
  /// - لا يحتوي على id (يمنع خطأ RLS with_check).
  /// - firstName/lastName لا يكونان null أبدًا (NOT NULL constraint).
  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{};

    // حقول مطلوبة (NOT NULL) - نضمن عدم إرسال null
    map['firstName'] = firstName ?? '';
    map['lastName'] = lastName ?? '';

    // حقول اختيارية (تُضاف فقط إذا لم تكن null لتجنب مسح البيانات الموجودة)
    if (fullName != null) map['full_name'] = fullName;
    if (email != null) map['email'] = email;
    if (phoneNumber != null) map['phone_number'] = phoneNumber;
    if (gender != null) map['gender'] = gender;
    if (birthDate != null) map['birthDate'] = birthDate!.toIso8601String();
    if (heightCm != null) map['heightCm'] = heightCm;
    if (weightKg != null) map['weightKg'] = weightKg;
    if (dryWeightKg != null) map['dryWeightKg'] = dryWeightKg;
    if (dialysisStartDate != null) {
      map['dialysisStartDate'] = dialysisStartDate!.toIso8601String();
    }
    if (kidneyStage != null) map['kidneyStage'] = kidneyStage;
    if (dialysisStatus != null) map['dialysisStatus'] = dialysisStatus;

    // حقول الحدود والأهداف
    map['fluidLimitMl'] = fluidLimitMl;
    map['potassiumLimitMg'] = potassiumLimitMg;
    map['phosphorusLimitMg'] = phosphorusLimitMg;
    map['sodiumLimitMg'] = sodiumLimitMg;
    map['proteinLimitG'] = proteinLimitG;
    map['targetSystolic'] = targetSystolic;
    map['targetDiastolic'] = targetDiastolic;

    map['onboardingComplete'] = onboardingComplete;
    map['notifications_enabled'] = notificationsEnabled;

    if (avatarUrl != null) map['avatarUrl'] = avatarUrl;

    return map;
  }
}
