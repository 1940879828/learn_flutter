import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../learning_navigation_controls.dart';
import '../learning_routes.dart';
import 'route_lab_models.dart';

class RouteLabPage extends StatefulWidget {
  const RouteLabPage({required this.session, super.key});

  final RouteLabSession session;

  @override
  State<RouteLabPage> createState() => _RouteLabPageState();
}

class _RouteLabPageState extends State<RouteLabPage> {
  final List<RouteLabTask> _tasks = List<RouteLabTask>.of(routeLabSeedTasks);
  String _lastResult = '还没有从子页面收到返回值';

  Future<void> _openCreatePage() async {
    final draft = await context.push<RouteLabTaskDraft>(
      LearningRoutes.chapter07Create,
    );
    if (!mounted || draft == null) return;

    final task = RouteLabTask(
      id: 'task-${100 + _tasks.length + 1}',
      title: draft.title,
      note: draft.note,
      status: RouteLabTaskStatus.planned,
    );

    setState(() {
      _tasks.add(task);
      _lastResult = '已从创建页接收返回值：${draft.title}';
    });
  }

  void _openTask(RouteLabTask task) {
    context.push(
      LearningRoutes.taskDetailLocation(task.id, tab: 'notes'),
      extra: task,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('07 路由导航实验室'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'go_router 多页面练习',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('这一页把路由表、path、query、extra、返回值和 redirect 放到一个可跑的小案例里。'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _openCreatePage,
                  icon: const Icon(Icons.add),
                  label: const Text('打开创建页'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      LearningRoutes.searchLocation(keyword: 'riverpod'),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('用 query 搜索'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.session.isLoggedIn
                        ? widget.session.logout()
                        : widget.session.login();
                  },
                  icon: Icon(
                    widget.session.isLoggedIn
                        ? Icons.logout
                        : Icons.login_outlined,
                  ),
                  label: Text(widget.session.isLoggedIn ? '退出登录' : '模拟登录'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RouteStatusCard(
              isLoggedIn: widget.session.isLoggedIn,
              lastResult: _lastResult,
            ),
            const SizedBox(height: 16),
            ..._tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TaskTile(task: task, onTap: () => _openTask(task)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteStatusCard extends StatelessWidget {
  const _RouteStatusCard({required this.isLoggedIn, required this.lastResult});

  final bool isLoggedIn;
  final String lastResult;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('登录状态：${isLoggedIn ? '已登录' : '未登录'}'),
            const SizedBox(height: 6),
            const Text('未登录，详情页会被 redirect 到模拟登录页。'),
            const SizedBox(height: 6),
            Text(lastResult),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onTap});

  final RouteLabTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text('${task.id} · ${task.status.label}'),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
