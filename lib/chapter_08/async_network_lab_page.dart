import 'package:flutter/material.dart';

import '../learning_navigation_controls.dart';
import 'spell_api_client.dart';
import 'spell_generation_models.dart';
import 'spell_task_repository.dart';

class AsyncNetworkLabPage extends StatefulWidget {
  const AsyncNetworkLabPage({super.key});

  @override
  State<AsyncNetworkLabPage> createState() => _AsyncNetworkLabPageState();
}

class _AsyncNetworkLabPageState extends State<AsyncNetworkLabPage> {
  late final FakeSpellApiClient _client;
  late final SpellTaskRepository _repository;
  SpellTaskResult _result = const SpellTaskLoading();
  bool _nextRequestShouldFail = false;
  int _requestSerial = 0;

  @override
  void initState() {
    super.initState();
    _client = FakeSpellApiClient();
    _repository = SpellTaskRepository(_client);
    _load();
  }

  Future<void> _load({bool fail = false}) async {
    final serial = ++_requestSerial;
    setState(() {
      _result = const SpellTaskLoading();
      _nextRequestShouldFail = fail;
    });

    final result = await _repository.loadTasks(fail: fail);
    if (!mounted || serial != _requestSerial) return;

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('08 异步网络数据模型'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '模拟 SpellAI 请求链路',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'ApiClient 模拟 Dio，Repository 负责转换异常，Model 负责 fromJson/toJson，UI 只关心三态。',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _load(),
                  icon: const Icon(Icons.cloud_sync_outlined),
                  label: const Text('重新加载成功'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _load(fail: true),
                  icon: const Icon(Icons.error_outline),
                  label: const Text('模拟错误'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StateBanner(
              text: _nextRequestShouldFail ? '下一次请求：模拟失败' : '下一次请求：模拟成功',
            ),
            const SizedBox(height: 16),
            _ResultView(result: _result),
          ],
        ),
      ),
    );
  }
}

class _StateBanner extends StatelessWidget {
  const _StateBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: Text(text)),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final SpellTaskResult result;

  @override
  Widget build(BuildContext context) {
    return switch (result) {
      SpellTaskLoading() => const _LoadingPanel(),
      SpellTaskFailure(:final message) => _ErrorPanel(message: message),
      SpellTaskSuccess(:final tasks) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('success：共 ${tasks.length} 个任务'),
          const SizedBox(height: 8),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TaskCard(task: task),
            ),
          ),
        ],
      ),
    };
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('loading：正在模拟请求任务列表'),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('error：$message'),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final SpellGenerationTask task;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(task.id.substring(0, 1).toUpperCase()),
        ),
        title: Text(task.prompt),
        subtitle: Text('${task.id} · ${task.status.label}'),
        trailing: const Icon(Icons.data_object_outlined),
      ),
    );
  }
}
