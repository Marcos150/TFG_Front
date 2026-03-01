import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

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

Future<PdfScanResult?> scanAsPdf() async {
  try {
    final result = await FlutterDocScanner().getScannedDocumentAsPdf();
    return result;
  } on DocScanException catch (e) {
    print('Scan failed: ${e.code} - ${e.message}');
  }

  return null;
}
