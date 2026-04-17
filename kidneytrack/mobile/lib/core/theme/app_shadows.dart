import 'package:flutter/material.dart';

class AppShadows {
  // Level 1: Standard Medical Cards
  static List<BoxShadow> elev1 = [
    const BoxShadow(
      color: Color(0x0A334155), // ~4% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Level 2: Warning Banners / Active Modals
  static List<BoxShadow> elev2 = [
    const BoxShadow(
      color: Color(0x14334155), // ~8% opacity
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  // Level 3: Critical Alerts / High Elevation
  static List<BoxShadow> elev3 = [
    const BoxShadow(
      color: Color(0x1F334155), // ~12% opacity
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Action / FAB
  static List<BoxShadow> fab = elev3;

  // Legacy alias for backward compatibility
  static List<BoxShadow> get card => elev1;
}
