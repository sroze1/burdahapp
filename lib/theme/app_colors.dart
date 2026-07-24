import 'package:flutter/material.dart';

/// Raw hex color constants for both the light and dark themes.
///
/// These are the single source of truth for every locked hex value from
/// `01-UI-SPEC.md`'s Color section (D-01 through D-04). Widgets must never
/// hardcode these hex values directly — always consume via
/// `Theme.of(context)` / `BurdahColors` (see app_theme_extension.dart).
class AppColors {
  const AppColors._();

  // --- Light theme ---
  static const lightBackground = Color(0xFFFAF6EA);
  static const lightPrimaryGreen = Color(0xFF0A642B);
  static const lightGoldAccent = Color(0xFFC9A227);
  static const lightTextPrimary = Color(0xFF1B2B20);
  static const lightTextSecondary = Color(0xFF5B6B5E);
  static const lightTextOnGreen = Color(0xFFFAF6EA);
  static const lightTextOnGold = Color(0xFF1B2B20);
  static const lightError = Color(0xFFB3261E);

  // --- Dark theme ---
  static const darkBackground = Color(0xFF0A642B);
  static const darkElevatedSurface = Color(0xFF12793A);
  static const darkGoldAccent = Color(0xFFE3C067);
  static const darkTextPrimary = Color(0xFFF5EFDD);
  static const darkTextSecondary = Color(0xFFC9D6C9);
  static const darkTextOnGold = Color(0xFF1B2B20);
  static const darkError = Color(0xFFE2726B);
}
