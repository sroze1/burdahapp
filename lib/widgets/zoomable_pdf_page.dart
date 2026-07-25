import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Pinch-to-zoom wrapper around a single rendered PDF page (READ-02).
///
/// `pdfrx 2.4.7`'s [PdfPageView] is a plain image-rendering widget — it
/// exposes no zoom/scale API of its own (confirmed by reading the pinned
/// package source, resolving RESEARCH.md Open Question 1 / Assumption A1).
/// Pinch-to-zoom is therefore composed externally via [InteractiveViewer]
/// driven by a [TransformationController].
///
/// Each page gets its own, independently-owned [TransformationController]
/// (constructed in [State], never shared or hoisted to a parent) so zoom on
/// one page can never leak into another page's state (RESEARCH.md
/// Pitfall 1). The controller's scale is reported to [onZoomChanged] with a
/// small epsilon (`1.01`) so floating-point jitter at exactly `1.0` doesn't
/// spuriously toggle the parent [PdfPageSwiper]'s swipe-lock.
class ZoomablePdfPage extends StatefulWidget {
  const ZoomablePdfPage({
    super.key,
    required this.document,
    required this.pageNumber,
    required this.onZoomChanged,
  });

  /// The already-loaded PDF document (from [PdfDocumentViewBuilder]).
  final PdfDocument document;

  /// The 1-indexed page number to render.
  final int pageNumber;

  /// Called with `true` when this page is zoomed in past 1.0x, and `false`
  /// when it returns to 1.0x. The parent uses this to lock/unlock swiping.
  final ValueChanged<bool> onZoomChanged;

  /// Scale epsilon avoiding float jitter around 1.0 (RESEARCH.md Pattern 2).
  static const double _zoomEpsilon = 1.01;

  @override
  State<ZoomablePdfPage> createState() => _ZoomablePdfPageState();
}

class _ZoomablePdfPageState extends State<ZoomablePdfPage> {
  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _controller.addListener(_handleTransformChanged);
  }

  void _handleTransformChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > ZoomablePdfPage._zoomEpsilon);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1.0,
      maxScale: 4.0,
      child: PdfPageView(document: widget.document, pageNumber: widget.pageNumber),
    );
  }
}
