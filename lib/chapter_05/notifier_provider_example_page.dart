import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';

final notifierTaskListProvider =
    NotifierProvider<NotifierTaskListController, List<SpellTaskItem>>(
      NotifierTaskListController.new,
    );

class NotifierTaskListController extends Notifier<List<SpellTaskItem>> {
  int _nextId = 4;

  @override
  List<SpellTaskItem> build() {
    return initialSpellTasks;
  }

  void addTask() {
    final id = _nextId.toString().padLeft(3, '0');
    _nextId++;

    state = [
      SpellTaskItem(
        id: 'notifier_$id',
        prompt: 'NotifierProvider 新任务 $id',
        status: SpellTaskStatus.waiting,
      ),
      ...state,
    ];
  }

  void markDone(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(status: SpellTaskStatus.done)
        else
          task,
    ];
  }
}

class NotifierProviderExamplePage extends ConsumerWidget {
  const NotifierProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(notifierTaskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('02 NotifierProvider')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Widget 只负责显示；新增和完成任务的逻辑放在 Notifier 里。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            for (final task in tasks) ...[
              _NotifierTaskTile(task: task),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(notifierTaskListProvider.notifier).addTask();
        },
        icon: const Icon(Icons.add),
        label: const Text('Notifier 新增'),
      ),
    );
  }
}

class _NotifierTaskTile extends ConsumerWidget {
  const _NotifierTaskTile({required this.task});

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
                tooltip: '标记完成',
                icon: const Icon(Icons.done),
                onPressed: () {
                  ref.read(notifierTaskListProvider.notifier).markDone(task.id);
                },
              ),
      ),
    );
  }
}
