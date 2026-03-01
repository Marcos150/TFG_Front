import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:tfg/utils.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    if (getFileExtension(file) == 'pdf') {
      return PdfViewPinch(
        controller: PdfControllerPinch(
          document: PdfDocument.openFile(file.path),
        ),
      );
    }
    else if (getFileExtension(file) == 'jpg') {
      return Image.file(File(file.path));
    }

    return Text(getFileExtension(file));
  }
}
