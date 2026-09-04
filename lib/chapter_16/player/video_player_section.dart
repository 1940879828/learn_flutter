import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'controls/video_controls.dart';

// 视频区域
class VideoPlayerSection extends StatefulWidget {
  const VideoPlayerSection({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<StatefulWidget> createState() => _VideoPlayerSectionState();
}

class _VideoPlayerSectionState extends State<VideoPlayerSection> {
  late final VideoPlayerController _controller;
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _ready = _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.play();
    });
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

        if (snapshot.hasError) {
          videoContent = const Center(child: Text('视频加载或播放失败'));
        } else if (snapshot.connectionState != ConnectionState.done) {
          videoContent = const Center(child: CircularProgressIndicator());
        } else {
          videoContent = VideoPlayer(_controller);
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
              if (isReady)
                VideoControls(
                  controller: _controller,
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
    _controller.dispose();
    super.dispose();
  }
}
