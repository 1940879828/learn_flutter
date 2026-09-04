import 'package:video_player/video_player.dart';

// 视频控制器工厂：根据视频 URL 异步创建一个尚未初始化的控制器。
abstract interface class VideoControllerFactory {
  Future<VideoPlayerController> create(String videoUrl);
}

final class NetworkVideoControllerFactory implements VideoControllerFactory {
  const NetworkVideoControllerFactory();

  @override
  Future<VideoPlayerController> create(String videoUrl) async {
    return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  }
}