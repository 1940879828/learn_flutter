import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'learning_routes.dart';

class LearningHomePage extends StatelessWidget {
  const LearningHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = <_LearningEntry>[
      _LearningEntry(
        title: '03 Widget 生命周期',
        subtitle: '看 initState、didUpdateWidget、dispose 如何触发',
        icon: Icons.account_tree_outlined,
        path: LearningRoutes.chapter03Lifecycle,
      ),
      _LearningEntry(
        title: '04 布局案例实验室',
        subtitle: '像学 CSS 布局一样，逐个拆 Flutter 经典布局',
        icon: Icons.dashboard_customize_outlined,
        path: LearningRoutes.chapter04Layout,
      ),
      _LearningEntry(
        title: '05 状态管理与 Riverpod',
        subtitle: '练 watch、read、listen 和状态分层',
        icon: Icons.hub_outlined,
        path: LearningRoutes.chapter05State,
      ),
      _LearningEntry(
        title: '06 转场动画实验室',
        subtitle: '练 PageRouteBuilder、Hero 和常见转场组合',
        icon: Icons.animation_outlined,
        path: LearningRoutes.chapter06Transition,
      ),
      _LearningEntry(
        title: '07 路由导航与页面组织',
        subtitle: '练 go_router、参数、返回值和 redirect',
        icon: Icons.route_outlined,
        path: LearningRoutes.chapter07Lab,
      ),
      _LearningEntry(
        title: '08 异步网络数据模型',
        subtitle: '练 API client、repository、model 和三态 UI',
        icon: Icons.cloud_queue_outlined,
        path: LearningRoutes.chapter08AsyncNetwork,
      ),
      _LearningEntry(
        title: '09 本地存储权限与文件',
        subtitle: '练最近 prompt、本地 JSON 和模拟权限状态',
        icon: Icons.folder_copy_outlined,
        path: LearningRoutes.chapter09LocalStorage,
      ),
      _LearningEntry(
        title: '10 音视频与媒体能力',
        subtitle: '练媒体来源、图片预览和视频生命周期',
        icon: Icons.video_library_outlined,
        path: LearningRoutes.chapter10Media,
      ),
      _LearningEntry(
        title: '11 工程化调试测试构建',
        subtitle: '练 pubspec、analyze、test、codegen 门禁判断',
        icon: Icons.construction_outlined,
        path: LearningRoutes.chapter11Engineering,
      ),
      _LearningEntry(
        title: '13 多语言与本地化',
        subtitle: '练 locale、fallback、占位符和 gen-l10n 心智',
        icon: Icons.translate_outlined,
        path: LearningRoutes.chapter13Localization,
      ),
      _LearningEntry(
        title: '14 Firebase 登录与账号状态',
        subtitle: '练 provider 登录、loading/error 和 auth state',
        icon: Icons.verified_user_outlined,
        path: LearningRoutes.chapter14FirebaseAuth,
      ),
      _LearningEntry(
        title: '15 聊天键盘上移动画',
        subtitle: '复刻键盘弹起时聊天列表整体上移的卡顿场景',
        icon: Icons.keyboard_alt_outlined,
        path: LearningRoutes.chapter15ChatKeyboardJank,
      ),
      _LearningEntry(
        title: '16 视频示例',
        subtitle: '视频操作',
        icon: Icons.video_call_outlined,
        path: LearningRoutes.chapter16Video,
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
          context.push(entry.path);
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
    required this.path,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String path;
}
