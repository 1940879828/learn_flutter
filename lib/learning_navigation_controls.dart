import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'learning_routes.dart';

class LearningBackOrHomeButton extends StatelessWidget {
  const LearningBackOrHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '返回上一页',
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }

        context.go(LearningRoutes.home);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}

class LearningHomeAction extends StatelessWidget {
  const LearningHomeAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '回到学习首页',
      onPressed: () => context.go(LearningRoutes.home),
      icon: const Icon(Icons.home_outlined),
    );
  }
}
