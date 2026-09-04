import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// 视频控制器
class VideoControls extends StatefulWidget {
  const VideoControls({
    super.key,
    required this.controller,
    required this.onFullscreen,
  });

  final VideoPlayerController controller;

  final VoidCallback onFullscreen;

  @override
  State<StatefulWidget> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _controlsVisible = false;

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controlsVisible) ...[
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 64,
              child: _TopGradient(),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 72,
              child: _BottomGradient(),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 4,
              child: Row(
                children: [
                  _PlayPauseButton(controller: widget.controller),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onFullscreen,
                    style: const ButtonStyle(
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),
                    ),
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
      color: Colors.white,
      style: const ButtonStyle(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncPlaybackState);
    super.dispose();
  }
}

class _TopGradient extends StatelessWidget {
  const _TopGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
    );
  }
}
