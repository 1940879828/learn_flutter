import 'package:flutter/material.dart';

class LayoutLabPage extends StatelessWidget {
  const LayoutLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 这一组 _LayoutCase 是本章的“案例目录”。
    // 每一项只描述入口信息和目标页面，真正的布局实现放在各自的 Page 里。
    final cases = <_LayoutCase>[
      _LayoutCase(
        title: '基础居中布局',
        subtitle: 'Center + Column：把一组内容放在画面中心',
        icon: Icons.center_focus_strong_outlined,
        builder: (_) => const CenterColumnLayoutPage(),
      ),
      _LayoutCase(
        title: '横向信息卡',
        subtitle: 'Row + Expanded：图标、文字、操作区并排',
        icon: Icons.view_agenda_outlined,
        builder: (_) => const RowColumnFlexLayoutPage(),
      ),
      _LayoutCase(
        title: '比例分栏',
        subtitle: 'Expanded flex：按比例分配剩余空间',
        icon: Icons.view_week_outlined,
        builder: (_) => const ExpandedFlexibleLayoutPage(),
      ),
      _LayoutCase(
        title: '卡片列表',
        subtitle: 'ListView 思路：重复内容纵向滚动',
        icon: Icons.list_alt_outlined,
        builder: (_) => const CardListLayoutPage(),
      ),
      _LayoutCase(
        title: '两列网格',
        subtitle: 'GridView：图库、模板、作品集常用',
        icon: Icons.grid_view_outlined,
        builder: (_) => const TwoColumnGridLayoutPage(),
      ),
      _LayoutCase(
        title: '图片遮罩叠层',
        subtitle: 'Stack + Positioned：图片上叠文字和按钮',
        icon: Icons.layers_outlined,
        builder: (_) => const StackOverlayLayoutPage(),
      ),
      _LayoutCase(
        title: '固定头部滚动区',
        subtitle: 'Column + Expanded：头部固定，内容滚动',
        icon: Icons.vertical_align_top_outlined,
        builder: (_) => const FixedHeaderScrollLayoutPage(),
      ),
      _LayoutCase(
        title: '响应式布局',
        subtitle: 'LayoutBuilder：窄屏单列，宽屏双列',
        icon: Icons.devices_outlined,
        builder: (_) => const ResponsiveLayoutPage(),
      ),
      _LayoutCase(
        title: '安全区布局',
        subtitle: 'SafeArea：避开刘海、状态栏和手势区',
        icon: Icons.phone_iphone_outlined,
        builder: (_) => const SafeAreaLayoutPage(),
      ),
      _LayoutCase(
        title: '我的居中练习',
        subtitle: '第一个案例',
        icon: Icons.edit_outlined,
        builder: (_) => const MyCenterPracticePage(),
      ),
      _LayoutCase(
        title: '我的横向信息卡练习',
        subtitle: '第二个案例',
        icon: Icons.view_agenda_outlined,
        builder: (_) => const MyRowColumnFlexLayoutPage(),
      ),
      _LayoutCase(
        title: '我的比例分栏',
        subtitle: 'Expanded flex：按比例分配剩余空间',
        icon: Icons.view_week_outlined,
        builder: (_) => const MyExpandedFlexibleLayoutPage(),
      ),
      _LayoutCase(
        title: '我的卡片列表',
        subtitle: 'ListView 思路：重复内容纵向滚动',
        icon: Icons.list_alt_outlined,
        builder: (_) => const MyCardListLayoutPage(),
      ),
      _LayoutCase(
        title: '两列网格',
        subtitle: 'GridView：图库、模板、作品集常用',
        icon: Icons.grid_view_outlined,
        builder: (_) => const MyTwoColumnGridLayoutPage(),
      ),
      _LayoutCase(
        title: '我的图片遮罩叠层',
        subtitle: 'Stack + Positioned：图片上叠文字和按钮',
        icon: Icons.layers_outlined,
        builder: (_) => const MyStackOverlayLayoutPage(),
      ),
      _LayoutCase(
        title: '我的固定头部滚动区',
        subtitle: 'Column + Expanded：头部固定，内容滚动',
        icon: Icons.vertical_align_top_outlined,
        builder: (_) => const MyFixedHeaderScrollLayoutPage(),
      ),
      _LayoutCase(
        title: '我的响应式布局',
        subtitle: 'LayoutBuilder：窄屏单列，宽屏双列',
        icon: Icons.devices_outlined,
        builder: (_) => const MyResponsiveLayoutPage(),
      ),
      _LayoutCase(
        title: '安全区布局',
        subtitle: 'SafeArea：避开刘海、状态栏和手势区',
        icon: Icons.phone_iphone_outlined,
        builder: (_) => const MySafeAreaLayoutPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('04 布局案例实验室')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          // 额外 +1 是为了把章节说明 _LayoutIntro 放在列表第一项。
          itemCount: cases.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _LayoutIntro();
            }

            // 因为 index 0 留给了介绍卡片，所以真正的案例索引要减 1。
            final layoutCase = cases[index - 1];
            return Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              child: ListTile(
                leading: Icon(layoutCase.icon),
                title: Text(layoutCase.title),
                subtitle: Text(layoutCase.subtitle),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  // push 会把目标案例页面压入导航栈；系统返回键会回到这个目录页。
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: layoutCase.builder));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class CenterColumnLayoutPage extends StatelessWidget {
  const CenterColumnLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaseScaffold(
      title: '基础居中布局',
      description: 'Center 负责把子组件放中间，Column 负责把图标、标题、按钮纵向排起来。',
      child: SizedBox(
        height: 280,
        child: ColoredBox(
          color: Color(0xFFE8F5E9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 48),
                SizedBox(height: 12),
                Text('Center + Column'),
                SizedBox(height: 12),
                FilledButton(onPressed: null, child: Text('居中的操作按钮')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyCenterPracticePage extends StatelessWidget {
  const MyCenterPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '基础居中布局',
      description: 'description',
      child: SizedBox(
        height: 280,
        child: ColoredBox(
          color: Color(0xFFE8F5E9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 48),
                Text("hi"),
                FilledButton(
                  onPressed: () {
                    debugPrint('hello');
                  },
                  child: const Text('居中的操作按钮'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RowColumnFlexLayoutPage extends StatelessWidget {
  const RowColumnFlexLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaseScaffold(
      title: '横向信息卡',
      description: 'Row 管横向排列；Expanded 让中间文字吃掉剩余宽度，避免挤爆右侧按钮。',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.image_outlined,
            title: '生成封面',
            description: '图标固定宽度，文字区域自适应，按钮保持在右侧。',
            actionText: '查看',
          ),
          SizedBox(height: 12),
          _InfoRow(
            icon: Icons.movie_creation_outlined,
            title: '生成视频',
            description: '这种结构在任务列表、设置项、历史记录里很常见。',
            actionText: '继续',
          ),
        ],
      ),
    );
  }
}

class MyRowColumnFlexLayoutPage extends StatelessWidget {
  const MyRowColumnFlexLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '横向信息卡',
      description: 'Row 管横向排列；Expanded 让中间文字吃掉剩余宽度，避免挤爆右侧按钮。',
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.image_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hi this is title',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text('yeah this is desc'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => debugPrint('hi'),
                    child: Text('action'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyExpandedFlexibleLayoutPage extends StatelessWidget {
  const MyExpandedFlexibleLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaseScaffold(
      title: '比例分栏',
      description: '三个 Expanded 使用不同 flex，父级剩余宽度会按 2:1:1 分给它们。',
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _ColorPanel(
                label: '主内容 flex: 1',
                color: Color(0xFFB2DFDB),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _ColorPanel(label: '侧栏 flex: 2', color: Color(0xFFFFECB3)),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _ColorPanel(label: '操作 flex: 3', color: Color(0xFFFFCDD2)),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedFlexibleLayoutPage extends StatelessWidget {
  const ExpandedFlexibleLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaseScaffold(
      title: '比例分栏',
      description: '三个 Expanded 使用不同 flex，父级剩余宽度会按 2:1:1 分给它们。',
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _ColorPanel(
                label: '主内容 flex: 2',
                color: Color(0xFFB2DFDB),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _ColorPanel(label: '侧栏 flex: 1', color: Color(0xFFFFECB3)),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _ColorPanel(label: '操作 flex: 1', color: Color(0xFFFFCDD2)),
            ),
          ],
        ),
      ),
    );
  }
}

class CardListLayoutPage extends StatelessWidget {
  const CardListLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '卡片列表',
      description: '列表页的核心是重复单元。先把单个 item 写清楚，再交给 ListView 重复。',
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
            child: _TaskCard(
              title: '任务 ${index + 1}',
              status: index.isEven ? '生成中' : '已完成',
              color: index.isEven
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFE8F5E9),
            ),
          ),
        ),
      ),
    );
  }
}

class MyCardListLayoutPage extends StatelessWidget {
  const MyCardListLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '卡片列表',
      description: '列表页的核心是重复单元。先把单个 item 写清楚，再交给 ListView 重复。',
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
            child: _TaskCard(
              title: 'task ${index + 1}',
              status: index.isEven ? 'doing' : 'done',
              color: index.isEven
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFE8F5E9),
            ),
          ),
        ),
      ),
    );
  }
}

