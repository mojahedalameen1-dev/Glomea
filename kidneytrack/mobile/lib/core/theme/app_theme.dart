import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'IBM Plex Sans Arabic',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.bgSurface,
        error: AppColors.textCritical,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgPage,
      dividerColor: AppColors.borderBase,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.h1,
        displaySmall: AppTextStyles.h2,
        bodyLarge: AppTextStyles.bodyL,
        bodyMedium: AppTextStyles.bodyM,
        bodySmall: AppTextStyles.bodyS,
        labelLarge: AppTextStyles.label,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.radiusM)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'IBM Plex Sans Arabic',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.bgSurfaceDark,
        error: AppColors.textCriticalDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.bgPageDark,
      dividerColor: AppColors.borderBaseDark,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.textPrimaryDark),
        displayMedium:
            AppTextStyles.h1.copyWith(color: AppColors.textPrimaryDark),
        displaySmall:
            AppTextStyles.h2.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge:
            AppTextStyles.bodyL.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium:
            AppTextStyles.bodyM.copyWith(color: AppColors.textPrimaryDark),
        bodySmall:
            AppTextStyles.bodyS.copyWith(color: AppColors.textSecondaryDark),
        labelLarge:
            AppTextStyles.label.copyWith(color: AppColors.textPrimaryDark),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgSurfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.radiusM)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.h2.copyWith(color: AppColors.textPrimaryDark),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
    );
  }
}
