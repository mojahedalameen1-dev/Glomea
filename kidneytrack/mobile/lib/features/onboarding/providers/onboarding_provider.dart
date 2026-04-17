import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingData {
  final String? fullName;
  final int? age;
  final String? kidneyStage;
  final String? dialysisStatus;
  final String? avatarUrl;

  final int? fluidLimitMl;
  final int? potassiumLimitMg;
  final int? sodiumLimitMg;
  final int? proteinLimitG;
  final int? phosphorusLimitMg;

  final String? physicianName;
  final bool notificationsEnabled;

  OnboardingData({
    this.fullName,
    this.age,
    this.kidneyStage,
    this.dialysisStatus,
    this.avatarUrl,
    this.fluidLimitMl,
    this.potassiumLimitMg,
    this.sodiumLimitMg,
    this.proteinLimitG,
    this.phosphorusLimitMg,
    this.physicianName,
    this.notificationsEnabled = true,
  });

  OnboardingData copyWith({
    String? fullName,
    int? age,
    String? kidneyStage,
    String? dialysisStatus,
    String? avatarUrl,
    int? fluidLimitMl,
    int? potassiumLimitMg,
    int? sodiumLimitMg,
    int? proteinLimitG,
    int? phosphorusLimitMg,
    String? physicianName,
    bool? notificationsEnabled,
  }) {
    return OnboardingData(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      kidneyStage: kidneyStage ?? this.kidneyStage,
      dialysisStatus: dialysisStatus ?? this.dialysisStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fluidLimitMl: fluidLimitMl ?? this.fluidLimitMl,
      potassiumLimitMg: potassiumLimitMg ?? this.potassiumLimitMg,
      sodiumLimitMg: sodiumLimitMg ?? this.sodiumLimitMg,
      proteinLimitG: proteinLimitG ?? this.proteinLimitG,
      phosphorusLimitMg: phosphorusLimitMg ?? this.phosphorusLimitMg,
      physicianName: physicianName ?? this.physicianName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class OnboardingState {
  final bool isLoading;
  final OnboardingData data;
  final String? error;

  OnboardingState({
    this.isLoading = false,
    required this.data,
    this.error,
  });

  OnboardingState copyWith({
    bool? isLoading,
    OnboardingData? data,
    String? error,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref)
      : super(OnboardingState(data: OnboardingData()));

  void updateData(OnboardingData newData) {
    state = state.copyWith(data: newData);
  }

  Future<bool> completeOnboarding() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Save Physician Name to SharedPreferences (Local Only)
      if (state.data.physicianName != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('physician_name', state.data.physicianName!);
      }

      // 2. Prepare Supabase Payload
      final data = state.data;
      final Map<String, dynamic> payload = {
        'onboardingComplete': true,
        'updatedAt': DateTime.now().toIso8601String(),
        'notifications_enabled': data.notificationsEnabled,
      };

      if (data.fullName != null) payload['full_name'] = data.fullName;
      if (data.physicianName != null)
        payload['physician_name'] = data.physicianName;
      if (data.age != null) {
        // Calculate a rough birthdate since backend expects birthDate
        final birthYear = DateTime.now().year - data.age!;
        payload['birthDate'] = DateTime(birthYear, 1, 1).toIso8601String();
      }
      if (data.kidneyStage != null) payload['kidneyStage'] = data.kidneyStage;
      if (data.dialysisStatus != null)
        payload['dialysisStatus'] = data.dialysisStatus;
      if (data.avatarUrl != null) payload['avatarUrl'] = data.avatarUrl;

      if (data.fluidLimitMl != null)
        payload['fluidLimitMl'] = data.fluidLimitMl;
      if (data.potassiumLimitMg != null)
        payload['potassiumLimitMg'] = data.potassiumLimitMg;
      if (data.sodiumLimitMg != null)
        payload['sodiumLimitMg'] = data.sodiumLimitMg;
      if (data.proteinLimitG != null)
        payload['proteinLimitG'] = data.proteinLimitG;
      if (data.phosphorusLimitMg != null)
        payload['phosphorusLimitMg'] = data.phosphorusLimitMg;

      final error =
          await _ref.read(authNotifierProvider.notifier).updatePatient(payload);

      if (error != null) {
        state = state.copyWith(isLoading: false, error: error);
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
