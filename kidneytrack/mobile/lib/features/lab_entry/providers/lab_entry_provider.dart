import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final labEntryProvider =
    StateNotifierProvider<LabEntryNotifier, AsyncValue<void>>((ref) {
  return LabEntryNotifier(ref);
});

class LabEntryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  LabEntryNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> saveLabResults({
    required DateTime recordedAt,
    required Map<String, double> indicators,
    required Map<String, String> units,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();

    try {
      final patient = _ref.read(authNotifierProvider).value;
      if (patient == null) throw Exception('User not authenticated');

      final List<Map<String, dynamic>> dataToInsert = [];

      indicators.forEach((code, value) {
        if (value > 0) {
          dataToInsert.add({
            'patientId': patient.id,
            'indicatorCode': code,
            'value': value,
            'unit': units[code] ?? '',
            'recordedAt': recordedAt.toIso8601String(),
            if (imageUrl != null) 'imageUrl': imageUrl,
          });
        }
      });

      // Image only logic removed

      if (dataToInsert.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      await _supabase.from('LabResult').insert(dataToInsert).select();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