class TwoColumnGridLayoutPage extends StatelessWidget {
  const TwoColumnGridLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '两列网格',
      description: 'GridView 适合图库和模板选择。这里用 shrinkWrap 让它嵌在教学页的滚动容器里。',
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(6, (index) => _GridTile(index: index)),
      ),
    );
  }
}

class MyTwoColumnGridLayoutPage extends StatelessWidget {
  const MyTwoColumnGridLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '两列网格',
      description: 'GridView 适合图库和模板选择。这里用 shrinkWrap 让它嵌在教学页的滚动容器里。',
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(6, (index) => _GridTile(index: index)),
      ),
    );
  }
}

class StackOverlayLayoutPage extends StatelessWidget {
  const StackOverlayLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaseScaffold(
      title: '图片遮罩叠层',
      description: 'Stack 像图层系统，后写的 Widget 会压在先写的 Widget 上面。',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _OverlayCaption(),
            ),
          ],
        ),
      ),
    );
  }
}

class MyStackOverlayLayoutPage extends StatelessWidget {
  const MyStackOverlayLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '图片遮罩叠层',
      description: 'Stack 像图层系统，后写的 Widget 会压在先写的 Widget 上面。',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _MyOverlayCaption(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyOverlayCaption extends StatelessWidget {
  const _MyOverlayCaption();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'works preview',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              'title、tag、button can overflow the image',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FixedHeaderScrollLayoutPage extends StatelessWidget {
  const FixedHeaderScrollLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '固定头部滚动区',
      description: 'Column 放固定头部，Expanded 把剩余高度给内部 ListView。',
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF263238),
              child: const Text('固定筛选栏', style: TextStyle(color: Colors.white)),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 12,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('滚动内容 ${index + 1}'),
                    subtitle: const Text('头部不会跟着这块内部列表滚动'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyFixedHeaderScrollLayoutPage extends StatelessWidget {
  const MyFixedHeaderScrollLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '固定头部滚动区',
      description: 'Column 放固定头部，Expanded 把剩余高度给内部 ListView。',
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF263238),
              child: const Text('固定筛选栏', style: TextStyle(color: Colors.white)),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('滚动内容 ${index + 1}'),
                    subtitle: const Text('头部不会跟着这块内部列表滚动'),
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveLayoutPage extends StatelessWidget {
  const ResponsiveLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '响应式布局',
      description: 'LayoutBuilder 能拿到父组件给你的最大宽度，然后决定当前用哪一种布局。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 520;
          final preview = [
            const _ResponsivePanel(title: '预览区', color: Color(0xFFE1F5FE)),
            const _ResponsivePanel(title: '设置区', color: Color(0xFFF1F8E9)),
          ];

          if (isWide) {
            return Row(
              children: [
                Expanded(child: preview[0]),
                const SizedBox(width: 12),
                Expanded(child: preview[1]),
              ],
            );
          }

          return Column(
            children: [preview[0], const SizedBox(height: 12), preview[1]],
          );
        },
      ),
    );
  }
}

