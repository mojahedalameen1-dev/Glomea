import 'package:flutter/material.dart';

class AppColors {
  // --- Class A: Normal / Base Surfaces ---
  static const bgPage      = Color(0xFFF8FAFC); // Slate 50
  static const bgSurface   = Color(0xFFFFFFFF);
  static const bgPageDark  = Color(0xFF020617); // Slate 950
  static const bgSurfaceDark = Color(0xFF0F172A); // Slate 900
  
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  
  static const borderBase  = Color(0xFFE2E8F0); // Slate 200
  static const borderBaseDark = Color(0xFF1E293B);

  // --- Class B: Informational (Tips, Normal Labs) ---
  static const bgInfo      = Color(0xFFF0F9FF); // Blue 50
  static const textInfo      = Color(0xFF0369A1); // Blue 700
  static const borderInfo  = Color(0xFFBAE6FD); // Blue 200
  static const bgInfoDark  = Color(0xFF0C4A6E); // Blue 900
  static const textInfoDark  = Color(0xFF7DD3FC); // Blue 300

  // --- Success / Safe State ---
  static const bgSuccess   = Color(0xFFECFDF5); // Emerald 50
  static const textSuccess   = Color(0xFF065F46); // Emerald 800
  static const borderSuccess = Color(0xFFA7F3D0); // Emerald 200
  static const bgSuccessDark = Color(0xFF064E3B); // Emerald 900
  static const textSuccessDark = Color(0xFF6EE7B7); // Emerald 200

  // --- Class C: Warning (Clinical Caution) ---
  static const bgWarning   = Color(0xFFFFFBEB); // Amber 50
  static const textWarning   = Color(0xFF92400E); // Amber 800
  static const borderWarning = Color(0xFFFCD34D); // Amber 300
  static const bgWarningDark = Color(0xFF451A03); // Amber 900
  static const textWarningDark = Color(0xFFFDE68A); // Amber 200

  // --- Class D: Critical Medical (Urgent Instructions) ---
  static const bgCritical  = Color(0xFFFEF2F2); // Red 50
  static const textCritical  = Color(0xFF991B1B); // Red 800
  static const borderCritical = Color(0xFFFCA5A5); // Red 300
  static const bgCriticalDark = Color(0xFF450A0A); // Red 900
  static const textCriticalDark = Color(0xFFFEE2E2); // Red 200
  static const borderCriticalDark = Color(0xFF7F1D1D); // Red 900 border

  // --- Aliases for Layout Stability ---
  static const bgBack      = bgPage;
  static const bgBackDark  = bgPageDark;
  static const bgBase      = bgSurface;
  static const bgBaseDark  = bgSurfaceDark;
  
  static const borderWarningDark = Color(0xFF78350F); // Amber 900 border

  // --- Core Brand Identity ---
  static const primary     = Color(0xFF1565C0);
  static const primaryLight= Color(0xFFE3F2FD);
  static const accent      = Color(0xFF00BCD4);
  
  // Legacy Semantic Mappers (for backward compatibility during migration)
  static const safeGreen   = Color(0xFF00C853);
  static const warningAmber = Color(0xFFFFB300);
  static const criticalRed = Color(0xFFFF1744);
  // --- Premium Wellness Theme (Design Overhaul) ---
  static const premiumBg         = Color(0xFFF9F7F2); // Warm Cream/Beige
  static const premiumBgDark     = Color(0xFF0A0F1D); // Deep Midnight Blue
  static const premiumCard       = Color(0xFFFFFFFF);
  static const premiumCardDark   = Color(0xFF161C2C);
  static const premiumGlass      = Color(0xCCFFFFFF); // 80% White
  static const premiumGlassDark  = Color(0xCC161C2C); // 80% Dark Blue
  
  static const premiumTextMain   = Color(0xFF1A1A1A);
  static const premiumTextSub    = Color(0xFF6B7280);
  
  // High-fidelity gradients
  static const premiumBlueGrad   = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
