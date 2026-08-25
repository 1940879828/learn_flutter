import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';
import 'task_repository.dart';

final futureTasksProvider = FutureProvider<List<SpellTaskItem>>((ref) {
  final repository = ref.watch(spellTaskRepositoryProvider);
  return repository.fetchTasks();
});

class FutureProviderExamplePage extends ConsumerWidget {
  const FutureProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(futureTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('04 FutureProvider')),
      body: SafeArea(
        child: asyncTasks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _FutureErrorView(error: error),
          data: (tasks) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'FutureProvider 适合一次性加载远程数据，AsyncValue 帮你拆出 loading、error、data。',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              for (final task in tasks) ...[
                ListTile(
                  title: Text(task.prompt),
                  subtitle: Text('${task.id} · ${task.status.label}'),
                ),
                const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.invalidate(futureTasksProvider);
        },
        icon: const Icon(Icons.refresh),
        label: const Text('重新请求'),
      ),
    );
  }
}

class _FutureErrorView extends ConsumerWidget {
  const _FutureErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('请求失败：$error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                ref.invalidate(futureTasksProvider);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
