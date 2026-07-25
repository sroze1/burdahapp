import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

/// Gold-filled call-to-action button (D-02).
///
/// Background fill reads [BurdahColors.gold] from the current theme.
/// Label color reads `ColorScheme.onSecondary`, which `AppTheme` wires to
/// `AppColors.lightTextOnGold`/`AppColors.darkTextOnGold` — both
/// `0xFF1B2B20` per `01-UI-SPEC.md` — so the correct text-on-gold color is
/// resolved per theme without hardcoding a hex literal here.
///
/// The label text uses the Heading role (24px Bold, via
/// `textTheme.headlineSmall`) to satisfy the WCAG large-text threshold:
/// gold-on-green contrast is only 3.0-4.2:1 (RESEARCH.md Pitfall 4),
/// which passes AA only at large-text size, never at body-text size.
class GoldCtaButton extends StatelessWidget {
  const GoldCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  /// Spacing-xl per UI-SPEC Spacing Scale.
  static const double _horizontalPadding = 32;

  /// Spacing-md per UI-SPEC Spacing Scale.
  static const double _verticalPadding = 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final burdahColors = theme.extension<BurdahColors>()!;
    final onGold = theme.colorScheme.onSecondary;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: burdahColors.gold,
        foregroundColor: onGold,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: theme.textTheme.headlineSmall?.copyWith(color: onGold),
      ),
    );
  }
}
