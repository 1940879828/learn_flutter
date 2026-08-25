import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';
import 'task_repository.dart';

final asyncRepositoryTasksProvider =
    AsyncNotifierProvider<AsyncRepositoryTaskController, List<SpellTaskItem>>(
      AsyncRepositoryTaskController.new,
    );

class AsyncRepositoryTaskController extends AsyncNotifier<List<SpellTaskItem>> {
  @override
  Future<List<SpellTaskItem>> build() {
    return ref.watch(spellTaskRepositoryProvider).fetchTasks();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(spellTaskRepositoryProvider).fetchTasks();
    });
  }

  Future<void> loadError() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(spellTaskRepositoryProvider).fetchTasks(shouldFail: true);
    });
  }

  void markFirstActiveDone() {
    final currentTasks = state.when(
      data: (tasks) => tasks,
      error: (error, stackTrace) => null,
      loading: () => null,
    );

    if (currentTasks == null) {
      return;
    }

    state = AsyncData([
      for (final task in currentTasks)
        if (!task.isDone) task.copyWith(status: SpellTaskStatus.done) else task,
    ]);
  }
}

class AsyncNotifierRepositoryExamplePage extends ConsumerWidget {
  const AsyncNotifierRepositoryExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(asyncRepositoryTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('05 AsyncNotifier + repository')),
      body: SafeArea(
        child: asyncTasks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _AsyncErrorView(error: error),
          data: (tasks) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'repository 负责获取数据；AsyncNotifier 负责把 loading、error、data 和用户动作收口。',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              for (final task in tasks) ...[
                _AsyncTaskTile(task: task),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: Wrap(
        spacing: 12,
        children: [
          FloatingActionButton.small(
            heroTag: 'async_error',
            tooltip: '模拟错误',
            onPressed: () {
              ref.read(asyncRepositoryTasksProvider.notifier).loadError();
            },
            child: const Icon(Icons.error_outline),
          ),
          FloatingActionButton.extended(
            heroTag: 'async_reload',
            onPressed: () {
              ref.read(asyncRepositoryTasksProvider.notifier).reload();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }
}

class _AsyncTaskTile extends ConsumerWidget {
  const _AsyncTaskTile({required this.task});

  final SpellTaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        title: Text(task.prompt),
        subtitle: Text('${task.id} · ${task.status.label}'),
        trailing: task.isDone
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                tooltip: '完成第一个未完成任务',
                icon: const Icon(Icons.done),
                onPressed: () {
                  ref
                      .read(asyncRepositoryTasksProvider.notifier)
                      .markFirstActiveDone();
                },
              ),
      ),
    );
  }
}

class _AsyncErrorView extends ConsumerWidget {
  const _AsyncErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('error：$error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                ref.read(asyncRepositoryTasksProvider.notifier).reload();
              },
              child: const Text('从 repository 重新加载'),
            ),
          ],
        ),
      ),
    );
  }
}
