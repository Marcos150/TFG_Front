import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart' show OrtValue;
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart';
import 'dart:typed_data';

import 'package:tfg/models/measure.dart';

import 'OnnxRT.dart';

void showSnackbar(
  final String text,
  final BuildContext context, {
  final int duration = 4,
  final String? actionLabel,
  final VoidCallback? action,
}) {
  final snackBar = SnackBar(
    duration: Duration(seconds: duration),
    content: Text(text),
    action: SnackBarAction(
      label: actionLabel ?? '',
      onPressed: action ?? () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void myShowDialog(
  final String title,
  final String content,
  final BuildContext context, {
  final List<Widget>? actionLabels,
  final List<VoidCallback>? actions,
}) {
  assert(
    actionLabels?.length == actions?.length,
    'ActionLabel and actions must have the same length',
  );

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (context, _, _) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: List.generate(
        actions?.length ?? 0,
        (index) => TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (actions?[index] != null) actions?[index]();
          },
          child: actionLabels?[index] ?? const Text('OK'),
        ),
      ),
    ),
  );
}

String _getFileExtension(final File file) => file.path.split('.').last;

enum FileType { pdf, image, other }

FileType getFileType(final File file) {
  final extension = _getFileExtension(file);
  switch (extension) {
    case 'pdf':
      return FileType.pdf;
    case 'jpg':
    case 'jpeg':
    case 'png':
      return FileType.image;
    default:
      return FileType.other;
  }
}

Future<ImageScanResult?> scanAsPdf() async {
  try {
    final result = await FlutterDocScanner().getScannedDocumentAsImages();
    return result;
  } on DocScanException catch (e) {
    print('Scan failed: ${e.code} - ${e.message}');
  }

  return null;
}

Future<img.Image?> pdfToImage(File pdfPath, {int numPage = 1}) async {
  final document = await PdfDocument.openFile(pdfPath.path);
  final page = await document.getPage(numPage);

  // width/height: Higher numbers = better quality (DPI)
  final pageImage = await page.render(
    width: page.width * 2,
    height: page.height * 2,
    format: PdfPageImageFormat.jpeg,
  );

  await document.close();

  if (pageImage != null) {
    final img.Image? decodedImage = img.decodeImage(pageImage.bytes);
    return decodedImage;
  }

  return null;
}

Uint8List _preprocessImage(img.Image image) {
  return image.getBytes(order: img.ChannelOrder.rgb);
}

Future<List<Measure>> findMeasures(final File image) async {
  final fileType = getFileType(image);
  if (fileType == FileType.other) return [];

  final img.Image? originalImage;
  if (fileType == FileType.pdf) {
    originalImage = await pdfToImage(image);
  } else {
    final Uint8List imageBytes = await image.readAsBytes();
    originalImage = img.decodeImage(imageBytes);
  }

  if (originalImage == null) return [];

  final ort = OnnxRT();
  final int imageW = originalImage.width;
  final int imageH = originalImage.height;

  final Uint8List inputTensor = _preprocessImage(originalImage);

  // specify input with data and shape
  final inputs = {
    'image_tensor:0': await OrtValue.fromList(
      inputTensor,
      [1, imageH, imageW, 3], // Shape: [Batch, H, W, C]
    ),
  };

  final outputs = await ort.runInference(inputs);

  // onnxruntime_flutter usually returns nested lists for multidimensional tensors
  final List<dynamic>? boxesRaw = await outputs['detection_boxes:0']?.asList();
  final List<dynamic>? scoresRaw = await outputs['detection_scores:0']
      ?.asList();
  final List<dynamic>? classesRaw = await outputs['detection_classes:0']
      ?.asList();

  final List<Measure> rects = [];

  if (boxesRaw != null && scoresRaw != null && classesRaw != null) {
    final List<dynamic> boxes = boxesRaw[0];
    final List<double> scores = scoresRaw[0];

    for (int i = 0; i < boxes.length; i++) {
      if (scores[i] > 0.5) {
        final List<dynamic> box = boxes[i];

        final double y1 = box[0];
        final double x1 = box[1];
        final double y2 = box[2];
        final double x2 = box[3];

        rects.add(Measure(x1, y1, x2, y2));
      }
    }
  }

  return rects;
}
