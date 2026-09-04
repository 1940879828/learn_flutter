import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'controls/video_controls.dart';

// 视频区域
class VideoPlayerSection extends StatefulWidget {
  const VideoPlayerSection({super.key,required this.videoUrl});

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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(aspectRatio: 16 / 9, child: videoContent),
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError)
              VideoControls(controller: _controller),
          ],
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

