import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF524ADD);
  static const Color primaryLight = Color(0xFF8B85FF);

  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryDark = Color(0xFF00A8CC);
  static const Color secondaryLight = Color(0xFF4DE2FF);

  static const Color accent = Color(0xFF00F5D4);
  static const Color accentDark = Color(0xFF00C4A9);
  static const Color accentLight = Color(0xFF33FFE3);

  static const Color background = Color(0xFF0F0F1A);
  static const Color backgroundLight = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF1E1E32);
  static const Color surface = Color(0xFF252542);

  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textTertiary = Color(0xFF808090);

  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB74D);
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);

  static const Color glass = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x20FFFFFF);

  static const Color gradientStart = Color(0xFF6C63FF);
  static const Color gradientEnd = Color(0xFF00D4FF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
  );
}
