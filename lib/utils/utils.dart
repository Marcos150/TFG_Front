import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

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

Uint8List _preprocessImage(img.Image image) {
  return image.getBytes(order: img.ChannelOrder.rgb);
}

class OnnxRT {
  static final OnnxRT _singleton = OnnxRT._internal();
  final ort = OnnxRuntime();
  late OrtSession session;

  Future<void> init() async {
    //final options = OrtSessionOptions(interOpNumThreads: 1, intraOpNumThreads: 4, providers: [OrtProvider.XNNPACK]);
    session = await ort.createSessionFromAsset('assets/models/mobileNet.onnx');
  }

  factory OnnxRT() {
    return _singleton;
  }

  OnnxRT._internal() {
    init();
  }
}

Future<List<Rect>> onnxTest(final File image) async {
  final ort = OnnxRT();
  final Uint8List imageBytes = await image.readAsBytes();
  final img.Image? originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) return [];

  final int imageW = originalImage.width;
  final int imageH = originalImage.height;

  final Uint8List inputTensor = _preprocessImage(originalImage);

  // specify input with data and shape
  final inputs = {
    'image_tensor:0': await OrtValue.fromList(
      inputTensor,
      [1, imageH, imageW, 3], // Shape: [Batch, H, W, C]d
    ),
  };

  final outputs = await ort.session.run(inputs);

  // onnxruntime_flutter usually returns nested lists for multidimensional tensors
  final List<dynamic>? boxesRaw = await outputs['detection_boxes:0']?.asList();
  final List<dynamic>? scoresRaw = await outputs['detection_scores:0']
      ?.asList();
  final List<dynamic>? classesRaw = await outputs['detection_classes:0']
      ?.asList();

  final List<Rect> rects = [];

  if (boxesRaw != null && scoresRaw != null && classesRaw != null) {
    final List<dynamic> boxes = boxesRaw[0];
    final List<dynamic> scores = scoresRaw[0];
    final List<dynamic> classes = classesRaw[0];

    for (int i = 0; i < boxes.length; i++) {
      // The Python script checks for class == 1 and score > 0.5
      if (classes[i] == 1 && scores[i] > 0.5) {
        final List<dynamic> box = boxes[i];

        final double y1 = box[0];
        final double x1 = box[1];
        final double y2 = box[2];
        final double x2 = box[3];

        rects.add(Rect.fromLTRB(x1, y1, x2, y2));
      }
    }
  }

  return rects;
}
