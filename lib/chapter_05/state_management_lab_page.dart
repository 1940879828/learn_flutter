import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SpellTaskStatus {
  waiting('等待中'),
  running('生成中'),
  done('已完成');

  const SpellTaskStatus(this.label);

  final String label;
}

enum SpellTaskFilter {
  all('全部'),
  active('进行中'),
  done('已完成');

  const SpellTaskFilter(this.label);

  final String label;
}

class SpellTaskItem {
  const SpellTaskItem({
    required this.id,
    required this.prompt,
    required this.status,
  });

  final String id;
  final String prompt;
  final SpellTaskStatus status;

  bool get isDone => status == SpellTaskStatus.done;

  SpellTaskItem copyWith({SpellTaskStatus? status}) {
    return SpellTaskItem(id: id, prompt: prompt, status: status ?? this.status);
  }
}

class TaskSummary {
  const TaskSummary({
    required this.total,
    required this.active,
    required this.done,
  });

  final int total;
  final int active;
  final int done;
}

final taskFilterProvider =
    NotifierProvider<TaskFilterController, SpellTaskFilter>(
      TaskFilterController.new,
    );

class TaskFilterController extends Notifier<SpellTaskFilter> {
  @override
  SpellTaskFilter build() {
    return SpellTaskFilter.all;
  }

  void setFilter(SpellTaskFilter filter) {
    state = filter;
  }
}

final taskSummaryProvider = Provider<TaskSummary>((ref) {
  final tasks = ref.watch(spellTaskListProvider);
  final done = tasks.where((task) => task.isDone).length;

  return TaskSummary(
    total: tasks.length,
    active: tasks.length - done,
    done: done,
  );
});

final remoteHintProvider = FutureProvider<String>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 120));
  return 'FutureProvider：模拟从远端加载任务配置';
});

final filteredTasksProvider = Provider<List<SpellTaskItem>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(spellTaskListProvider);

  switch (filter) {
    case SpellTaskFilter.all:
      return tasks;
    case SpellTaskFilter.active:
      return tasks.where((task) => !task.isDone).toList();
    case SpellTaskFilter.done:
      return tasks.where((task) => task.isDone).toList();
  }
});

final spellTaskListProvider =
    NotifierProvider<SpellTaskListController, List<SpellTaskItem>>(
      SpellTaskListController.new,
    );

class SpellTaskListController extends Notifier<List<SpellTaskItem>> {
  int _nextId = 4;

  @override
  List<SpellTaskItem> build() {
    return const [
      SpellTaskItem(
        id: 'task_001',
        prompt: '生成一张魔法卡片封面',
        status: SpellTaskStatus.done,
      ),
      SpellTaskItem(
        id: 'task_002',
        prompt: '把图片转成 4 秒短视频',
        status: SpellTaskStatus.running,
      ),
      SpellTaskItem(
        id: 'task_003',
        prompt: '给角色生成头像变体',
        status: SpellTaskStatus.waiting,
      ),
    ];
  }

  void addDemoTask() {
    final id = _nextId.toString().padLeft(3, '0');
    _nextId++;

    state = [
      SpellTaskItem(
        id: 'task_$id',
        prompt: '新建的 Riverpod 练习任务 $id',
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

class StateManagementLabPage extends ConsumerStatefulWidget {
  const StateManagementLabPage({super.key});

  @override
  ConsumerState<StateManagementLabPage> createState() {
    return _StateManagementLabPageState();
  }
}

class _StateManagementLabPageState
    extends ConsumerState<StateManagementLabPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen<SpellTaskFilter>(taskFilterProvider, (previous, next) {
      if (previous == null || previous == next) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('listen：筛选条件切换为「${next.label}」'),
          duration: const Duration(milliseconds: 900),
        ),
      );
    });

    final summary = ref.watch(taskSummaryProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('05 状态管理与 Riverpod')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StateIntro(summary: summary),
            const SizedBox(height: 16),
            const _RemoteHintCard(),
            const SizedBox(height: 16),
            _FilterBar(currentFilter: currentFilter),
            const SizedBox(height: 16),
            _TaskList(tasks: tasks),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(spellTaskListProvider.notifier).addDemoTask();
        },
        icon: const Icon(Icons.add),
        label: const Text('新增任务'),
      ),
    );
  }
}

class _StateIntro extends StatelessWidget {
  const _StateIntro({required this.summary});

  final TaskSummary summary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('任务状态看板', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'watch：页面订阅任务列表和筛选条件；read：按钮点击时修改状态；listen：筛选变化时弹 SnackBar。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(label: '全部', count: summary.total),
                _SummaryChip(label: '进行中', count: summary.active),
                _SummaryChip(label: '已完成', count: summary.done),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoteHintCard extends ConsumerWidget {
  const _RemoteHintCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hint = ref.watch(remoteHintProvider);

    return Material(
      color: const Color(0xFFE3F2FD),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.cloud_download_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: hint.when(
                data: Text.new,
                error: (error, stackTrace) => Text('远程提示加载失败：$error'),
                loading: () => const Text('FutureProvider：加载中...'),
              ),
            ),
            IconButton(
              tooltip: '刷新远程提示',
              onPressed: () {
                ref.invalidate(remoteHintProvider);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label $count'));
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.currentFilter});

  final SpellTaskFilter currentFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: [
        for (final filter in SpellTaskFilter.values)
          FilterChip(
            label: Text(filter.label),
            selected: currentFilter == filter,
            onSelected: (_) {
              ref.read(taskFilterProvider.notifier).setFilter(filter);
            },
          ),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks});

  final List<SpellTaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const _EmptyTaskView();
    }

    return Column(
      children: [
        for (final task in tasks) ...[
          _TaskTile(task: task),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final SpellTaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (task.status) {
      SpellTaskStatus.waiting => Colors.blueGrey,
      SpellTaskStatus.running => Colors.orange,
      SpellTaskStatus.done => Colors.green,
    };

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.16),
          child: Icon(Icons.auto_awesome, color: statusColor),
        ),
        title: Text(task.prompt),
        subtitle: Text('${task.id} · ${task.status.label}'),
        trailing: task.isDone
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                tooltip: '标记完成',
                icon: const Icon(Icons.done),
                onPressed: () {
                  ref.read(spellTaskListProvider.notifier).markDone(task.id);
                },
              ),
      ),
    );
  }
}

class _EmptyTaskView extends StatelessWidget {
  const _EmptyTaskView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Text('当前筛选下没有任务')),
    );
  }
}
