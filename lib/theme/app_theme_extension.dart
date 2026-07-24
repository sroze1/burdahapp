import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Custom theme tokens for the gold/cream accent set that doesn't map
/// cleanly onto Material's default `ColorScheme` roles.
///
/// Access via `Theme.of(context).extension<BurdahColors>()!` — never
/// hardcode these hex values in widget code (single-source-of-truth
/// contract, see RESEARCH.md Pattern 2 / Anti-Patterns).
@immutable
class BurdahColors extends ThemeExtension<BurdahColors> {
  /// Accent gold — reserved for CTA fill, divider hairlines, icon accents,
  /// and geometric border trim. Never body-sized text (WCAG contrast,
  /// RESEARCH.md Pitfall 4).
  final Color gold;

  /// Stroke color for geometric border/frame widgets (D-05 through D-08).
  final Color borderStroke;

  /// Warm cream/ivory tone. In the light theme this matches the scaffold
  /// background; in the dark theme it is repurposed as the dark
  /// background role per D-03.
  final Color cream;

  const BurdahColors({
    required this.gold,
    required this.borderStroke,
    required this.cream,
  });

  static const light = BurdahColors(
    gold: AppColors.lightGoldAccent,
    borderStroke: AppColors.lightPrimaryGreen,
    cream: AppColors.lightBackground,
  );

  static const dark = BurdahColors(
    gold: AppColors.darkGoldAccent,
    borderStroke: AppColors.darkElevatedSurface,
    cream: AppColors.darkBackground,
  );

  @override
  BurdahColors copyWith({Color? gold, Color? borderStroke, Color? cream}) =>
      BurdahColors(
        gold: gold ?? this.gold,
        borderStroke: borderStroke ?? this.borderStroke,
        cream: cream ?? this.cream,
      );

  @override
  BurdahColors lerp(ThemeExtension<BurdahColors>? other, double t) {
    if (other is! BurdahColors) return this;
    return BurdahColors(
      gold: Color.lerp(gold, other.gold, t)!,
      borderStroke: Color.lerp(borderStroke, other.borderStroke, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
    );
  }
}