class MyResponsiveLayoutPage extends StatelessWidget {
  const MyResponsiveLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CaseScaffold(
      title: '响应式布局',
      description: 'LayoutBuilder 能拿到父组件给你的最大宽度，然后决定当前用哪一种布局。',
      // 在 build 的时候，拿到“父组件给我的尺寸约束”，然后根据这个约束决定怎么布局。
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 520;
          final preview = [
            const _ResponsivePanel(title: '预览区', color: Color(0xFFE1F5FE)),
            const _ResponsivePanel(title: '设置区', color: Color(0xFFF1F8E9)),
          ];

          if (isWide) {
            return Row(
              children: [
                Expanded(child: preview[0]),
                const SizedBox(width: 12),
                Expanded(child: preview[1]),
              ],
            );
          }

          return Column(
            children: [preview[0], const SizedBox(height: 12), preview[1]],
          );
        },
      ),
    );
  }
}

class SafeAreaLayoutPage extends StatelessWidget {
  const SafeAreaLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaseScaffold(
      title: '安全区布局',
      description: 'SafeArea 会根据设备边缘不可用区域自动加 padding，移动端页面很常用。',
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFF111827)),
        child: SafeArea(
          minimum: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PhoneBar(text: '顶部避开状态栏和刘海'),
              SizedBox(height: 120),
              _PhoneBar(text: '底部避开手势区'),
            ],
          ),
        ),
      ),
    );
  }
}

