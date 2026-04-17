import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

final localizationProvider = StateNotifierProvider<LocalizationNotifier, Locale>((ref) {
  return LocalizationNotifier();
});

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localizationProvider);
  // This is a bit tricky without context, but AppLocalizations.delegate.load returns a Future.
  // We can use the lookup function if we had it, but standard way in Riverpod 
  // without context is often difficult unless we use a lookup table.
  // However, flutter_gen provides a lookup function.
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
      state = Locale(langCode);
    } else {
      // Default to English on first launch as per requirement
      state = const Locale('en');
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
