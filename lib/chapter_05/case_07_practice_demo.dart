import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final challengeFilterProvider =
    NotifierProvider<ChallengeFilterController, String>(
      ChallengeFilterController.new,
    );

class ChallengeFilterController extends Notifier<String> {
  @override
  String build() {
    return '全部';
  }

  void toggle() {
    state = state == '全部' ? '进行中' : '全部';
  }
}

// ===
class ChallengeTask {
  const ChallengeTask({required this.title, required this.status});
  final String title;
  final String status;
}

final challengeTasksProvider = FutureProvider.autoDispose<List<ChallengeTask>>((
  ref,
) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  return const [
    ChallengeTask(title: '1', status: '进行中'),
    ChallengeTask(title: '2', status: '已完成'),
    ChallengeTask(title: '3', status: '进行中'),
  ];
});

final filteredChallengeTasksProvider =
    Provider<AsyncValue<List<ChallengeTask>>>((ref) {
      final currentFilter = ref.watch(challengeFilterProvider);
      final tasksAsync = ref.watch(challengeTaskListProvider);
      return tasksAsync.whenData((tasks) {
        if (currentFilter == '全部') {
          return tasks;
        }
        return tasks.where((task) => task.status == currentFilter).toList();
      });
    });
// ====

class ChallengeTaskRepository {
  Future<List<ChallengeTask>> fetchTasks({bool shouldFail = false}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (shouldFail) {
      throw Exception('模拟加载失败');
    }
    return const [
      ChallengeTask(title: '1', status: '进行中'),
      ChallengeTask(title: '2', status: '已完成'),
      ChallengeTask(title: '3', status: '进行中'),
    ];
  }
}

final challengeTaskRepositoryProvider = Provider<ChallengeTaskRepository>((
  ref,
) {
  return ChallengeTaskRepository();
});

final challengeTaskListProvider =
    AsyncNotifierProvider<ChallengeTaskListController, List<ChallengeTask>>(
      ChallengeTaskListController.new,
    );

class ChallengeTaskListController extends AsyncNotifier<List<ChallengeTask>> {
  @override
  Future<List<ChallengeTask>> build() async {
    final repository = ref.watch(challengeTaskRepositoryProvider);
    return repository.fetchTasks();
  }

  Future<void> reload() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeTaskRepositoryProvider);
      return repository.fetchTasks();
    });
  }

  void addLocalTask() {
    final currentTask = state.value ?? const <ChallengeTask>[];

    state = AsyncData([
      ...currentTask,
      const ChallengeTask(title: '新任务', status: '进行中'),
    ]);
  }

  Future<void> loadError() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeTaskRepositoryProvider);
      return repository.fetchTasks(shouldFail: true);
    });
  }
}

class Case07PracticeDemo extends ConsumerWidget {
  const Case07PracticeDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(challengeFilterProvider);
    final taskAsync = ref.watch(filteredChallengeTasksProvider);

    ref.listen(challengeTaskListProvider, (prev,next){
      final wasError = prev?.hasError ?? false;
      final isError = next.hasError;

      if (!wasError && isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('任务加载失败: ${next.error}'))
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('局部状态')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前筛选：$currentFilter'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(challengeFilterProvider.notifier).toggle();
                  },
                  child: const Text('切换筛选'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(challengeTaskListProvider.notifier).addLocalTask();
                  },
                  child: const Text('新增任务'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(challengeTaskListProvider.notifier).loadError();
                  },
                  child: const Text('模拟失败'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(challengeTaskListProvider.notifier).reload();
                  },
                  child: const Text('刷新任务'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            taskAsync.when(
              skipLoadingOnRefresh: false,
              data: (List<ChallengeTask> tasks) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('任务数量 ${tasks.length}'),
                    const SizedBox(height: 12),
                    for (final task in tasks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('${task.title} / ${task.status}'),
                      ),
                  ],
                );
              },
              error: (Object error, StackTrace stackTrace) {
                return Text('加载失败 $error');
              },
              loading: () {
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
