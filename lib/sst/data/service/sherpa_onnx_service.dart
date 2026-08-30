import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'stt_constants.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class SherpaOnnxService {
  static final SherpaOnnxService _instance = SherpaOnnxService._internal();
  factory SherpaOnnxService() => _instance;
  SherpaOnnxService._internal();

  sherpa.OfflineRecognizer? _recognizer;

  Future<void> init() async {
    if (_recognizer != null) return;

    final dir = await getApplicationDocumentsDirectory();

    final config = sherpa.OfflineRecognizerConfig(
      model: sherpa.OfflineModelConfig(
        moonshine: sherpa.OfflineMoonshineModelConfig(
          encoder: '${dir.path}/${SttConstants.encoderFile}',
          mergedDecoder: '${dir.path}/${SttConstants.decoderFile}',
        ),
        tokens: '${dir.path}/${SttConstants.tokensFile}',
      ),
    );

    _recognizer = sherpa.OfflineRecognizer(config);
  }

  String transcribe(List<double> samples) {
    if (_recognizer == null) return "";

    final stream = _recognizer!.createStream();
    stream.acceptWaveform(
      samples: Float32List.fromList(samples),
      sampleRate: 16000,
    );

    _recognizer!.decode(stream);

    final result = _recognizer!.getResult(stream).text;
    stream.free();
    return result;
  }

  void dispose() {
    _recognizer?.free();
    _recognizer = null;
  }
}
