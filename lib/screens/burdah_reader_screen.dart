import 'package:flutter/material.dart';

import '../data/models/burdah.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/pdf_page_swiper.dart';

/// The Burdah reading screen — page-by-page PDF viewer (DSGN-04).
///
/// Accepts an already-resolved [Burdah] via the constructor rather than
/// fetching one internally (RESEARCH.md Architectural Responsibility Map),
/// so this screen slots directly into a Phase 3 `go_router` route builder
/// without rework.
///
/// Islamic chrome is applied only to the [AppBar] — [BurdahColors.gold] for
/// the title-adjacent divider accent — and NOT wrapped around the
/// [PdfPageSwiper] itself. Per RESEARCH.md Anti-Patterns / Pitfall 3,
/// `GeometricBorderFrame` insets and overlays static content; wrapping it
/// around the gesture-active PDF viewport would eat into edge-swipe hit
/// testing and fight the border's own SVG layer against live pinch/swipe
/// touch targets. The PDF content area is left fully unencumbered.
class BurdahReaderScreen extends StatelessWidget {
  const BurdahReaderScreen({super.key, required this.burdah});

  final Burdah burdah;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final burdahColors = Theme.of(context).extension<BurdahColors>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(burdah.title),
        bottom: burdah.titleArabic != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(32),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      burdah.titleArabic!,
                      style: textTheme.bodyLarge?.copyWith(
                        color: burdahColors.gold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(child: PdfPageSwiper(pdfAsset: burdah.pdfAsset)),
    );
  }
}
