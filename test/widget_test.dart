// Basic smoke test for the BurdahApp root widget.
//
// Verifies the app boots and the design-system test screen renders its
// static section headings — a full render-and-await-catalog test would
// require pumping past the FutureBuilder's async gap, which is out of
// scope for this walking-skeleton smoke test.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:burdahapp/app.dart';

void main() {
  testWidgets('BurdahApp boots and shows the design system test screen', (
    WidgetTester tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const BurdahApp());
    await tester.pump();

    expect(find.text('Design System Test'), findsOneWidget);
    expect(find.text('Color Palette (DSGN-03)'), findsOneWidget);
  });
}
