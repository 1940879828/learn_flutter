import 'package:flutter/material.dart';

import '../learning_navigation_controls.dart';

class EngineeringChecklistPage extends StatelessWidget {
  const EngineeringChecklistPage({super.key});

  static const _items = [
    EngineeringChecklistItem(
      title: 'pubspec.yaml',
      command: 'fvm flutter pub get',
      note: '依赖、assets、fonts 或 generate 配置变化后先同步 lock 文件。',
      icon: Icons.inventory_2_outlined,
    ),
    EngineeringChecklistItem(
      title: 'analysis_options.yaml',
      command: 'fvm flutter analyze',
      note: '对应 Web 里的 eslint/tsc，用来提前抓静态错误和团队规范。',
      icon: Icons.rule_outlined,
    ),
    EngineeringChecklistItem(
      title: 'widget / unit test',
      command: 'fvm flutter test',
      note: '页面入口、状态变化、model 转换这类收口逻辑优先写测试。',
      icon: Icons.checklist_outlined,
    ),
    EngineeringChecklistItem(
      title: 'build_runner',
      command:
          'fvm flutter pub run build_runner build --delete-conflicting-outputs',
      note: '修改 json_serializable、Riverpod 生成或其它注解模型时才需要跑。',
      icon: Icons.precision_manufacturing_outlined,
    ),
    EngineeringChecklistItem(
      title: 'gen-l10n',
      command: 'fvm flutter gen-l10n',
      note: '修改 .arb 多语言源文件后重新生成，不手改生成产物。',
      icon: Icons.translate_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('11 工程化调试测试构建'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('改动前后的门禁清单', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('学习项目先掌握判断顺序；SpellAI 里还要额外关注自定义 lint、生成文件和平台配置。'),
            const SizedBox(height: 16),
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChecklistTile(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EngineeringChecklistItem {
  const EngineeringChecklistItem({
    required this.title,
    required this.command,
    required this.note,
    required this.icon,
  });

  final String title;
  final String command;
  final String note;
  final IconData icon;
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item});

  final EngineeringChecklistItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(item.icon),
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.command),
            const SizedBox(height: 4),
            Text(item.note),
          ],
        ),
      ),
    );
  }
}
