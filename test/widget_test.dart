// Basic smoke test for the BurdahApp root widget.
//
// The initial route ('/') now renders the animated SplashScreen (Phase 4),
// which fades in over several seconds and plays an audio clip — asserting
// on specific splash text/animation state is out of scope for this
// walking-skeleton smoke test. This test only verifies the app boots and
// renders its first frame without throwing.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:burdahapp/app.dart';

void main() {
  testWidgets('BurdahApp boots and renders without throwing', (
    WidgetTester tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const BurdahApp());
    await tester.pump();
    // The splash screen's flutter_animate chains schedule zero-duration
    // kickoff Timers at each stage transition; advance the fake clock past
    // the full ~6.1s chain (through the pushReplacement navigation to
    // Home) so no Timer is left pending when the test tears down the
    // widget tree (avoids a "Timer still pending" test-framework
    // assertion — this is test-harness only, not a runtime bug).
    await tester.pump(const Duration(milliseconds: 7200));

    expect(tester.takeException(), isNull);
  });
}