class MySafeAreaLayoutPage extends StatelessWidget {
  const MySafeAreaLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaseScaffold(
      title: '安全区布局',
      description: 'SafeArea 会根据设备边缘不可用区域自动加 padding，移动端页面很常用。',
      child: SafeArea(
        minimum: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PhoneBar(text: '顶部避开状态栏和刘海'),
            SizedBox(height: 120),
            _PhoneBar(text: '底部避开手势区'),
          ],
        ),
      ),
    );
  }
}

class _LayoutIntro extends StatelessWidget {
  const _LayoutIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('经典布局清单', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '先点进去看效果，再回到 lib/chapter_04/layout_lab_page.dart 找同名类读代码。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CaseScaffold extends StatelessWidget {
  const _CaseScaffold({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionText,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: null, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}

class _ColorPanel extends StatelessWidget {
  const _ColorPanel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.status,
    required this.color,
  });

  final String title;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        title: Text(title),
        subtitle: const Text('一个可复用的列表 item'),
        trailing: Chip(label: Text(status)),
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      const Color(0xFFB2DFDB),
      const Color(0xFFFFECB3),
      const Color(0xFFC5CAE9),
      const Color(0xFFFFCDD2),
      const Color(0xFFD7CCC8),
      const Color(0xFFC8E6C9),
    ];

    return Material(
      color: colors[index % colors.length],
      borderRadius: BorderRadius.circular(8),
      child: Center(child: Text('作品 ${index + 1}')),
    );
  }
}

class _OverlayCaption extends StatelessWidget {
  const _OverlayCaption();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          /**
           * 交叉轴对齐方式
           * Column 主轴：上下方向
           * Column 交叉轴：左右方向
           */
          crossAxisAlignment: CrossAxisAlignment.start,
          // 垂直方向 高度只包住内容，不主动撑满父级高度
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI 作品预览',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text('标题、标签、按钮可以叠在图片上。', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _ResponsivePanel extends StatelessWidget {
  const _ResponsivePanel({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      color: color,
      child: Text(title),
    );
  }
}

class _PhoneBar extends StatelessWidget {
  const _PhoneBar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF4DB6AC),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _LayoutCase {
  const _LayoutCase({
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
