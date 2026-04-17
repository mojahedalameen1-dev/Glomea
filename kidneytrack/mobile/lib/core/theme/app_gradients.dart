import 'package:flutter/material.dart';

class AppGradients {
  // Page header gradient (top of dashboard)
  static const LinearGradient clinicalHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1565C0), // Primary Blue
      Color(0xFF1E88E5), // Lighter Blue
    ],
  );

  static const LinearGradient headerGradient = clinicalHeader;
  static const primaryGradient = headerGradient;
  static const brandGradient = headerGradient;

  // Safe status card
  static const safeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
  );

  // Warning status card
  static const warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), Color(0xFFFFD54F)],
  );

  // Critical status card
  static const criticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF1744), Color(0xFFFF6D00)],
  );

  // Potassium card special (most critical indicator)
  static const potassiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B1FA2), Color(0xFFE91E63)],
  );

  // Fluid tracker ring background
  static const fluidGradient = LinearGradient(
    colors: [Color(0xFF0288D1), Color(0xFF26C6DA)],
  );
}
