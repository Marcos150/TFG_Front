import 'package:flutter/material.dart';

class MeasurePainter extends CustomPainter {
  final List<Rect> rects;

  MeasurePainter({required this.rects});

  MeasurePainter.fromOffsets(Offset start, Offset end)
    : rects = [Rect.fromPoints(start, end)];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withAlpha(127)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = Colors.red.withAlpha(25)
      ..style = PaintingStyle.fill;

    for (final rect in rects) {
      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(MeasurePainter oldDelegate) => oldDelegate.rects != rects;
}
