import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Load environment variables if needed or hardcode the Supabase URL and Key for the script run
  // But wait, the config is in lib/core/config/supabase_config.dart. We can just use it.
  // Actually, Dart CLI cannot use flutter packages directly easily without 'flutter test' or similar.
  // Let's use standard Dart with the Supabase URL and ANON Key found in supabase_config.dart

  const supabaseUrl = 'https://xrdaimedsdxbfjoyvhpx.supabase.co';
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhyZGFpbWVkc2R4YmZqb3l2aHB4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwODcwMDgsImV4cCI6MjA1NzY2MzAwOH0.Y_bN3BvP47G6lG5Z8QKVYk3ZlE23qG1s8vKQXZbM9zE';

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    // ignore: avoid_print
    print('Attempting to create test patient...');
    final response = await client.auth.signUp(
        email: 'test_patient@glomea.com',
        password: 'Password123!',
        data: {
          'firstName': 'مريض',
          'lastName': 'تجريبي',
        });

    if (response.user != null) {
      // ignore: avoid_print
      print('SUCCESS: Created patient with ID: ${response.user!.id}');
      // ignore: avoid_print
      print('Email: test_patient@glomea.com');
      // ignore: avoid_print
      print('Password: Password123!');
    } else {
      // ignore: avoid_print
      print('Failed to create patient.');
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error creating test patient: $e');
  }
}
