import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_flutter/main.dart';

void main() {
  testWidgets('Home page lists learning chapter entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter 学习目录'), findsOneWidget);
    expect(find.text('03 Widget 生命周期'), findsOneWidget);
    expect(find.text('04 布局案例实验室'), findsOneWidget);
    expect(find.text('05 状态管理与 Riverpod'), findsOneWidget);
    expect(find.text('06 转场动画实验室'), findsOneWidget);
    expect(find.text('07 路由导航与页面组织'), findsOneWidget);
  });

  testWidgets(
    'Lifecycle demo counter increments and reacts to config changes',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('03 Widget 生命周期'));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(
        find.text('You have pushed the button this many times:'),
        findsOneWidget,
      );
      expect(find.text('你已经点击按钮这么多次：'), findsNothing);

      await tester.tap(find.text('切换外部文案'));
      await tester.pump();

      expect(
        find.text('You have pushed the button this many times:'),
        findsNothing,
      );
      expect(find.text('你已经点击按钮这么多次：'), findsOneWidget);
    },
  );

  testWidgets('Layout lab opens a classic layout case', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('04 布局案例实验室'));
    await tester.pumpAndSettle();

    expect(find.text('经典布局清单'), findsOneWidget);

    await tester.tap(find.text('基础居中布局'));
    await tester.pumpAndSettle();

    expect(find.text('Center + Column'), findsOneWidget);
    expect(find.text('居中的操作按钮'), findsOneWidget);
  });

  testWidgets('Every layout lab case can be opened', (
    WidgetTester tester,
  ) async {
    const caseTitles = [
      '基础居中布局',
      '横向信息卡',
      '比例分栏',
      '卡片列表',
      '两列网格',
      '图片遮罩叠层',
      '固定头部滚动区',
      '响应式布局',
      '安全区布局',
    ];

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('04 布局案例实验室'));
    await tester.pumpAndSettle();

    for (final title in caseTitles) {
      final titleFinder = find.text(title);

      await tester.ensureVisible(titleFinder);
      await tester.tap(titleFinder);
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Riverpod lab filters and updates task state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('05 状态管理与 Riverpod'));
    await tester.pumpAndSettle();

    expect(find.text('状态管理练习顺序'), findsOneWidget);
    expect(find.text('01 StatefulWidget + setState'), findsOneWidget);
    expect(find.text('02 NotifierProvider'), findsOneWidget);
    expect(find.text('03 Provider 派生数据'), findsOneWidget);
    expect(find.text('04 FutureProvider'), findsOneWidget);
    expect(find.text('05 AsyncNotifier + repository'), findsOneWidget);
    expect(find.text('06 综合任务看板'), findsOneWidget);

    await tester.tap(find.text('06 综合任务看板'));
    await tester.pumpAndSettle();

    expect(find.text('任务状态看板'), findsOneWidget);
    expect(find.text('全部 3'), findsOneWidget);
    expect(find.text('进行中 2'), findsOneWidget);
    expect(find.text('已完成 1'), findsOneWidget);
    expect(
      find.text('watch：页面订阅任务列表和筛选条件；read：按钮点击时修改状态；listen：筛选变化时弹 SnackBar。'),
      findsOneWidget,
    );

    await tester.tap(find.text('新增任务'));
    await tester.pumpAndSettle();

    expect(find.text('全部 4'), findsOneWidget);
    expect(find.text('进行中 3'), findsOneWidget);
    expect(find.textContaining('新建的 Riverpod 练习任务 004'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, '已完成'));
    await tester.pumpAndSettle();

    expect(find.text('listen：筛选条件切换为「已完成」'), findsOneWidget);
    expect(find.textContaining('生成一张魔法卡片封面'), findsOneWidget);
  });

  testWidgets('State management single examples can be opened', (
    WidgetTester tester,
  ) async {
    const exampleTitles = [
      '01 StatefulWidget + setState',
      '02 NotifierProvider',
      '03 Provider 派生数据',
      '04 FutureProvider',
      '05 AsyncNotifier + repository',
    ];

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('05 状态管理与 Riverpod'));
    await tester.pumpAndSettle();

    for (final title in exampleTitles) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('setState and AsyncNotifier repository examples handle actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('05 状态管理与 Riverpod'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('01 StatefulWidget + setState'));
    await tester.pumpAndSettle();
    expect(find.text('本地点击次数：0'), findsOneWidget);

    await tester.tap(find.text('setState 加一'));
    await tester.pump();
    expect(find.text('本地点击次数：1'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('05 AsyncNotifier + repository'));
    await tester.pumpAndSettle();
    expect(find.textContaining('repository 第'), findsOneWidget);

    await tester.tap(find.byTooltip('模拟错误'));
    await tester.pumpAndSettle();
    expect(find.textContaining('模拟接口失败'), findsOneWidget);

    await tester.tap(find.text('从 repository 重新加载'));
    await tester.pumpAndSettle();
    expect(find.textContaining('repository 第'), findsOneWidget);
  });

  testWidgets('Transition lab opens every transition demo', (
    WidgetTester tester,
  ) async {
    const demoTitles = [
      'SlideTransition',
      'FadeTransition',
      'ScaleTransition',
      'RotationTransition',
      'SizeTransition',
      'Container Transform',
      'Hero Header',
      'Hero + Staggered',
      'Collapsing Header',
      'Parallax Header',
      'Shared Axis Z',
      'Fade Through',
      'AnimatedContainer',
      'Hero',
    ];

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('06 转场动画实验室'));
    await tester.pumpAndSettle();

    expect(find.text('PageRouteBuilder 转场'), findsOneWidget);

    for (final title in demoTitles) {
      final titleFinder = find.text(title).first;

      await tester.ensureVisible(titleFinder);
      await tester.tap(titleFinder);
      await tester.pumpAndSettle();

      expect(find.text(title), findsWidgets);
      expect(tester.takeException(), isNull);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Route lab opens and redirects protected detail to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('07 路由导航与页面组织'));
    await tester.pumpAndSettle();

    expect(find.text('07 路由导航实验室'), findsOneWidget);
    expect(find.text('go_router 多页面练习'), findsOneWidget);
    expect(find.text('读取 path 参数'), findsOneWidget);
    expect(find.text('Android 预测返回'), findsNothing);
    expect(find.textContaining('未登录，详情页会被 redirect'), findsOneWidget);

    await tester.tap(find.text('读取 path 参数'));
    await tester.pumpAndSettle();

    expect(find.text('模拟登录页'), findsOneWidget);
    expect(find.text('redirect 练习'), findsOneWidget);

    await tester.tap(find.text('模拟登录并返回原页面'));
    await tester.pumpAndSettle();

    expect(find.text('路由详情页'), findsOneWidget);
    expect(find.text('详情：task-101'), findsOneWidget);
    expect(find.text('path 参数 taskId'), findsOneWidget);
    expect(find.text('task-101'), findsWidgets);
    expect(find.text('query 参数 tab'), findsOneWidget);
    expect(find.text('notes'), findsOneWidget);
    expect(find.text('extra 是否存在'), findsOneWidget);
    expect(find.text('否'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('07 路由导航实验室'), findsOneWidget);

    await tester.tap(find.text('读取 path 参数'));
    await tester.pumpAndSettle();
    expect(find.text('路由详情页'), findsOneWidget);

    await tester.tap(find.text('回到路由实验室'));
    await tester.pumpAndSettle();

    expect(find.text('07 路由导航实验室'), findsOneWidget);
  });

  testWidgets('Route lab passes extra when already logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('07 路由导航与页面组织'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('模拟登录'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('区分 query 和 extra'));
    await tester.pumpAndSettle();

    expect(find.text('详情：task-102'), findsOneWidget);
    expect(find.text('query 参数 tab'), findsOneWidget);
    expect(find.text('notes'), findsOneWidget);
    expect(find.text('extra 是否存在'), findsOneWidget);
    expect(find.text('是'), findsOneWidget);
    expect(find.text('区分 query 和 extra'), findsOneWidget);
  });

  testWidgets('Route lab receives create page result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('07 路由导航与页面组织'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('打开创建页'));
    await tester.pumpAndSettle();

    expect(find.text('创建路由任务'), findsOneWidget);
    expect(find.text('返回值练习'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '从测试返回的新任务');
    await tester.enterText(find.byType(TextField).last, '测试 pop(result) 的返回值');
    await tester.tap(find.text('创建并返回列表'));
    await tester.pumpAndSettle();

    expect(find.text('07 路由导航实验室'), findsOneWidget);
    expect(find.text('从测试返回的新任务'), findsOneWidget);
    expect(find.textContaining('已从创建页接收返回值：从测试返回的新任务'), findsOneWidget);
  });

  testWidgets('Route search page reads and updates query parameters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('07 路由导航与页面组织'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('用 query 搜索'));
    await tester.pumpAndSettle();

    expect(find.text('query 参数搜索页'), findsOneWidget);
    expect(find.text('当前 query：riverpod'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'go_router');
    await tester.tap(find.text('更新 query'));
    await tester.pumpAndSettle();

    expect(find.text('当前 query：go_router'), findsOneWidget);

    await tester.tap(find.byTooltip('回到学习首页'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter 学习目录'), findsOneWidget);
  });
}
