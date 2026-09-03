import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  static const _videoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Text("video")
      ),
    );
  }
}