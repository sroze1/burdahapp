import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'zoomable_pdf_page.dart';

/// Page-by-page, book-like swiper over a bundled PDF asset (READ-01, READ-04).
///
/// Uses `PageView.builder` (not `pdfrx`'s top-level `PdfViewer`, which is
/// built for continuous pan/zoom browsing, not discrete page turns — see
/// RESEARCH.md Anti-Patterns) so each swipe snaps exactly one page. `reverse:
/// true` flips the scroll direction to right-to-left, matching Arabic book
/// page order (READ-04, RESEARCH.md Pattern 3): page 1 appears first and
/// forward swiping advances the page index while moving visually
/// right-to-left.
///
/// Swipe is locked (via [NeverScrollableScrollPhysics]) whenever the
/// currently visible page reports itself as zoomed in past 1.0x
/// ([ZoomablePdfPage.onZoomChanged]), and unlocked when zoom resets. The
/// lock state is also force-reset on every page change so a zoom state left
/// behind on a previous page can never leak onto a freshly-shown page
/// (RESEARCH.md Pitfall 1).
class PdfPageSwiper extends StatefulWidget {
  const PdfPageSwiper({super.key, required this.pdfAsset});

  /// The bundled asset path, e.g. `Burdah.pdfAsset`.
  final String pdfAsset;

  @override
  State<PdfPageSwiper> createState() => _PdfPageSwiperState();
}

class _PdfPageSwiperState extends State<PdfPageSwiper> {
  final PageController _pageController = PageController();
  bool _swipeLocked = false;

  /// Vertical padding around the error-state copy, matching the pattern in
  /// `design_system_test_screen.dart`.
  static const double _errorStateVerticalPadding = 16;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleZoomChanged(bool isZoomed) {
    if (_swipeLocked != isZoomed) {
      setState(() => _swipeLocked = isZoomed);
    }
  }

  void _handlePageChanged(int _) {
    // A page change always means the newly-visible page starts unzoomed
    // (RESEARCH.md Pitfall 1) — never let a stale lock from the previous
    // page persist onto the new one.
    if (_swipeLocked) {
      setState(() => _swipeLocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PdfDocumentViewBuilder.asset(
      widget.pdfAsset,
      loadingBuilder: (context) =>
          const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stackTrace) => _buildErrorState(context),
      builder: (context, document) {
        final pageCount = document?.pages.length ?? 0;
        return PageView.builder(
          controller: _pageController,
          reverse: true,
          itemCount: pageCount,
          physics: _swipeLocked
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          onPageChanged: _handlePageChanged,
          itemBuilder: (context, index) {
            if (document == null) return const SizedBox.shrink();
            return ZoomablePdfPage(
              document: document,
              pageNumber: index + 1,
              onZoomChanged: _handleZoomChanged,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    // UI-SPEC Copywriting Contract — error state (RESEARCH.md Security
    // Domain V5: corrupted/unreadable PDF asset must not crash uncaught).
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: _errorStateVerticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Something's not right",
              style: textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "This couldn't be loaded. Please restart the "
              'app, or reinstall it if the problem continues.',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
