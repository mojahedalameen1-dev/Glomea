import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/providers/localization_provider.dart';

import 'core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'core/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Timezones
  tz.initializeTimeZones();

  bool isSupabaseInitialized = false;
  try {
    await dotenv.load(fileName: ".env");
    await NotificationService.initialize();

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? SupabaseConfig.url,
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
    isSupabaseInitialized = true;
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(
    ProviderScope(
      child: GlomeaApp(isInitialized: isSupabaseInitialized),
    ),
  );
}

class GlomeaApp extends ConsumerWidget {
  final bool isInitialized;
  const GlomeaApp({super.key, required this.isInitialized});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localizationProvider);
    AppTextStyles.updateLocale(locale);

    if (!isInitialized) {
      return MaterialApp(
        title: 'KidneyTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: AppColors.criticalRed),
                  const SizedBox(height: 24),
                  Text(
                    locale.languageCode == 'ar'
                        ? 'خطأ في الاتصال بالخدمة'
                        : 'Connection Error',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    locale.languageCode == 'ar'
                        ? 'تعذر تهيئة التطبيق. يرجى التأكد من اتصال الإنترنت وإعادة المحاولة.'
                        : 'Failed to initialize the application. Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyM,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'KidneyTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
