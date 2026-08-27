import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../learning_navigation_controls.dart';
import '../learning_routes.dart';
import 'route_lab_models.dart';

class RouteTaskDetailPage extends StatelessWidget {
  const RouteTaskDetailPage({
    required this.taskId,
    required this.tab,
    required this.extraTask,
    super.key,
  });

  final String taskId;
  final String tab;
  final RouteLabTask? extraTask;

  @override
  Widget build(BuildContext context) {
    final task = extraTask ?? _findTask(taskId);

    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('路由详情页'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '详情：$taskId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(task.title),
            const SizedBox(height: 16),
            _InfoRow(label: 'path 参数 taskId', value: taskId),
            _InfoRow(label: 'query 参数 tab', value: tab),
            _InfoRow(label: 'extra 是否存在', value: extraTask == null ? '否' : '是'),
            const SizedBox(height: 16),
            Text(task.note),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(LearningRoutes.chapter07Lab),
              icon: const Icon(Icons.list_alt),
              label: const Text('回到路由实验室'),
            ),
          ],
        ),
      ),
    );
  }

  RouteLabTask _findTask(String taskId) {
    return routeLabSeedTasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => RouteLabTask(
        id: taskId,
        title: '从 path 恢复的任务',
        note: 'extra 为空时，真实项目通常会用 path id 重新查询数据。',
        status: RouteLabTaskStatus.planned,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
