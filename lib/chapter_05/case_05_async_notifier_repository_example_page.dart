import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';
import 'task_repository.dart';

// AsyncNotifierProvider = “异步数据 + 用户动作”的统一入口。
// 对比 FutureProvider：FutureProvider 更像只读请求；AsyncNotifier 可以额外暴露 reload、loadError、markDone 这类动作。
final asyncRepositoryTasksProvider =
    AsyncNotifierProvider<AsyncRepositoryTaskController, List<SpellTaskItem>>(
      AsyncRepositoryTaskController.new,
    );

// AsyncNotifier 管理的 state 类型是 AsyncValue<List<SpellTaskItem>>。
// 所以 controller 内部既可以进入 loading，也可以保存成功数据或错误。
class AsyncRepositoryTaskController extends AsyncNotifier<List<SpellTaskItem>> {
  // build() 是初次读取 provider 时的异步初始化入口。
  // 返回 Future<List<...>> 后，Riverpod 会自动把它包成 AsyncLoading / AsyncData / AsyncError。
  @override
  Future<List<SpellTaskItem>> build() {
    return ref.watch(spellTaskRepositoryProvider).fetchTasks();
  }

  Future<void> reload() async {
    // 用户主动刷新时，先把 state 切回 loading，让 UI 有明确反馈。
    state = const AsyncLoading();
    // AsyncValue.guard 会把成功值包装成 AsyncData，把异常包装成 AsyncError。
    // 这样 controller 不需要手写 try/catch 分支。
    state = await AsyncValue.guard(() {
      return ref.read(spellTaskRepositoryProvider).fetchTasks();
    });
  }

  Future<void> loadError() async {
    state = const AsyncLoading();
    // 这里故意请求失败，用来观察 AsyncError 如何流向 UI。
    state = await AsyncValue.guard(() {
      return ref.read(spellTaskRepositoryProvider).fetchTasks(shouldFail: true);
    });
  }

  void markFirstActiveDone() {
    // 修改列表前，先只从 data 分支取当前任务。
    // loading/error 状态下没有可安全修改的列表，所以返回 null 并提前结束。
    final currentTasks = state.when(
      data: (tasks) => tasks,
      error: (error, stackTrace) => null,
      loading: () => null,
    );

    if (currentTasks == null) {
      return;
    }

    // 这里仍然创建新 List、新 task，而不是原地修改。
    // Riverpod 和前端状态管理一样，更推荐不可变更新，重建边界更清楚。
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
    // watch 到的是 AsyncValue，所以页面仍然用 when 分别渲染 loading/error/data。
    // 差别在于：用户动作会通过 notifier 方法改变这个 AsyncValue。
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
              // 点击事件只调用 controller 方法，不需要订阅 provider，所以用 read。
              ref.read(asyncRepositoryTasksProvider.notifier).loadError();
            },
            child: const Icon(Icons.error_outline),
          ),
          FloatingActionButton.extended(
            heroTag: 'async_reload',
            onPressed: () {
              // reload 内部会先切 loading，再通过 repository 重新拿数据。
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
                  // 子组件不直接改 task；它把动作交给 AsyncNotifier 统一处理。
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
                // 错误视图也通过同一个 controller 入口恢复数据。
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
