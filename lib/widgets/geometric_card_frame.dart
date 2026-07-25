import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme_extension.dart';

/// Card-sized Islamic star-tessellation border frame (D-05, D-06, D-08).
///
/// Follows the same recoloring pattern as [GeometricBorderFrame] but uses
/// the smaller `star_tessellation_frame_card.svg` asset and a tighter
/// spacing-sm content inset (8px per `01-UI-SPEC.md` Spacing Scale),
/// suitable for wrapping individual cards or list items (e.g. a burdah
/// list entry) rather than an entire screen.
class GeometricCardFrame extends StatelessWidget {
  const GeometricCardFrame({super.key, required this.child});

  final Widget child;

  /// Spacing-sm per UI-SPEC Spacing Scale.
  static const double _contentInset = 8;

  @override
  Widget build(BuildContext context) {
    final borderStroke =
        Theme.of(context).extension<BurdahColors>()!.borderStroke;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/images/svg/star_tessellation_frame_card.svg',
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(borderStroke, BlendMode.srcIn),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(_contentInset),
          child: child,
        ),
      ],
    );
  }
}
