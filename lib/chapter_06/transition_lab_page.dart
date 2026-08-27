import 'package:flutter/material.dart';

class TransitionLabPage extends StatelessWidget {
  const TransitionLabPage({super.key});

  static const _demos = <_TransitionDemo>[
    _TransitionDemo(
      title: 'SlideTransition',
      subtitle: '从右侧滑入，最接近常见页面 push 效果',
      icon: Icons.swipe_right_alt,
      type: _TransitionType.slide,
    ),
    _TransitionDemo(
      title: 'FadeTransition',
      subtitle: '淡入淡出，适合轻量页面或状态切换',
      icon: Icons.blur_on,
      type: _TransitionType.fade,
    ),
    _TransitionDemo(
      title: 'ScaleTransition',
      subtitle: '缩放进入，适合弹窗、卡片详情、工具面板',
      icon: Icons.zoom_out_map,
      type: _TransitionType.scale,
    ),
    _TransitionDemo(
      title: 'RotationTransition',
      subtitle: '轻微旋转加缩放，适合观察动画组合',
      icon: Icons.rotate_right,
      type: _TransitionType.rotation,
    ),
    _TransitionDemo(
      title: 'SizeTransition',
      subtitle: '从顶部展开，适合理解尺寸动画',
      icon: Icons.unfold_more,
      type: _TransitionType.size,
    ),
    _TransitionDemo(
      title: 'Container Transform',
      subtitle: '卡片像容器一样展开成详情页',
      icon: Icons.crop_square,
      type: _TransitionType.containerTransform,
    ),
    _TransitionDemo(
      title: 'Hero Header',
      subtitle: '共享元素从列表飞到页面头图位置',
      icon: Icons.auto_awesome_motion,
      type: _TransitionType.heroHeader,
    ),
    _TransitionDemo(
      title: 'Hero + Staggered',
      subtitle: '共享元素先飞入，详情内容再分批出现',
      icon: Icons.view_agenda_outlined,
      type: _TransitionType.staggered,
    ),
    _TransitionDemo(
      title: 'Collapsing Header',
      subtitle: '大头图滚动后折叠进 AppBar',
      icon: Icons.vertical_align_top,
      type: _TransitionType.collapsingHeader,
    ),
    _TransitionDemo(
      title: 'Parallax Header',
      subtitle: '滚动时头图慢速移动，制造空间层次',
      icon: Icons.layers_outlined,
      type: _TransitionType.parallaxHeader,
    ),
    _TransitionDemo(
      title: 'Shared Axis Z',
      subtitle: '页面像沿前后层级推进',
      icon: Icons.view_in_ar,
      type: _TransitionType.sharedAxisZ,
    ),
    _TransitionDemo(
      title: 'Fade Through',
      subtitle: '旧内容淡出，新内容稍后淡入',
      icon: Icons.blur_linear,
      type: _TransitionType.fadeThrough,
    ),
    _TransitionDemo(
      title: 'AnimatedContainer',
      subtitle: '同页卡片展开、变色、圆角变化',
      icon: Icons.auto_fix_high,
      type: _TransitionType.animatedContainer,
    ),
    _TransitionDemo(
      title: 'Hero',
      subtitle: '最小共享元素示例：图标从列表飞到详情',
      icon: Icons.motion_photos_on_outlined,
      type: _TransitionType.hero,
    ),
  ];

  void _openDemo(BuildContext context, _TransitionDemo demo) {
    Navigator.of(context).push(_buildDemoRoute(demo));
  }

