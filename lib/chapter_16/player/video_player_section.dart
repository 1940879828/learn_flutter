import 'package:flutter/material.dart';
import 'package:learn_flutter/chapter_16/player/source/video_controller_factory.dart';
import 'package:video_player/video_player.dart';

import 'controls/video_controls.dart';

// 视频区域
class VideoPlayerSection extends StatefulWidget {
  const VideoPlayerSection({
    super.key,
    required this.videoUrl,
    this.controllerFactory = const NetworkVideoControllerFactory(),
  });

  final String videoUrl;
  final VideoControllerFactory controllerFactory;

  @override
  State<StatefulWidget> createState() => _VideoPlayerSectionState();
}

class _VideoPlayerSectionState extends State<VideoPlayerSection> {
  VideoPlayerController? _controller;
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    // 异步完成信号
    _ready = _prepareController();
  }

  // 准备播放器控制器直到可以播放
  Future<void> _prepareController() async {
    // 从工厂创建 controller
    final controller = await widget.controllerFactory.create(widget.videoUrl);

    if (!mounted) {
      // 页面不存在了，调用控制器的销毁
      await controller.dispose();
      return;
    }

    // 把 controller 交给当前 State 持有
    _controller = controller;

    // initialize 初始化播放器
    await controller.initialize();

    // 初始化完成后，确认页面还存在
    if (!mounted) return;
    // 调用播放器自动播放
    await controller.play();
  }

  void _openFullscreen() {
    debugPrint('_openFullscreen');
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        Widget videoContent;
        final controller = _controller;

        if (snapshot.hasError) {
          videoContent = const Center(child: Text('视频加载或播放失败'));
        } else if (snapshot.connectionState != ConnectionState.done) {
          videoContent = const Center(child: CircularProgressIndicator());
        } else {
          if (controller == null) {
            videoContent = const Center(child: CircularProgressIndicator());
          } else {
            videoContent = VideoPlayer(controller);
          }
        }

        final isReady =
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError;

        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              videoContent,
              if (isReady && controller != null)
                VideoControls(
                  controller: controller,
                  onFullscreen: _openFullscreen,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
