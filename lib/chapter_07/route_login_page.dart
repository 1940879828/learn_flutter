import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../learning_navigation_controls.dart';
import '../learning_routes.dart';
import 'route_lab_models.dart';

class RouteLoginPage extends StatelessWidget {
  const RouteLoginPage({required this.session, required this.from, super.key});

  final RouteLabSession session;
  final String from;

  void _login(BuildContext context) {
    final returnTo = from.isEmpty ? LearningRoutes.chapter07Lab : from;
    session.login();
    context.pushReplacement(returnTo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('模拟登录页'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'redirect 练习',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '登录后回到：${from.isEmpty ? LearningRoutes.chapter07Lab : from}',
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _login(context),
                icon: const Icon(Icons.login),
                label: const Text('模拟登录并返回原页面'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
