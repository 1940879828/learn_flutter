import 'package:flutter/material.dart';

import 'chapter_03/lifecycle_demo_page.dart';
import 'chapter_04/layout_lab_page.dart';
import 'chapter_05/state_management_lab_page.dart';

class LearningHomePage extends StatelessWidget {
  const LearningHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = <_LearningEntry>[
      _LearningEntry(
        title: '03 Widget 生命周期',
        subtitle: '看 initState、didUpdateWidget、dispose 如何触发',
        icon: Icons.account_tree_outlined,
        builder: (_) => const LifecycleDemoPage(),
      ),
      _LearningEntry(
        title: '04 布局案例实验室',
        subtitle: '像学 CSS 布局一样，逐个拆 Flutter 经典布局',
        icon: Icons.dashboard_customize_outlined,
        builder: (_) => const LayoutLabPage(),
      ),
      _LearningEntry(
        title: '05 状态管理与 Riverpod',
        subtitle: '练 watch、read、listen 和状态分层',
        icon: Icons.hub_outlined,
        builder: (_) => const StateManagementLabPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter 学习目录'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _HomeIntro();
            }

            final entry = entries[index - 1];
            return _LearningEntryTile(entry: entry);
          },
        ),
      ),
    );
  }
}

class _HomeIntro extends StatelessWidget {
  const _HomeIntro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('从这里进入每章练习', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '先看页面效果，再读对应 Dart 文件，最后自己照着新增一个入口。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LearningEntryTile extends StatelessWidget {
  const _LearningEntryTile({required this.entry});

  final _LearningEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: Icon(entry.icon),
        title: Text(entry.title),
        subtitle: Text(entry.subtitle),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: entry.builder));
        },
      ),
    );
  }
}

class _LearningEntry {
  const _LearningEntry({
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
