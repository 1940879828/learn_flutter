import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';
import 'task_repository.dart';

// FutureProvider 适合“读取一次远程/异步数据”的场景。
// 它暴露给 UI 的不是 List 本身，而是 AsyncValue<List<SpellTaskItem>>：
// UI 必须显式处理 loading、error、data 三种状态。
final futureTasksProvider = FutureProvider<List<SpellTaskItem>>((ref) {
  // watch repository provider，表示数据源如果被替换，这个 FutureProvider 也会重新计算。
  final repository = ref.watch(spellTaskRepositoryProvider);
  return repository.fetchTasks();
});

/**
 * 整个 Widget 都要用 ref，且不需要本地 state
    => ConsumerWidget

    整个 Widget 都要用 ref，且还需要本地 state / 生命周期
    => ConsumerStatefulWidget

    只有局部一小块需要用 ref
    => Consumer
 */
class FutureProviderExamplePage extends ConsumerWidget {
  const FutureProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch = 订阅 FutureProvider 的 AsyncValue。
    // 请求中、成功、失败任一状态变化，都会触发当前页面重新 build。
    final asyncTasks = ref.watch(futureTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('04 FutureProvider')),
      body: SafeArea(
        // AsyncValue.when 是 Riverpod 推荐的异步状态分支写法。
        // 和前端常见的 isLoading / error / data 三段判断类似，但状态被统一收口了。
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
          // invalidate 会丢弃 provider 当前缓存。
          // 下一次被 watch 时，FutureProvider 会重新执行 fetchTasks()。
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
                // 错误页里也可以 invalidate 同一个 provider，形成“重试”入口。
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
