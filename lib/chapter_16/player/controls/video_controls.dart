import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// 视频控制器
class VideoControls extends StatelessWidget {
  const VideoControls({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return _PlayPauseButton(controller: controller);
  }
}

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();

    _isPlaying = widget.controller.value.isPlaying;
    // 监听控制器状态变化
    widget.controller.addListener(_syncPlaybackState);
  }

  // 同步视频控制器里的 isPlaying 状态
  void _syncPlaybackState() {
    // 拿到变化的控制器的 isPlaying 字段 自己做筛选
    final nextIsPlaying = widget.controller.value.isPlaying;

    // 和现在的状态一样 不修改
    if (_isPlaying == nextIsPlaying) return;

    // 不一样就同步一下状态
    setState(() {
      _isPlaying = nextIsPlaying;
    });
  }

  void _togglePlayback() {
    if (_isPlaying) {
      // 调用控制器的 暂停方法
      widget.controller.pause();
    } else {
      // 调用控制器的 播放方法
      widget.controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _togglePlayback,
      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncPlaybackState);
    super.dispose();
  }
}
