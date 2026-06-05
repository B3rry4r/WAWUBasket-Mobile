import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Drawable signature pad. Tracks pan strokes and renders them as a
/// black ink path on a white surface. Use [SignaturePadController] to
/// clear or read the stroke list.
class SignaturePadController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  bool get isEmpty => _strokes.isEmpty;

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  void beginStroke(Offset p) {
    _strokes.add(<Offset>[p]);
    notifyListeners();
  }

  void appendToStroke(Offset p) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(p);
    notifyListeners();
  }
}

class SignaturePad extends StatefulWidget {
  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 180,
  });

  final SignaturePadController controller;
  final double height;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WBRadius.card),
        border: Border.all(color: WBColors.bgDivider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WBRadius.card),
        child: Stack(
          children: [
            Positioned.fill(
              // A RawGestureDetector with an eager pan recognizer. The default
              // GestureDetector defers its hit-test to the CustomPaint child
              // (which isn't hittable), so taps never land; and a plain pan
              // recognizer loses the gesture arena to the surrounding
              // scrollable. _EagerPanGestureRecognizer claims every pointer so
              // strokes draw reliably even inside a ListView.
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  _EagerPanGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                          _EagerPanGestureRecognizer>(
                    () => _EagerPanGestureRecognizer(),
                    (r) {
                      r.onStart = (d) {
                        widget.controller.beginStroke(d.localPosition);
                      };
                      r.onUpdate = (d) {
                        widget.controller.appendToStroke(d.localPosition);
                      };
                    },
                  ),
                },
                child: CustomPaint(
                  painter: _InkPainter(widget.controller.strokes),
                  size: Size.infinite,
                ),
              ),
            ),
            if (widget.controller.isEmpty)
              const IgnorePointer(
                child: Center(
                  child: Text(
                    'Sign here',
                    style: TextStyle(
                      color: WBColors.fgPlaceholder,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: widget.controller.clear,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: WBColors.bgSoft,
                    borderRadius: BorderRadius.circular(WBRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const WBIcon(WBIconName.close, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        'Clear',
                        style: WBTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 10,
              child: Text(
                'TRADER SIGNATURE',
                style: WBTypography.label.copyWith(
                  color: WBColors.fgPlaceholder,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.66,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InkPainter extends CustomPainter {
  _InkPainter(this.strokes);
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WBColors.fgHeader
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.isNotEmpty) {
          canvas.drawCircle(stroke.first, 1.1, paint);
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _InkPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}

/// A [PanGestureRecognizer] that immediately wins the gesture arena instead of
/// yielding to an ancestor scrollable. Without this, a signature pad placed
/// inside a `ListView` loses vertical drags to the list's own scroll
/// recognizer and the user can't draw.
class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    // The arena tried to hand the pointer to another member (the scrollable);
    // accept it here so the stroke keeps drawing.
    acceptGesture(pointer);
  }
}
