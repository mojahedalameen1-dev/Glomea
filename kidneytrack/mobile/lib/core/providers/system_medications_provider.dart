import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/system_medication.dart';
import '../data/medication_database.dart';

final systemMedicationsProvider =
    FutureProvider<List<SystemMedication>>((ref) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('system_medications').select();

    if (response.isNotEmpty) {
      return response.map((json) => SystemMedication.fromJson(json)).toList();
    } else {
      // If table is empty but reachable
      return MedicationDatabase.fallbackMedications;
    }
  } catch (e) {
    // Fallback if offline or table doesn't exist
    return MedicationDatabase.fallbackMedications;
  }
});
