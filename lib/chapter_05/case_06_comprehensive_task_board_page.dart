import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';

// 筛选条件是一个很小的全局状态：all / active / done。
// 用 NotifierProvider 是为了让 UI 通过 controller 暴露的 setFilter 修改它。
final taskFilterProvider =
    NotifierProvider<TaskFilterController, SpellTaskFilter>(
      TaskFilterController.new,
    );

class TaskFilterController extends Notifier<SpellTaskFilter> {
  // build() 返回 provider 的初始状态；这里默认展示全部任务。
  @override
  SpellTaskFilter build() {
    return SpellTaskFilter.all;
  }

  void setFilter(SpellTaskFilter filter) {
    // 改 state 后，watch taskFilterProvider 的 Widget 和派生 provider 都会重新计算。
    state = filter;
  }
}

// Provider 可以只做“派生数据”，不自己持有可变状态。
// summary 依赖任务列表；任务列表变化时，统计结果自动重新计算。
final taskSummaryProvider = Provider<TaskSummary>((ref) {
  final tasks = ref.watch(spellTaskListProvider);
  return summarizeTasks(tasks);
});

// filteredTasks 同时依赖筛选条件和任务列表。
// 任一输入变化，当前可见任务都会自动重新计算。
final filteredTasksProvider = Provider<List<SpellTaskItem>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(spellTaskListProvider);
  return filterTasks(tasks, filter);
});

// 任务列表是真正会被用户动作修改的主状态。
// 页面新增任务、标记完成，都应该进入这个 controller，而不是散落在 Widget 里。
final spellTaskListProvider =
    NotifierProvider<SpellTaskListController, List<SpellTaskItem>>(
      SpellTaskListController.new,
    );

class SpellTaskListController extends Notifier<List<SpellTaskItem>> {
  int _nextId = 4;

  // 初始任务来自 task_models.dart，方便把数据模型和状态管理示例分开看。
  @override
  List<SpellTaskItem> build() {
    return initialSpellTasks;
  }

  void addDemoTask() {
    final id = _nextId.toString().padLeft(3, '0');
    _nextId++;

    // 新任务放在列表最前面，同时返回一个全新的 List。
    // 这和前端里 setState([...newItem, ...oldItems]) 的心智模型很接近。
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
    // 用 copyWith 更新目标任务，保持 SpellTaskItem 本身不可变。
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(status: SpellTaskStatus.done)
        else
          task,
    ];
  }
}

class ComprehensiveTaskBoardPage extends ConsumerStatefulWidget {
  const ComprehensiveTaskBoardPage({super.key});

  @override
  ConsumerState<ComprehensiveTaskBoardPage> createState() {
    return _ComprehensiveTaskBoardPageState();
  }
}

class _ComprehensiveTaskBoardPageState
    extends ConsumerState<ComprehensiveTaskBoardPage> {
  @override
  Widget build(BuildContext context) {
    // listen 用来处理“状态变化带来的副作用”，比如弹 SnackBar、打点、导航。
    // 它不会像 watch 一样把返回值拿来渲染 UI。
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

    // watch 用来读取会参与 UI 渲染的数据。
    // 这里分别订阅统计、当前筛选条件、筛选后的任务列表。
    final summary = ref.watch(taskSummaryProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('06 综合任务看板')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StateIntro(summary: summary),
            const SizedBox(height: 16),
            _FilterBar(currentFilter: currentFilter),
            const SizedBox(height: 16),
            _TaskList(tasks: tasks),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 按钮事件只触发动作，不需要因为读取 controller 而重建，所以用 read。
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
              // FilterChip 只告诉 controller 用户选了哪个 filter。
              // 真正的筛选列表由 filteredTasksProvider 自动派生。
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
                  // 行组件只提交 task.id；列表如何更新由 Notifier 统一决定。
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
