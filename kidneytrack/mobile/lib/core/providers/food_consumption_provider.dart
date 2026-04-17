import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_consumption.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Notifier for managing food consumption logs.
class FoodConsumptionNotifier
    extends StateNotifier<AsyncValue<List<FoodConsumption>>> {
  final String? patientId;
  final _supabase = Supabase.instance.client;

  FoodConsumptionNotifier(this.patientId) : super(const AsyncValue.loading());

  Future<void> fetchTodayConsumption() async {
    if (patientId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final startOfDay =
          DateTime(now.year, now.month, now.day).toIso8601String();

      final response = await _supabase
          .from('FoodConsumption')
          .select()
          .eq('patientId', patientId!)
          .gte('consumedAt', startOfDay)
          .order('consumedAt', ascending: false);

      final list = (response as List)
          .map((json) => FoodConsumption.fromJson(json))
          .toList();
      state = AsyncValue.data(list);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addConsumption(FoodConsumption consumption) async {
    try {
      await _supabase.from('FoodConsumption').insert(consumption.toJson());

      // Update local state proactively if we already have data
      state.whenData((currentList) {
        state = AsyncValue.data([consumption, ...currentList]);
      });
    } catch (e) {
      // In case of error, we might want to refresh from server
      await fetchTodayConsumption();
      rethrow;
    }
  }
}

/// Provider for the food consumption notifier.
final foodConsumptionProvider = StateNotifierProvider<FoodConsumptionNotifier,
    AsyncValue<List<FoodConsumption>>>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final patientId = auth.valueOrNull?.id;
  final notifier = FoodConsumptionNotifier(patientId);

  if (patientId != null) {
    notifier.fetchTodayConsumption();
  }

  return notifier;
});
