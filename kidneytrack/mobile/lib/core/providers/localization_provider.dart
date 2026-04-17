import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, Locale>((ref) {
  return LocalizationNotifier();
});

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localizationProvider);
  return lookupAppLocalizations(locale);
});

class LocalizationNotifier extends StateNotifier<Locale> {
  static const String _languageKey = 'selected_language';

  LocalizationNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey);

    if (langCode != null) {
      // المستخدم سبق أن اختار لغة — نحترم اختياره
      state = Locale(langCode);
    } else {
      // أول تشغيل — نكتشف لغة الجهاز
      final deviceLocales = PlatformDispatcher.instance.locales;
      final isDeviceArabic = deviceLocales.any(
        (locale) => locale.languageCode == 'ar',
      );
      state = isDeviceArabic ? const Locale('ar') : const Locale('en');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;

    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  void toggleLanguage() {
    if (state.languageCode == 'en') {
      setLocale(const Locale('ar'));
    } else {
      setLocale(const Locale('en'));
    }
  }

  bool get isArabic => state.languageCode == 'ar';
}
