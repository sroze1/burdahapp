import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Zoomable wrapper around a single rendered PDF page (READ-02).
///
/// Uses double-tap to enter/exit zoom mode, with pinch-to-zoom for fine
/// adjustment once zoomed. This avoids a fundamental Flutter gesture conflict:
/// InteractiveViewer's ScaleGestureRecognizer claims single-finger horizontal
/// drags even at 1x scale, blocking PageView from receiving swipe gestures.
/// Disabling both panEnabled and scaleEnabled when not zoomed makes
/// InteractiveViewer passive, letting PageView handle page-turn swiping.
///
/// Each page gets its own TransformationController (never shared) so zoom
/// on one page cannot leak into another (RESEARCH.md Pitfall 1).
class ZoomablePdfPage extends StatefulWidget {
  const ZoomablePdfPage({
    super.key,
    required this.document,
    required this.pageNumber,
    required this.onZoomChanged,
  });

  final PdfDocument document;
  final int pageNumber;
  final ValueChanged<bool> onZoomChanged;

  static const double _zoomEpsilon = 1.01;
  static const double _doubleTapScale = 2.5;

  @override
  State<ZoomablePdfPage> createState() => _ZoomablePdfPageState();
}

class _ZoomablePdfPageState extends State<ZoomablePdfPage>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _animController;
  Animation<Matrix4>? _animation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        if (_animation != null) {
          _controller.value = _animation!.value;
        }
      });
    _controller.addListener(_handleTransformChanged);
  }

  void _handleTransformChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    final zoomed = scale > ZoomablePdfPage._zoomEpsilon;
    if (_isZoomed != zoomed) {
      setState(() => _isZoomed = zoomed);
    }
    widget.onZoomChanged(zoomed);
  }

  void _handleDoubleTap() {
    final s = ZoomablePdfPage._doubleTapScale;
    final end = _isZoomed
        ? Matrix4.identity()
        : (Matrix4.identity()..scaleByDouble(s, s, 1.0, 1.0));
    _animation = Matrix4Tween(begin: _controller.value, end: end).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTransformChanged);
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1.0,
        maxScale: 4.0,
        panEnabled: _isZoomed,
        scaleEnabled: _isZoomed,
        child: PdfPageView(
          document: widget.document,
          pageNumber: widget.pageNumber,
        ),
      ),
    );
  }
}
