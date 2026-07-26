import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable fade-in / glow-to-peak / fade-out reveal animation (D-05, D-09).
///
/// Total duration is fixed at 600ms fade-in + 800ms glow + 600ms fade-out =
/// 2000ms, matching D-05's locked 2-second spec. The glow stage uses a
/// [ColorFiltered] white overlay ramping up to peak brightness at the
/// midpoint and easing back — visually distinct from a flat opacity fade
/// (D-09), not a simple screen-transition fade.
class TransitionalRevealImage extends StatelessWidget {
  const TransitionalRevealImage({
    super.key,
    required this.assetPath,
    required this.onComplete,
  });

  final String assetPath;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, fit: BoxFit.cover)
        .animate(onComplete: (_) => onComplete())
        .fadeIn(duration: 600.ms, curve: Curves.easeIn)
        .then()
        .custom(
          duration: 800.ms,
          builder: (context, value, child) => ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.35 * (1 - (2 * value - 1).abs())),
              BlendMode.screen,
            ),
            child: child,
          ),
        )
        .then()
        .fadeOut(duration: 600.ms, curve: Curves.easeOut);
  }
}
