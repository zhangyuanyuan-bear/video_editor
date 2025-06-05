import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ExportService {
  static String formatSecondsToTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static Future<void> exportVideoWithFFmpeg(
      {required String inputPath, required int startTime}) async {
    final outputPath = await getTemporaryVideoPath();
    debugPrint('outputPath === $outputPath');
    final formattedStartTime = formatSecondsToTime(startTime);
    const duration = '5'; // 持续时间 (秒)

    final command = '-i $inputPath -ss $formattedStartTime -t $duration -c copy $outputPath';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('视频裁剪成功');
        await ImageGallerySaver.saveFile(outputPath);
      } else if (ReturnCode.isCancel(returnCode)) {
        debugPrint('操作取消');
      } else {
        debugPrint('视频裁剪失败');
      }
    });
  }

  static Future<void> exportImageWithFFmpeg(
      {required String inputPath, required double timestampSeconds}) async {
    final outputPath = await getTemporaryImagePath();
    debugPrint('outputPath === $outputPath');

    final command = '-i $inputPath -ss $timestampSeconds -vframes 1 -c:v mjpeg -q:v 2 $outputPath';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('视频裁剪成功');
        await ImageGallerySaver.saveFile(outputPath);
      } else if (ReturnCode.isCancel(returnCode)) {
        debugPrint('操作取消');
      } else {
        debugPrint('视频裁剪失败');
      }
    });
  }

  static Future<String> getTemporaryVideoPath() async {
    // 获取临时目录
    final tempDir = await getTemporaryDirectory();

    // 生成唯一的文件名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'trimmed_video_$timestamp.mp4';

    // 组合完整路径
    return path.join(tempDir.path, fileName);
  }

  static Future<String> getTemporaryImagePath() async {
    // 获取临时目录
    final tempDir = await getTemporaryDirectory();

    // 生成唯一的文件名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'trimmed_image_$timestamp.jpeg';

    // 组合完整路径
    return path.join(tempDir.path, fileName);
  }
}
