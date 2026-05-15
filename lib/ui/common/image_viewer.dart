import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:tfg/models/measure.dart';

import '../../utils/sheet_music_file_type.dart';
import '../../utils/measure_painter.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({
    super.key,
    required this.file,
    this.measures = const [],
    this.hideMeasures = false,
  });

  final File file;
  final List<Measure> measures;
  final bool hideMeasures;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late final _controller = getFileType(widget.file) == SheetMusicFileType.pdf
      ? PdfController(document: PdfDocument.openFile(widget.file.path))
      : null;
  double? _pdfHeight;

  Future<void> _calculateHeight() async {
    final document = await _controller!.document;
    final page = await document.getPage(1);

    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      _pdfHeight = (page.height / page.width) * screenWidth;
    });

    await page.close();
  }

  @override
  void initState() {
    if (getFileType(widget.file) == SheetMusicFileType.pdf) {
      _calculateHeight();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Placeholder();
    final extension = getFileType(widget.file);

    if (extension == SheetMusicFileType.pdf) {
      content = SizedBox(
        height: _pdfHeight,
        child: AbsorbPointer(child: PdfView(controller: _controller!)),
      );
    } else if (extension == SheetMusicFileType.image) {
      content = Image.file(
        File(widget.file.path),
        alignment: AlignmentGeometry.topCenter,
      );
    }

    return CustomPaint(
      foregroundPainter: MeasurePainter(
        widget.measures,
        hideMeasures: widget.hideMeasures,
      ),
      child: content,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
