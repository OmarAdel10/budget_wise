import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'stt_constants.dart';

class SttDownloadManager {
  static const String taskName = "stt_model_download";

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> startDownload() async {
    await Workmanager().registerOneOffTask(
      "stt_download_unique",
      taskName,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<bool> checkFilesExist() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = [
      SttConstants.encoderFile,
      SttConstants.decoderFile,
      SttConstants.tokensFile,
    ];
    for (var file in files) {
      final f = File('${dir.path}/$file');
      if (!await f.exists()) return false;
    }
    return true;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == SttDownloadManager.taskName) {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();

      try {
        for (var file in [
          SttConstants.encoderFile,
          SttConstants.decoderFile,
          SttConstants.tokensFile,
        ]) {
          await dio.download(
            '${SttConstants.modelBaseUrl}/$file',
            '${dir.path}/$file',
          );
        }
        await prefs.setBool(SttConstants.prefModelReady, true);
        return true;
      } catch (e) {
        return false;
      }
    }
    return true;
  });
}
