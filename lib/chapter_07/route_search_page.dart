import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../learning_navigation_controls.dart';
import '../learning_routes.dart';

class RouteSearchPage extends StatefulWidget {
  const RouteSearchPage({required this.keyword, super.key});

  final String keyword;

  @override
  State<RouteSearchPage> createState() => _RouteSearchPageState();
}

class _RouteSearchPageState extends State<RouteSearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.keyword);
  }

  @override
  void didUpdateWidget(RouteSearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyword == widget.keyword) return;
    _controller.text = widget.keyword;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuery() {
    context.go(LearningRoutes.searchLocation(keyword: _controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('query 参数搜索页'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '当前 query：${widget.keyword}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'keyword'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _updateQuery,
              icon: const Icon(Icons.sync),
              label: const Text('更新 query'),
            ),
          ],
        ),
      ),
    );
  }
}
