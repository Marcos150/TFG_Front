import 'dart:io' show File;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:opencv_dart/opencv.dart' as cv;

void showSnackbar(
  final String text,
  final BuildContext context, {
  final int duration = 2,
}) {
  final snackBar = SnackBar(
    duration: Duration(seconds: duration),
    content: Text(text),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String getFileExtension(final File file) => file.path.split('.').last;

Future<ImageScanResult?> scanAsPdf() async {
  try {
    final result = await FlutterDocScanner().getScannedDocumentAsImages();
    return result;
  } on DocScanException catch (e) {
    print('Scan failed: ${e.code} - ${e.message}');
  }

  return null;
}

Uint8List detectSheetMusic(final File file) {
  final img = cv.imread(file.path, flags: cv.IMREAD_COLOR);
  final gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY);
  final binary = cv.adaptiveThreshold(
      gray, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY_INV, 11, 2
  );

  final verticalKernel = cv.getStructuringElement(cv.MORPH_RECT, (1, 50));
  final barLinesImg = cv.morphologyEx(binary, cv.MORPH_OPEN, verticalKernel);
  final lines = cv.HoughLinesP(
      barLinesImg, 1, 3.14 / 180, 50,
      minLineLength: 50, maxLineGap: 10
  );

  final List<cv.Rect> extractedBarLines = [];
  for (int i = 0; i < lines.rows; i++) {
    final line = lines.at<cv.Vec4i>(i, 0); // [x1, y1, x2, y2]
    final x1 = line.val1;
    final y1 = line.val2;
    final y2 = line.val4;

    final yTop = math.min(y1, y2);
    final height = (y2 - y1).abs();

    extractedBarLines.add(cv.Rect(x1, yTop, 0, height)); // Width is 0 for a line
  }

  extractedBarLines.sort((a, b) => a.x.compareTo(b.x));

  double maxLineHeight = 0;
  for (final line in extractedBarLines) {
    if (line.height > maxLineHeight) maxLineHeight = line.height.toDouble();
  }

  final List<cv.Rect> cleanBarLines = [];
  for (final line in extractedBarLines) {
    if (line.height > (maxLineHeight * 0.85)) {
      cleanBarLines.add(line);
    }
  }

  final List<cv.Rect> measures = [];

  for (int i = 0; i < cleanBarLines.length - 1; i++) {
    final currentLine = cleanBarLines[i];

    for (int j = i + 1; j < cleanBarLines.length; j++) {
      final nextLine = cleanBarLines[j];

      // Check if they are on the same line (Y-coordinates are within 30 pixels)
      if ((currentLine.y - nextLine.y).abs() < 30) {
        final measureWidth = nextLine.x - currentLine.x;

        if (measureWidth > 50 && measureWidth <= img.cols * 0.75) {
          final measureHeight = math.max(currentLine.height, nextLine.height);
          measures.add(cv.Rect(currentLine.x, currentLine.y, measureWidth, measureHeight));
          break;
        }
      }
    }
  }

  final displayImg = img.clone();
  for (int i = 0; i < measures.length; i++) {
    final rect = measures[i];

    cv.rectangle(
        displayImg,
        rect,
        cv.Scalar(0, 255, 0, 0),
        thickness: 2
    );

    cv.putText(
        displayImg,
        'M${i + 1}',
        cv.Point(rect.x, rect.y - 10),
        cv.FONT_HERSHEY_SIMPLEX,
        0.5,
        cv.Scalar(255, 0, 0, 0),
        thickness: 1
    );
  }

  return cv.imencode('.png', displayImg).$2;
}
