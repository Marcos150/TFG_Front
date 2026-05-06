import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

class OnnxRT {
  static final OnnxRT _singleton = OnnxRT._internal();
  final ort = OnnxRuntime();
  late OrtSession session;

  Future<void> init() async {
    //final options = OrtSessionOptions(interOpNumThreads: 1, intraOpNumThreads: 4, providers: [OrtProvider.XNNPACK]);
    session = await ort.createSessionFromAsset('assets/models/mobileNet.onnx');
  }

  Future<Map<String, OrtValue>> runInference(Map<String, OrtValue> inputs) async {
    return await session.run(inputs);
  }

  factory OnnxRT() {
    return _singleton;
  }

  OnnxRT._internal() {
    init();
  }
}