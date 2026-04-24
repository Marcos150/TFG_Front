import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:tfg/utils.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key, required this.file});

  final File file;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late final _controller = PdfControllerPinch(
    document: PdfDocument.openFile(widget.file.path),
  );

  @override
  Widget build(BuildContext context) {
    if (getFileExtension(widget.file) == 'pdf') {
      return PdfViewPinch(controller: _controller);
    } else if (getFileExtension(widget.file) == 'jpg' ||
        getFileExtension(widget.file) == 'png') {
      return Image.file(File(widget.file.path));
    }

    return Text(getFileExtension(widget.file));
  }
}
