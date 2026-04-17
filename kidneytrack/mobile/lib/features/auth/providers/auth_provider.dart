import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/models/patient.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

class AuthNotifier extends AsyncNotifier<Patient?> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isFetching = false;

  static const _onboardingKey = 'onboarding_complete';
  static const _patientCacheKey = 'patient_data_cache';

  Future<bool> _getCachedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> _cacheOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  Future<Patient?> _getCachedPatient() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_patientCacheKey);
    if (jsonStr != null) {
      try {
        return Patient.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        debugPrint('Error decoding cached patient: $e');
      }
    }
    return null;
  }

  Future<void> _saveCachedPatient(Patient patient) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_patientCacheKey, jsonEncode(patient.toJson()));
  }

  @override
  FutureOr<Patient?> build() async {
    // الاستماع لتغيرات حالة المصادقة لإعادة جلب البيانات تلقائياً
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.session != null) {
          _fetchInBackground();
        } else {
          state = const AsyncValue.data(null);
        }
      });
    });

    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    final cachedPatient = await _getCachedPatient();
    if (cachedPatient != null && cachedPatient.id == session.user.id) {
      _fetchInBackground();
      return cachedPatient;
    }

    return await _fetchPatient();
  }

  void _fetchInBackground() {
    if (!_isFetching) {
      _isFetching = true;
      _fetchPatient().then((patient) {
        _isFetching = false;
        if (patient != null) {
          _cacheOnboarding(patient.onboardingComplete);
          _saveCachedPatient(patient);
          state = AsyncValue.data(patient);
        }
      });
    }
  }

  Future<Patient?> _fetchPatient() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    try {
      final data = await _supabase
          .from('Patient')
          .select()
          .eq('id', session.user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (data == null) {
        return Patient.quick(
          id: session.user.id,
          onboardingComplete: await _getCachedOnboarding(),
        );
      }
      final patient = Patient.fromJson(data);
      _saveCachedPatient(patient);
      return patient;
    } catch (e) {
      debugPrint('Error fetching patient: $e');
      return Patient.quick(
        id: session.user.id,
        onboardingComplete: await _getCachedOnboarding(),
      );
    }
  }

  Future<String?> register(
      {required String email, required String password}) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);

      if (res.user != null) {
        if (res.session != null) {
          return null; // نجاح مباشر
        } else {
          return 'CONFIRM_EMAIL'; // يحتاج تأكيد البريد
        }
      }
      return 'فشل إنشاء الحساب';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
  }

  Future<void> checkAuth() async {
    state = const AsyncValue.loading();
    final patient = await _fetchPatient();
    state = AsyncValue.data(patient);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();

    // مسح الـ Cache المحلي عند الخروج لمنع تسريب البيانات
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patientCacheKey);
    await prefs.remove(_onboardingKey);

    state = const AsyncValue.data(null);
  }

  Future<String?> updatePatient(Map<String, dynamic> data) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'المصادقة مطلوبة';

      // 1) بناء الـ payload مع `id` دائماً (مطلوب لـ UPSERT)
      final payload = Map<String, dynamic>.from(data);

      // Mapping aliases to DB columns
      if (payload.containsKey('fullName')) {
        payload['full_name'] = payload.remove('fullName');
      }
      if (payload.containsKey('phone')) {
        payload['phone_number'] = payload.remove('phone');
      }
      if (payload.containsKey('phoneNumber')) {
        payload['phone_number'] = payload.remove('phoneNumber');
      }
      if (payload.containsKey('notificationsEnabled')) {
        payload['notifications_enabled'] =
            payload.remove('notificationsEnabled');
      }

      // 2) تأكيد أن id موجود دائماً في الـ payload
      payload['id'] = user.id;

      // 3) ضمان عدم إرسال null لحقول NOT NULL
      if (payload.containsKey('firstName')) {
        payload['firstName'] = payload['firstName'] ?? '';
      }
      if (payload.containsKey('lastName')) {
        payload['lastName'] = payload['lastName'] ?? '';
      }

      // 4) إزالة أي null متبقي (باستثناء firstName و lastName و id)
      payload.removeWhere((key, value) =>
          value == null &&
          key != 'firstName' &&
          key != 'lastName' &&
          key != 'id');

      // 5) استخدام UPSERT بدلاً من UPDATE لمعالجة كلا الحالتين:
      //    - مستخدم جديد ليس له سجل بعد → INSERT
      //    - مستخدم موجود → UPDATE
      await _supabase.from('Patient').upsert(payload, onConflict: 'id');

      // 6) مزامنة حالة الـ Onboarding مع بيانات المستخدم (Metadata) - محاولة أفضل (Best-effort)
      if (payload['onboardingComplete'] == true) {
        await _cacheOnboarding(true);

        // تحديث الـ metadata في Auth بشكل غير معطل (Non-blocking)
        unawaited(() async {
          try {
            await _supabase.auth.updateUser(
              UserAttributes(data: {'onboarding_complete': true}),
            );
          } catch (e) {
            debugPrint('Silent Metadata Sync Failure: $e');
          }
        }());
      }

      final updatedPatient = await _fetchPatient();
      state = AsyncValue.data(updatedPatient);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } on PostgrestException catch (e) {
      debugPrint('updatePatient DB error: ${e.code} - ${e.message}');
      // 23505: unique_violation
      if (e.code == '23505') {
        if (e.message.contains('Patient_phone_key') ||
            e.message.contains('phone')) {
          return 'رقم الهاتف هذا مسجل مسبقاً لمستخدم آخر.';
        } else if (e.message.contains('Patient_email_key') ||
            e.message.contains('email')) {
          return 'البريد الإلكتروني هذا مسجل مسبقاً لمستخدم آخر.';
        }
        return 'بعض البيانات المدخلة مسجلة مسبقاً لمستخدم آخر.';
      }
      return 'فشل حفظ البيانات في قاعدة البيانات. يرجى المحاولة لاحقاً.';
    } catch (e) {
      debugPrint('updatePatient generic error: $e');
      return 'فشل تحديث البيانات. يرجى مراجعة اتصال الإنترنت.';
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, Patient?>(() {
  return AuthNotifier();
});

// Alias removed (use authNotifierProvider everywhere)
