import 'dart:io';

import 'package:flutter/material.dart';

import '../learning_navigation_controls.dart';
import 'local_storage_models.dart';

class LocalStorageLabPage extends StatefulWidget {
  const LocalStorageLabPage({super.key});

  @override
  State<LocalStorageLabPage> createState() => _LocalStorageLabPageState();
}

class _LocalStorageLabPageState extends State<LocalStorageLabPage> {
  final TextEditingController _promptController = TextEditingController(
    text: 'A glowing spell book on a desk',
  );
  final FakePromptPreferences _preferences = FakePromptPreferences();
  final JsonPromptFileStore _fileStore = JsonPromptFileStore();
  final List<PromptRecord> _records = <PromptRecord>[];

  MockPermissionState _permission = MockPermissionState.notDetermined;
  String _recentPrompt = '还没有保存 prompt';
  File? _lastFile;
  int _loadedRecordCount = 0;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveRecentPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    await _preferences.saveRecentPrompt(prompt);
    final recentPrompt = await _preferences.readRecentPrompt();
    if (!mounted) return;

    setState(() {
      _recentPrompt = recentPrompt ?? '还没有保存 prompt';
      _records.insert(
        0,
        PromptRecord(
          id: 'prompt_${_records.length + 1}',
          prompt: prompt,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _writeJsonFile() async {
    if (_records.isEmpty) {
      await _saveRecentPrompt();
    }

    final file = await _fileStore.writeRecords(_records);
    final loaded = await _fileStore.readRecords(file);
    if (!mounted) return;

    setState(() {
      _lastFile = file;
      _loadedRecordCount = loaded.length;
    });
  }

  void _setPermission(MockPermissionState permission) {
    setState(() {
      _permission = permission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('09 本地存储权限与文件'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('本地能力拆成三块', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              '轻量配置像 shared_preferences，结构化记录可进 sqflite，图片/视频结果要落到文件和相册链路。',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '最近一次 prompt',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _saveRecentPrompt,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('保存最近 prompt'),
                ),
                OutlinedButton.icon(
                  onPressed: _writeJsonFile,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('写入本地 JSON 文件'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: '最近 prompt',
              body: _recentPrompt,
              icon: Icons.tune_outlined,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'JSON 文件',
              body: _lastFile == null
                  ? '尚未写入'
                  : '${_lastFile!.path}\n已读回 $_loadedRecordCount 条记录',
              icon: Icons.folder_outlined,
            ),
            const SizedBox(height: 16),
            Text('模拟相册权限状态', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MockPermissionState.values.map((permission) {
                return ChoiceChip(
                  selected: _permission == permission,
                  label: Text(permission.label),
                  onSelected: (_) => _setPermission(permission),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _PermissionPanel(permission: _permission),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(body),
      ),
    );
  }
}

class _PermissionPanel extends StatelessWidget {
  const _PermissionPanel({required this.permission});

  final MockPermissionState permission;

  @override
  Widget build(BuildContext context) {
    final icon = switch (permission) {
      MockPermissionState.granted => Icons.check_circle_outline,
      MockPermissionState.limited => Icons.photo_library_outlined,
      MockPermissionState.denied => Icons.block_outlined,
      MockPermissionState.notDetermined => Icons.help_outline,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前状态：${permission.label}'),
                  const SizedBox(height: 4),
                  Text(permission.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
