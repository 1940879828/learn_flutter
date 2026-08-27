import 'package:flutter/foundation.dart';

enum RouteLabTaskStatus {
  planned('计划中'),
  running('进行中'),
  done('已完成');

  const RouteLabTaskStatus(this.label);

  final String label;
}

class RouteLabTask {
  const RouteLabTask({
    required this.id,
    required this.title,
    required this.note,
    required this.status,
  });

  final String id;
  final String title;
  final String note;
  final RouteLabTaskStatus status;
}

class RouteLabTaskDraft {
  const RouteLabTaskDraft({required this.title, required this.note});

  final String title;
  final String note;
}

class RouteLabSession extends ChangeNotifier {
  bool get isLoggedIn => _isLoggedIn;
  bool _isLoggedIn = false;

  void login() {
    if (_isLoggedIn) return;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    if (!_isLoggedIn) return;
    _isLoggedIn = false;
    notifyListeners();
  }
}

const routeLabSeedTasks = <RouteLabTask>[
  RouteLabTask(
    id: 'task-101',
    title: '读取 path 参数',
    note: '详情页应该能从 URL path 里拿到 taskId。',
    status: RouteLabTaskStatus.running,
  ),
  RouteLabTask(
    id: 'task-102',
    title: '区分 query 和 extra',
    note: 'query 适合可恢复的字符串状态，extra 适合本次跳转携带的对象。',
    status: RouteLabTaskStatus.planned,
  ),
  RouteLabTask(
    id: 'task-103',
    title: '用返回值更新列表',
    note: '创建页 pop(result) 后，列表页接收结果并追加任务。',
    status: RouteLabTaskStatus.done,
  ),
];
