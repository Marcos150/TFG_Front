import 'package:flutter/material.dart';

class MeasurePainter extends CustomPainter {
  final List<Rect> _rects;

  MeasurePainter(this._rects);

  MeasurePainter.fromOffsets(Offset start, Offset end)
    : _rects = [Rect.fromPoints(start, end)];

  bool _isRectNotScaled(Rect rect) {
    return rect.left < 1.0 &&
        rect.top < 1.0 &&
        rect.right <= 1.0 &&
        rect.bottom <= 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withAlpha(127)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = Colors.red.withAlpha(25)
      ..style = PaintingStyle.fill;

    for (final rect in _rects) {
      final isNotScaled = _isRectNotScaled(rect);

      final scaledRect = isNotScaled
          ? Rect.fromLTRB(
              rect.left * size.width,
              rect.top * size.height,
              rect.right * size.width,
              rect.bottom * size.height,
            )
          : rect;

      canvas.drawRect(scaledRect, paint);
      canvas.drawRect(scaledRect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(MeasurePainter oldDelegate) => true;
}
