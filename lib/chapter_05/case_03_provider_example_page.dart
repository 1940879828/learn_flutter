import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';

final providerBaseTasksProvider =
    NotifierProvider<ProviderBaseTasksController, List<SpellTaskItem>>(
      ProviderBaseTasksController.new,
    );

final providerFilterProvider =
    NotifierProvider<ProviderFilterController, SpellTaskFilter>(
      ProviderFilterController.new,
    );

final providerSummaryProvider = Provider<TaskSummary>((ref) {
  final tasks = ref.watch(providerBaseTasksProvider);
  return summarizeTasks(tasks);
});

final providerVisibleTasksProvider = Provider<List<SpellTaskItem>>((ref) {
  final tasks = ref.watch(providerBaseTasksProvider);
  final filter = ref.watch(providerFilterProvider);
  return filterTasks(tasks, filter);
});

final providerSummaryLabelProvider = Provider<String>((ref) {
  final summary = ref.watch(providerSummaryProvider);
  return 'Provider 派生文案：全部 ${summary.total}，进行中 ${summary.active}，已完成 ${summary.done}';
});

class ProviderBaseTasksController extends Notifier<List<SpellTaskItem>> {
  @override
  List<SpellTaskItem> build() {
    return initialSpellTasks;
  }
}

class ProviderFilterController extends Notifier<SpellTaskFilter> {
  @override
  SpellTaskFilter build() {
    return SpellTaskFilter.all;
  }

  void setFilter(SpellTaskFilter filter) {
    state = filter;
  }
}

class ProviderExamplePage extends ConsumerWidget {
  const ProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(providerFilterProvider);
    final tasks = ref.watch(providerVisibleTasksProvider);
    final summaryLabel = ref.watch(providerSummaryLabelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('03 Provider 派生数据')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(summaryLabel, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final filter in SpellTaskFilter.values)
                  FilterChip(
                    label: Text(filter.label),
                    selected: currentFilter == filter,
                    onSelected: (_) {
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
