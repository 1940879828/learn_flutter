import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';

// 这个 provider 是“状态入口”：
// - UI 用 ref.watch(notifierTaskListProvider) 订阅任务列表。
// - UI 用 ref.read(notifierTaskListProvider.notifier) 拿到 controller。
// - controller 负责改 state，Widget 只负责显示和触发动作。
final notifierTaskListProvider =
    NotifierProvider<NotifierTaskListController, List<SpellTaskItem>>(
      NotifierTaskListController.new,
    );

// Notifier 可以理解成 Riverpod 版的“状态 controller”。
// 泛型 List<SpellTaskItem> 表示这个 controller 管理的 state 类型是任务列表。
class NotifierTaskListController extends Notifier<List<SpellTaskItem>> {
  int _nextId = 4;

  // build() 是 provider 第一次被读取时的初始化入口。
  // 这里返回的值，会成为 notifierTaskListProvider 暴露给 UI 的初始 state。
  @override
  List<SpellTaskItem> build() {
    return initialSpellTasks;
  }

  void addTask() {
    final id = _nextId.toString().padLeft(3, '0');
    _nextId++;

    // Notifier 里不调用 setState。
    // 只要给 state 赋一个新的值，所有 watch 这个 provider 的 Widget 就会自动重建。
    // 这里用新 List，而不是在原 List 上 add，是为了保持状态不可变，减少隐蔽副作用。
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
    // 这里用 for collection 生成一个新列表：
    // 找到目标任务就 copyWith 成 done，其它任务原样保留。
    // 这和前端里用 map 返回新数组的心智很像。
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
    // watch = 订阅状态。
    // 只要 NotifierTaskListController 里 state 变了，这个 build 会重新执行。
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
          // read = 只在这次点击里读取一次，不订阅重建。
          // 按钮事件里通常用 read 去调用 controller 方法。
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

  // task 是父组件传进来的“当前行数据”。
  // 它不是全局状态本身，只是这次 build 时从 provider state 拆出来的一项。
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
                  // 子组件不直接改 task。
                  // 它只把 task.id 交给 Notifier，由 Notifier 统一修改列表状态。
                  ref.read(notifierTaskListProvider.notifier).markDone(task.id);
                },
              ),
      ),
    );
  }
}
