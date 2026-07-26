import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/gold_cta_button.dart';

/// The app's home screen (D-01, D-02, D-03, NAV-01).
///
/// Deliberately minimal: no `AppBar`, no title text, no Arabic calligraphy
/// header, no geometric framing — just a single centered [GoldCtaButton] on
/// the theme's plain background. "Prominent" (NAV-01's original wording) is
/// satisfied via size/color/centering, not literal geometric border widgets
/// — see 03-RESEARCH.md Phase Requirements reconciliation note.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GoldCtaButton(
          label: 'Burdah',
          onPressed: () => context.push('/burdahs'),
        ),
      ),
    );
  }
}
