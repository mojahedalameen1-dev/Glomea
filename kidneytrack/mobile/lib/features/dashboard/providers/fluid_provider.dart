import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/fluid_intake.dart';
import '../../auth/providers/auth_provider.dart';

final fluidProvider = StateNotifierProvider<FluidNotifier, AsyncValue<List<FluidIntake>>>((ref) {
  return FluidNotifier(ref);
});

final todayFluidIntakeProvider = Provider<int>((ref) {
  final fluidState = ref.watch(fluidProvider);
  return fluidState.when(
    data: (list) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return list
          .where((f) => f.consumedAt.isAfter(today))
          .fold(0, (sum, f) => sum + f.amountMl);
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

class FluidNotifier extends StateNotifier<AsyncValue<List<FluidIntake>>> {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  FluidNotifier(this._ref) : super(const AsyncValue.loading()) {
    // الاستماع لبيانات المريض لإعادة جلب السجل فور تسجيل الدخول
    _ref.listen(authNotifierProvider, (previous, next) {
      if (next.value != null) {
        fetchHistory();
      }
    });
    
    // محاولة جلب البيانات إذا كانت الجلسة موجودة مسبقاً
    if (_ref.read(authNotifierProvider).value != null) {
      fetchHistory();
    }
  }

  Future<void> fetchHistory() async {
    try {
      final patient = _ref.read(authNotifierProvider).value;
      if (patient == null) return;

      final data = await _supabase
          .from('FluidIntake')
          .select()
          .eq('patientId', patient.id)
          .order('loggedAt', ascending: false);
      
      final list = (data as List).map((json) => FluidIntake.fromJson(json)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addIntake(int amountMl) async {
    try {
      final patient = _ref.read(authNotifierProvider).value;
      if (patient == null) return;

      final intake = {
        'patientId': patient.id,
        'amountMl': amountMl,
        'loggedAt': DateTime.now().toIso8601String(),
      };

      await _supabase.from('FluidIntake').insert(intake);
      await fetchHistory();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeLastIntake() async {
    try {
      final patient = _ref.read(authNotifierProvider).value;
      if (patient == null) return;

      // Get the latest ID
      final data = await _supabase
          .from('FluidIntake')
          .select('id')
          .eq('patientId', patient.id)
          .order('loggedAt', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        await _supabase.from('FluidIntake').delete().eq('id', data['id']);
        await fetchHistory();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
