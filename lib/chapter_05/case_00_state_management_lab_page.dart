import 'package:flutter/material.dart';

import 'case_01_set_state_example_page.dart';
import 'case_02_notifier_provider_example_page.dart';
import 'case_03_provider_example_page.dart';
import 'case_04_future_provider_example_page.dart';
import 'case_05_async_notifier_repository_example_page.dart';
import 'case_06_comprehensive_task_board_page.dart';
import 'case_07_practice_demo.dart';

class StateManagementLabPage extends StatelessWidget {
  const StateManagementLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = <_StateExampleEntry>[
      _StateExampleEntry(
        title: '01 StatefulWidget + setState',
        subtitle: '状态只属于当前页面，按钮点击后手动 setState',
        icon: Icons.touch_app_outlined,
        builder: (_) => const SetStateExamplePage(),
      ),
      _StateExampleEntry(
        title: '02 NotifierProvider',
        subtitle: '把状态和修改逻辑从 Widget 抽到 controller',
        icon: Icons.tune_outlined,
        builder: (_) => const NotifierProviderExamplePage(),
      ),
      _StateExampleEntry(
        title: '03 Provider 派生数据',
        subtitle: 'Provider watch 另一个 provider，派生筛选后的列表',
        icon: Icons.account_tree_outlined,
        builder: (_) => const ProviderExamplePage(),
      ),
      _StateExampleEntry(
        title: '04 FutureProvider',
        subtitle: '一次性异步请求，直接处理 loading、error、data',
        icon: Icons.cloud_download_outlined,
        builder: (_) => const FutureProviderExamplePage(),
      ),
      _StateExampleEntry(
        title: '05 AsyncNotifier + repository',
        subtitle: '远程数据由 repository 获取，controller 管理刷新和错误',
        icon: Icons.storage_outlined,
        builder: (_) => const AsyncNotifierRepositoryExamplePage(),
      ),
      _StateExampleEntry(
        title: '06 综合任务看板',
        subtitle: '把 watch、read、listen 和派生 provider 组合起来',
        icon: Icons.dashboard_outlined,
        builder: (_) => const ComprehensiveTaskBoardPage(),
      ),
      _StateExampleEntry(
        title: '07 综合练习',
        subtitle: '手写一遍',
        icon: Icons.dashboard_outlined,
        builder: (_) => const Case07PracticeDemo(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('05 状态管理与 Riverpod')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: examples.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _StateLabIntro();
            }

            final example = examples[index - 1];
            return Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              child: ListTile(
                leading: Icon(example.icon),
                title: Text(example.title),
                subtitle: Text(example.subtitle),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: example.builder));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StateLabIntro extends StatelessWidget {
  const _StateLabIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('状态管理练习顺序', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '先看单点案例，再看最后的综合任务看板。每个页面都能单独打开、单独读代码。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _StateExampleEntry {
  const _StateExampleEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}
