import 'package:flutter/material.dart';

class AppColors {
  // --- Class A: Normal / Base Surfaces ---
  static const bgPage = Color(0xFFF4F6FF); // Medical Light Blue (Unified)
  static const bgSurface = Color(0xFFFFFFFF);
  static const bgPageDark = Color(0xFF020617); // Slate 950
  static const bgSurfaceDark = Color(0xFF0F172A); // Slate 900

  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);

  static const borderBase = Color(0xFFE2E8F0); // Slate 200
  static const borderBaseDark = Color(0xFF1E293B);

  // --- Class B: Informational (Tips, Normal Labs) ---
  static const bgInfo = Color(0xFFF0F9FF); // Blue 50
  static const textInfo = Color(0xFF0369A1); // Blue 700
  static const borderInfo = Color(0xFFBAE6FD); // Blue 200
  static const bgInfoDark = Color(0xFF0C4A6E); // Blue 900
  static const textInfoDark = Color(0xFF7DD3FC); // Blue 300

  // --- Class C: Warning (Clinical Caution) ---
  static const bgWarning = Color(0xFFFFFBEB); // Amber 50
  static const textWarning = Color(0xFF92400E); // Amber 800
  static const borderWarning = Color(0xFFFCD34D); // Amber 300
  static const bgWarningDark = Color(0xFF451A03); // Amber 900
  static const textWarningDark = Color(0xFFFDE68A); // Amber 200
  static const borderWarningDark = Color(0xFF78350F); // Amber 900 border

  // --- Core Brand Identity ---
  static const primary = Color(0xFF2563EB); // Vibrant Medical Blue
  static const primaryLight = Color(0xFFDBEAFE); // Blue 100
  static const accent = Color(0xFF0EA5E9); // Sky Blue Accent

  // --- Success / Safe State ---
  static const textSuccess = Color(0xFF10B981); // Mature Medical Green
  static const bgSuccess = Color(0xFFECFDF5);
  static const borderSuccess = Color(0xFFA7F3D0);
  static const bgSuccessDark = Color(0xFF064E3B);
  static const textSuccessDark = Color(0xFF6EE7B7);

  // --- Danger / Critical Medical ---
  static const textCritical = Color(0xFFEF4444); // Accessible Red
  static const bgCritical = Color(0xFFFEF2F2);
  static const borderCritical = Color(0xFFFCA5A5);
  static const bgCriticalDark = Color(0xFF450A0A);
  static const textCriticalDark = Color(0xFFFEE2E2);
  static const borderCriticalDark = Color(0xFF7F1D1D);

  // --- Aliases for Layout Stability / Migration ---
  static const bgBack = bgPage;
  static const bgBackDark = bgPageDark;
  static const bgBase = bgSurface;
  static const bgBaseDark = bgSurfaceDark;
  static const safeGreen = textSuccess;
  static const warningAmber = textWarning;
  static const criticalRed = textCritical;

  // --- Premium Wellness Theme (Unified to Base) ---
  static const premiumBg = bgPage;
  static const premiumBgDark = bgPageDark;
  static const premiumCard = bgSurface;
  static const premiumCardDark = bgSurfaceDark;
  static const premiumGlass = Color(0xCCFFFFFF);
  static const premiumGlassDark = Color(0xCC0F172A);

  static const premiumTextMain = textPrimary;
  static const premiumTextSub = textSecondary;

  // High-fidelity gradients
  static const premiumBlueGrad = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
