import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';
import 'app_theme_extension.dart';

/// Assembles the app's light and dark [ThemeData] instances.
///
/// Both themes are fully functional per D-03 — dark mode is not an
/// afterthought stub, it uses the deep green as its background with
/// lighter text and brightened gold accents.
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.lightPrimaryGreen,
      onPrimary: AppColors.lightTextOnGreen,
      secondary: AppColors.lightGoldAccent,
      onSecondary: AppColors.lightTextOnGold,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.lightError,
      onError: AppColors.lightTextOnGreen,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightPrimaryGreen,
        foregroundColor: AppColors.lightTextOnGreen,
      ),
      textTheme: AppTextTheme.build(AppColors.lightTextPrimary),
      extensions: const [BurdahColors.light],
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.darkElevatedSurface,
      onPrimary: AppColors.darkTextPrimary,
      secondary: AppColors.darkGoldAccent,
      onSecondary: AppColors.darkTextOnGold,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.darkError,
      onError: AppColors.darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkElevatedSurface,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      textTheme: AppTextTheme.build(AppColors.darkTextPrimary),
      extensions: const [BurdahColors.dark],
    );
  }
}
