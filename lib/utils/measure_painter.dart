import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:tfg/models/playing_state.dart';

class MeasurePainter extends CustomPainter {
  final List<Rect> _rects;
  final bool hideMeasures;

  MeasurePainter(this._rects, {this.hideMeasures = false});

  MeasurePainter.fromOffsets(
    Offset start,
    Offset end, {
    this.hideMeasures = false,
  }) : _rects = [Rect.fromPoints(start, end)];

  bool _isRectNotScaled(Rect rect) {
    return rect.left < 1.0 &&
        rect.top < 1.0 &&
        rect.right <= 1.0 &&
        rect.bottom <= 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = hideMeasures ? Colors.white : Colors.blue.withAlpha(127)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = hideMeasures ? Colors.white : Colors.blue.withAlpha(25)
      ..style = PaintingStyle.fill;

    final currentMeasure = PlayingState().currentMeasure;
    int measuresToShow = _rects.length;
    if (!currentMeasure.isNegative) {
      measuresToShow = min(measuresToShow, currentMeasure);
    }

    for (int i = 0; i < measuresToShow; i++) {
      final rect = _rects[i];
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
