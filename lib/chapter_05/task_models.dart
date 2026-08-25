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

TaskSummary summarizeTasks(List<SpellTaskItem> tasks) {
  final done = tasks.where((task) => task.isDone).length;

  return TaskSummary(
    total: tasks.length,
    active: tasks.length - done,
    done: done,
  );
}

List<SpellTaskItem> filterTasks(
  List<SpellTaskItem> tasks,
  SpellTaskFilter filter,
) {
  switch (filter) {
    case SpellTaskFilter.all:
      return tasks;
    case SpellTaskFilter.active:
      return tasks.where((task) => !task.isDone).toList();
    case SpellTaskFilter.done:
      return tasks.where((task) => task.isDone).toList();
  }
}

const initialSpellTasks = [
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
