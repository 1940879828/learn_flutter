import 'package:flutter/material.dart';
import 'package:learn_flutter/chapter_16/player/video_player_section.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  static const _videoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VideoPlayerSection(videoUrl: _videoUrl),
            Expanded(
              child: ListView(
                children: const [ListTile(title: Text('content'))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

