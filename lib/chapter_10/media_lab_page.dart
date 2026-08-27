import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../learning_navigation_controls.dart';
import 'media_models.dart';

class MediaLabPage extends StatefulWidget {
  const MediaLabPage({super.key});

  @override
  State<MediaLabPage> createState() => _MediaLabPageState();
}

class _MediaLabPageState extends State<MediaLabPage> {
  late final FakeVideoController _videoController;
  MediaSourceKind _selectedSource = MediaSourceKind.asset;
  bool _showLocalPreview = false;

  @override
  void initState() {
    super.initState();
    _videoController = FakeVideoController();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final initialize = _videoController.initialize();
    setState(() {});
    await initialize;
    if (!mounted) return;
    setState(() {});
  }

  void _play() {
    setState(() {
      _videoController.play();
    });
  }

  void _pause() {
    setState(() {
      _videoController.pause();
    });
  }

  void _selectSource(MediaSourceKind source) {
    setState(() {
      _selectedSource = source;
    });
  }

  void _togglePreview() {
    setState(() {
      _showLocalPreview = !_showLocalPreview;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('10 音视频与媒体能力'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('媒体来源与生命周期', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              '这个 demo 不接真实播放器，先把 asset/network/file 和 controller 生命周期跑顺。',
            ),
            const SizedBox(height: 16),
            _SourceSelector(
              selected: _selectedSource,
              onSelected: _selectSource,
            ),
            const SizedBox(height: 12),
            _SourceDescription(source: _selectedSource),
            const SizedBox(height: 16),
            Text('图片预览 demo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _ImagePreview(showLocalPreview: _showLocalPreview),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _togglePreview,
              icon: const Icon(Icons.image_outlined),
              label: Text(_showLocalPreview ? '切回 asset 预览' : '模拟选择 file 图片'),
            ),
            const SizedBox(height: 16),
            Text(
              '视频 controller 生命周期',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _VideoLifecyclePanel(controller: _videoController),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _initializeVideo,
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('initialize'),
                ),
                OutlinedButton.icon(
                  onPressed: _play,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('play'),
                ),
                OutlinedButton.icon(
                  onPressed: _pause,
                  icon: const Icon(Icons.pause),
                  label: const Text('pause'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceSelector extends StatelessWidget {
  const _SourceSelector({required this.selected, required this.onSelected});

  final MediaSourceKind selected;
  final ValueChanged<MediaSourceKind> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MediaSourceKind.values.map((source) {
        return ChoiceChip(
          selected: selected == source,
          label: Text(source.label),
          onSelected: (_) => onSelected(source),
        );
      }).toList(),
    );
  }
}

class _SourceDescription extends StatelessWidget {
  const _SourceDescription({required this.source});

  final MediaSourceKind source;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: const Icon(Icons.perm_media_outlined),
        title: Text('当前来源：${source.label}'),
        subtitle: Text(source.description),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.showLocalPreview});

  final bool showLocalPreview;

  static final Uint8List _assetImageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=',
  );

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Image.memory(
                _assetImageBytes,
                width: showLocalPreview ? 160 : 96,
                height: showLocalPreview ? 160 : 96,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  showLocalPreview ? 'file 图片预览' : 'asset 图片预览',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoLifecyclePanel extends StatelessWidget {
  const _VideoLifecyclePanel({required this.controller});

  final FakeVideoController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态：${controller.status.label}'),
            const SizedBox(height: 8),
            ...controller.lifecycleLogs.reversed.take(5).map(Text.new),
          ],
        ),
      ),
    );
  }
}
