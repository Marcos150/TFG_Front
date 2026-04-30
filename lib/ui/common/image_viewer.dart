import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:tfg/utils/utils.dart';

import '../../utils/measure_painter.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key, required this.file, this.measures = const []});

  final File file;
  final List<Rect> measures;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late final _controller = PdfControllerPinch(
    document: PdfDocument.openFile(widget.file.path),
  );

  @override
  Widget build(BuildContext context) {
    Widget content = const Placeholder();
    final extension = getFileExtension(widget.file);

    if (extension == 'pdf') {
      content = PdfViewPinch(controller: _controller);
    } else if (extension == 'jpg' || extension == 'png') {
      content = Image.file(
        File(widget.file.path),
        alignment: AlignmentGeometry.topCenter,
      );
    }

    return Expanded(
      child: Stack(
        children: [
          // The base layer (Image or PDF)
          Positioned.fill(child: content),

          // The overlay layer (Rectangles)
          Positioned.fill(
            child: IgnorePointer(
              // Allows interaction with the PDF/Image underneath
              child: CustomPaint(
                painter: MeasurePainter(rects: widget.measures),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
