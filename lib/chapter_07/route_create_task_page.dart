import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../learning_navigation_controls.dart';
import 'route_lab_models.dart';

class RouteCreateTaskPage extends StatefulWidget {
  const RouteCreateTaskPage({super.key});

  @override
  State<RouteCreateTaskPage> createState() => _RouteCreateTaskPageState();
}

class _RouteCreateTaskPageState extends State<RouteCreateTaskPage> {
  final _titleController = TextEditingController(text: '新增 go_router 练习任务');
  final _noteController = TextEditingController(text: '用 pop(result) 把结果交回列表页');

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    if (title.isEmpty) return;

    context.pop(RouteLabTaskDraft(title: title, note: note));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('创建路由任务'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('返回值练习', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '任务标题'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '备注'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('创建并返回列表'),
            ),
          ],
        ),
      ),
    );
  }
}
