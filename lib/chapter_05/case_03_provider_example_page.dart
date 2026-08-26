import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';

// 这个案例只保留两个 provider：
// - providerFilterProvider：保存当前筛选条件。
// - providerVisibleTasksProvider：watch 筛选条件，派生出页面要展示的任务列表。
final providerFilterProvider =
    NotifierProvider<ProviderFilterController, SpellTaskFilter>(
      ProviderFilterController.new,
    );

// 普通 Provider 适合放派生逻辑。
// filter 变化时，这里会重新执行；Widget 只 watch 最终的 visibleTasks。
final providerVisibleTasksProvider = Provider<List<SpellTaskItem>>((ref) {
  final filter = ref.watch(providerFilterProvider);
  return filterTasks(initialSpellTasks, filter);
});

class ProviderFilterController extends Notifier<SpellTaskFilter> {
  @override
  SpellTaskFilter build() {
    return SpellTaskFilter.all;
  }

  void setFilter(SpellTaskFilter filter) {
    // 修改筛选条件后，依赖它的 providerVisibleTasksProvider 会重新计算。
    state = filter;
  }
}

class ProviderExamplePage extends ConsumerWidget {
  const ProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch 既读取当前值，也建立订阅。
    // currentFilter 用于按钮选中态；tasks 是派生后的可见任务列表。
    final currentFilter = ref.watch(providerFilterProvider);
    final tasks = ref.watch(providerVisibleTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('03 Provider 派生数据')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Provider 可以 watch 另一个 provider，把原始状态派生成 UI 需要的数据。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final filter in SpellTaskFilter.values)
                  FilterChip(
                    label: Text(filter.label),
                    selected: currentFilter == filter,
                    onSelected: (_) {
                      // 事件回调里只需要“拿到 controller 并调用方法”，所以用 read。
                      // 如果这里用 watch，会让按钮构建逻辑多一个不必要的订阅关系。
                      ref
                          .read(providerFilterProvider.notifier)
                          .setFilter(filter);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            for (final task in tasks) ...[
              ListTile(
                title: Text(task.prompt),
                subtitle: Text(task.status.label),
              ),
              const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}
