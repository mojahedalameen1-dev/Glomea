import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static Locale _currentLocale = const Locale('en');

  static void updateLocale(Locale locale) {
    _currentLocale = locale;
  }

  static bool get isArabic => _currentLocale.languageCode == 'ar';

  static String _fontFamily(bool isLatin) {
    if (isArabic && !isLatin) return 'IBM Plex Sans Arabic';
    return 'Inter';
  }

  static TextStyle get arabicStyle => TextStyle(
        fontFamily: _fontFamily(false),
        color: AppColors.textPrimary,
      );

  static TextStyle get interStyle => const TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => arabicStyle.copyWith(
        fontSize: 32,
        fontWeight: isArabic
            ? FontWeight.w700
            : FontWeight.w800, // Bold for Arabic, ExtraBold (800) for Inter
        height: 1.1,
      );

  static TextStyle get h2 => arabicStyle.copyWith(
        fontSize: 24,
        fontWeight: isArabic
            ? FontWeight.w600
            : FontWeight.w700, // SemiBold for Arabic, Bold for Inter
        height: 1.2,
      );

  static TextStyle get h3 => arabicStyle.copyWith(
        fontSize: 20,
        fontWeight:
            isArabic ? FontWeight.w600 : FontWeight.w600, // SemiBold for both
        height: 1.3,
      );

  static TextStyle get bodyL => arabicStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        height: 1.4,
      );

  static TextStyle get bodyM => arabicStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        height: 1.5,
      );

  static TextStyle get bodyS => arabicStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => arabicStyle.copyWith(
        fontSize: 14,
        fontWeight: isArabic
            ? FontWeight.w500
            : FontWeight.w700, // Medium for Arabic, Bold for Inter
        height: 1.1,
      );

  static TextStyle get displayLarge => interStyle.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  // Optimized for numerals - Always Inter as per common practice for medical numbers
  static TextStyle get metricValue => interStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get unit => interStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
