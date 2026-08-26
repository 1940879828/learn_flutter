import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_models.dart';

final spellTaskRepositoryProvider = Provider<SpellTaskRepository>((ref) {
  return FakeSpellTaskRepository();
});

abstract class SpellTaskRepository {
  Future<List<SpellTaskItem>> fetchTasks({bool shouldFail = false});
}

class FakeSpellTaskRepository implements SpellTaskRepository {
  int _requestCount = 0;

  @override
  Future<List<SpellTaskItem>> fetchTasks({bool shouldFail = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 3000));

    if (shouldFail) {
      throw Exception('模拟接口失败：服务器暂时不可用');
    }

    _requestCount++;

    return [
      ...initialSpellTasks,
      SpellTaskItem(
        id: 'remote_${_requestCount.toString().padLeft(3, '0')}',
        prompt: 'repository 第 $_requestCount 次返回的远程任务',
        status: SpellTaskStatus.waiting,
      ),
    ];
  }
}
