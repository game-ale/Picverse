import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — deep indigo/purple from auth mocks
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42E8);
  static const Color primaryLight = Color(0xFF8B83FF);

  // Auth gradient
  static const Color authGradientStart = Color(0xFF1A1035);
  static const Color authGradientMiddle = Color(0xFF2D1B69);
  static const Color authGradientEnd = Color(0xFF0D0B1E);

  // Glow / accent
  static const Color glowPurple = Color(0x406C63FF);
  static const Color glowPurpleStrong = Color(0x806C63FF);

  // Neutrals
  static const Color white = Colors.white;
  static const Color black = Color(0xFF0D0D0D);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Surface (dark mode auth cards)
  static const Color cardDark = Color(0xFF1E1740);
  static const Color cardDarkBorder = Color(0xFF2E2560);
  static const Color inputDark = Color(0xFF251E45);
  static const Color inputDarkBorder = Color(0xFF3A3060);

  // Light theme surfaces
  static const Color scaffoldLight = Color(0xFFFAFAFA);
  static const Color cardLight = Colors.white;
}
