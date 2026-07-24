import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the app's [TextTheme], mapping the four typography roles from
/// `01-UI-SPEC.md` (Display, Heading, Body, Label) onto Material's
/// `TextTheme` slots.
///
/// Font-family mapping (UI-SPEC Typography section):
/// - Display / Heading roles → Scheherazade New (calligraphic display font)
/// - Body / Label roles → Amiri (higher-readability body font)
///
/// Fonts are loaded exclusively from the bundled `assets/google_fonts/`
/// files (see main.dart's `allowRuntimeFetching = false`) — never fetched
/// over the network.
class AppTextTheme {
  const AppTextTheme._();

  /// Display role: 32px Bold, line-height 1.25.
  static TextStyle _display(Color color) => GoogleFonts.scheherazadeNew(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.25,
        color: color,
      );

  /// Heading role: 24px Bold, line-height 1.3.
  static TextStyle _heading(Color color) => GoogleFonts.scheherazadeNew(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: color,
      );

  /// Body role: 16px Regular, line-height 1.6 (generous — Arabic
  /// diacritics and Naskh ascenders/descenders clip at tighter line
  /// heights, per UI-SPEC Typography section).
  static TextStyle _body(Color color) => GoogleFonts.amiri(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.6,
        color: color,
      );

  /// Label role: 14px Regular, line-height 1.4.
  static TextStyle _label(Color color) => GoogleFonts.amiri(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: color,
      );

  /// Builds a full [TextTheme] using [baseColor] as the text color for
  /// every role — callers pass the theme-appropriate primary text color
  /// (light or dark) so both themes share this single builder.
  static TextTheme build(Color baseColor) {
    return TextTheme(
      displayLarge: _display(baseColor),
      displayMedium: _display(baseColor),
      displaySmall: _display(baseColor),
      headlineLarge: _display(baseColor),
      headlineMedium: _heading(baseColor),
      headlineSmall: _heading(baseColor),
      titleLarge: _heading(baseColor),
      titleMedium: _body(baseColor),
      titleSmall: _label(baseColor),
      bodyLarge: _body(baseColor),
      bodyMedium: _body(baseColor),
      bodySmall: _label(baseColor),
      labelLarge: _label(baseColor),
      labelMedium: _label(baseColor),
      labelSmall: _label(baseColor),
    );
  }
}
