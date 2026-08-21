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

      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