  PageRouteBuilder<void> _buildDemoRoute(_TransitionDemo demo) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (context, animation, secondaryAnimation) {
        return switch (demo.type) {
          _TransitionType.heroHeader => _HeroHeaderResultPage(demo: demo),
          _TransitionType.staggered => _StaggeredResultPage(demo: demo),
          _TransitionType.collapsingHeader => _CollapsingHeaderResultPage(
            demo: demo,
          ),
          _TransitionType.parallaxHeader => _ParallaxHeaderResultPage(
            demo: demo,
          ),
          _TransitionType.animatedContainer => _AnimatedContainerResultPage(
            demo: demo,
          ),
          _ => _TransitionResultPage(demo: demo),
        };
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return switch (demo.type) {
          _TransitionType.slide => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
          _TransitionType.fade => FadeTransition(opacity: curved, child: child),
          _TransitionType.scale => FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
              child: child,
            ),
          ),
          _TransitionType.rotation => FadeTransition(
            opacity: curved,
            child: RotationTransition(
              turns: Tween<double>(begin: -0.04, end: 0).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                child: child,
              ),
            ),
          ),
          _TransitionType.size => Align(
            alignment: Alignment.topCenter,
            child: SizeTransition(
              sizeFactor: curved,
              axisAlignment: -1,
              child: child,
            ),
          ),
          _TransitionType.hero => FadeTransition(opacity: curved, child: child),
          _TransitionType.containerTransform => FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.72, end: 1).animate(curved),
              child: child,
            ),
          ),
          _TransitionType.heroHeader => FadeTransition(
            opacity: curved,
            child: child,
          ),
          _TransitionType.staggered => FadeTransition(
            opacity: curved,
            child: child,
          ),
          _TransitionType.collapsingHeader => FadeTransition(
            opacity: curved,
            child: child,
          ),
          _TransitionType.parallaxHeader => FadeTransition(
            opacity: curved,
            child: child,
          ),
          _TransitionType.sharedAxisZ => FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.84, end: 1).animate(curved),
              child: child,
            ),
          ),
          _TransitionType.fadeThrough => FadeTransition(
            opacity: TweenSequence<double>([
              TweenSequenceItem(tween: ConstantTween<double>(0), weight: 25),
              TweenSequenceItem(
                tween: Tween<double>(begin: 0, end: 1),
                weight: 75,
              ),
            ]).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          ),
          _TransitionType.animatedContainer => FadeTransition(
            opacity: curved,
            child: child,
          ),
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('06 转场动画实验室')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _demos.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) return const _TransitionIntro();

            final demo = _demos[index - 1];
            return _TransitionDemoTile(
              demo: demo,
              onTap: () => _openDemo(context, demo),
            );
          },
        ),
      ),
    );
  }
}

class _TransitionIntro extends StatelessWidget {
  const _TransitionIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PageRouteBuilder 转场',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          '同一个目标页可以套不同动画。重点看 transitionsBuilder 里返回了哪个动画 Widget。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _TransitionDemoTile extends StatelessWidget {
  const _TransitionDemoTile({required this.demo, required this.onTap});

  final _TransitionDemo demo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: demo.usesHero
            ? Hero(
                tag: demo.heroTag,
                child: CircleAvatar(
                  backgroundColor: color,
                  child: Icon(demo.icon),
                ),
              )
            : CircleAvatar(backgroundColor: color, child: Icon(demo.icon)),
        title: Text(demo.title),
        subtitle: Text(demo.subtitle),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}

class _HeroHeaderResultPage extends StatelessWidget {
  const _HeroHeaderResultPage({required this.demo});

  final _TransitionDemo demo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  Hero(
                    tag: demo.heroTag,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Icon(demo.icon, size: 44),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    demo.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _ResultBody(
                demo: demo,
                explanation:
                    'Hero Header 常用于作品列表进入详情：缩略图或头像飞到详情页 header，用户会感觉自己进入的是同一个对象。',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredResultPage extends StatefulWidget {
  const _StaggeredResultPage({required this.demo});

  final _TransitionDemo demo;

  @override
  State<_StaggeredResultPage> createState() => _StaggeredResultPageState();
}

class _StaggeredResultPageState extends State<_StaggeredResultPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ['标题从下方浮现', '副标题稍后出现', '操作按钮最后进入'];

    return Scaffold(
      appBar: AppBar(title: Text(widget.demo.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.demo.heroTag,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(widget.demo.icon, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < items.length; i++) ...[
                _StaggeredItem(
                  animation: _controller,
                  index: i,
                  text: items[i],
                ),
                const SizedBox(height: 12),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回动画列表'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({
    required this.animation,
    required this.index,
    required this.text,
  });

  final Animation<double> animation;
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final start = index * 0.18;
    final end = start + 0.5;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(curved),
        child: Card(
          child: ListTile(leading: Text('0${index + 1}'), title: Text(text)),
        ),
      ),
    );
  }
}

class _CollapsingHeaderResultPage extends StatelessWidget {
  const _CollapsingHeaderResultPage({required this.demo});

