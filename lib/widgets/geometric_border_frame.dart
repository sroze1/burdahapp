import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme_extension.dart';

/// Full-screen Islamic star-tessellation border frame (D-05, D-06, D-08).
///
/// Wraps [child] with the star-tessellation pattern rendered from
/// `assets/images/svg/star_tessellation_frame_full.svg`, recolored to the
/// current theme's [BurdahColors.borderStroke] via a `colorFilter` — never
/// the deprecated `color`/`colorBlendMode` `SvgPicture` params, which were
/// removed from `flutter_svg` (RESEARCH.md Pitfall 6).
///
/// The border frames content without competing with it (D-05): [child] is
/// inset from the border edges by the spacing-lg token (24px per
/// `01-UI-SPEC.md` Spacing Scale). The SVG scales via [BoxFit.contain] so
/// the tessellation does not distort at different aspect ratios
/// ([assumption:ui-overflow] — verify visually on phone- and
/// tablet-class sizes).
class GeometricBorderFrame extends StatelessWidget {
  const GeometricBorderFrame({super.key, required this.child});

  final Widget child;

  /// Spacing-lg per UI-SPEC Spacing Scale.
  static const double _contentInset = 24;

  @override
  Widget build(BuildContext context) {
    final borderStroke =
        Theme.of(context).extension<BurdahColors>()!.borderStroke;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/images/svg/star_tessellation_frame_full.svg',
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