  final _TransitionDemo demo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(demo.title),
              background: ColoredBox(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Hero(
                    tag: demo.heroTag,
                    child: Icon(demo.icon, size: 92),
                  ),
                ),
              ),
            ),
          ),
          SliverList.list(
            children: [
              _InfoSection(demo: demo),
              for (var i = 1; i <= 8; i++)
                ListTile(
                  title: Text('滚动内容 $i'),
                  subtitle: const Text('往上滑动观察 header 折叠'),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回动画列表'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParallaxHeaderResultPage extends StatelessWidget {
  const _ParallaxHeaderResultPage({required this.demo});

  final _TransitionDemo demo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(demo.title)),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: false,
            delegate: _ParallaxHeaderDelegate(demo: demo),
          ),
          SliverList.list(
            children: [
              _InfoSection(demo: demo),
              for (var i = 1; i <= 10; i++)
                ListTile(
                  title: Text('视差内容 $i'),
                  subtitle: const Text('滚动时 header 图层移动速度更慢'),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回动画列表'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParallaxHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ParallaxHeaderDelegate({required this.demo});

  final _TransitionDemo demo;

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 260;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Transform.translate(
          offset: Offset(0, shrinkOffset * 0.35),
          child: Center(child: Icon(demo.icon, size: 104)),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ParallaxHeaderDelegate oldDelegate) {
    return oldDelegate.demo != demo;
  }
}

class _AnimatedContainerResultPage extends StatefulWidget {
  const _AnimatedContainerResultPage({required this.demo});

  final _TransitionDemo demo;

  @override
  State<_AnimatedContainerResultPage> createState() {
    return _AnimatedContainerResultPageState();
  }
}

class _AnimatedContainerResultPageState
    extends State<_AnimatedContainerResultPage> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.demo.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  height: _expanded ? 220 : 120,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _expanded
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(_expanded ? 28 : 8),
                  ),
                  child: Align(
                    alignment: _expanded ? Alignment.center : Alignment.topLeft,
                    child: Icon(widget.demo.icon, size: _expanded ? 72 : 40),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('点上面的卡片，观察同一个 Widget 的尺寸、颜色、圆角和内容位置一起过渡。'),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回动画列表'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransitionResultPage extends StatelessWidget {
  const _TransitionResultPage({required this.demo});

  final _TransitionDemo demo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(demo.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: demo.heroTag,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(demo.icon, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                demo.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(demo.subtitle, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(
                demo.explanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回动画列表'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.demo, required this.explanation});

  final _TransitionDemo demo;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(demo.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text(explanation),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回动画列表'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.demo});

  final _TransitionDemo demo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        demo.explanation,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

enum _TransitionType {
  slide,
  fade,
  scale,
  rotation,
  size,
  containerTransform,
  heroHeader,
  staggered,
  collapsingHeader,
  parallaxHeader,
  sharedAxisZ,
  fadeThrough,
  animatedContainer,
  hero,
}

class _TransitionDemo {
  const _TransitionDemo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _TransitionType type;

  String get heroTag => 'transition-demo-$title';

  bool get usesHero {
    return switch (type) {
      _TransitionType.containerTransform ||
      _TransitionType.heroHeader ||
      _TransitionType.staggered ||
      _TransitionType.collapsingHeader ||
      _TransitionType.hero => true,
      _ => false,
    };
  }

  String get explanation {
    return switch (type) {
      _TransitionType.slide =>
        'SlideTransition 改的是页面位置，常用 Offset(1, 0) 表示从右侧进入。',
      _TransitionType.fade => 'FadeTransition 改的是透明度，适合不强调空间方向的页面切换。',
      _TransitionType.scale =>
        'ScaleTransition 改的是缩放比例，经常和 FadeTransition 组合使用。',
      _TransitionType.rotation => 'RotationTransition 改的是旋转角度。正式业务里通常只做很轻微的旋转。',
      _TransitionType.size => 'SizeTransition 改的是尺寸展开过程，适合理解动画如何影响布局空间。',
      _TransitionType.hero =>
        'Hero 不只依赖 route transition，它会寻找两个页面相同 tag 的 Widget 做共享元素动画。',
      _TransitionType.containerTransform =>
        'Container Transform 的关键是让用户觉得“点开的卡片就是详情页本身”。这里用缩放和淡入模拟容器展开。',
      _TransitionType.heroHeader => 'Hero Header 常用于图片、头像或作品封面飞到详情页头部，建立对象连续性。',
      _TransitionType.staggered =>
        'Staggered Animation 让内容分批出现。它常和 Hero 配合：主体先到位，文字和按钮再跟上。',
      _TransitionType.collapsingHeader =>
        'Collapsing Header 用 SliverAppBar 表达：大头图展开时沉浸，滚动后折叠成导航栏。',
      _TransitionType.parallaxHeader =>
        'Parallax Header 让背景移动得比内容慢，滚动时会产生前后空间层次。',
      _TransitionType.sharedAxisZ =>
        'Shared Axis Z 用缩放和淡入表达前后层级推进，适合设置页、步骤页、功能层级切换。',
      _TransitionType.fadeThrough =>
        'Fade Through 会让新内容稍晚出现，适合两个没有空间连续关系的功能区切换。',
      _TransitionType.animatedContainer =>
        'AnimatedContainer 不是页面转场，而是同一个页面内的属性动画，适合卡片展开和面板状态变化。',
    };
  }
}
