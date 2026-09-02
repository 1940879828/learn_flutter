import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_flutter/chapter_08/async_network_lab_page.dart';
import 'package:learn_flutter/chapter_08/spell_generation_models.dart';
import 'package:learn_flutter/chapter_09/local_storage_lab_page.dart';
import 'package:learn_flutter/chapter_09/local_storage_models.dart';
import 'package:learn_flutter/chapter_10/media_lab_page.dart';
import 'package:learn_flutter/chapter_13/localization_lab_page.dart';
import 'package:learn_flutter/chapter_13/localization_models.dart';
import 'package:learn_flutter/chapter_14/fake_firebase_auth_models.dart';
import 'package:learn_flutter/chapter_14/firebase_auth_lab_page.dart';
import 'package:learn_flutter/chapter_14/spellai_auth_models.dart';
import 'package:learn_flutter/main.dart';

void main() {
  test('SpellGenerationTask supports JSON roundtrip', () {
    final task = SpellGenerationTask(
      id: 'draw_101',
      prompt: 'Crystal mage portrait',
      previewUrl: 'https://example.com/draw_101.png',
      status: SpellGenerationStatus.completed,
      createdAt: DateTime.utc(2026, 8, 27, 9, 20),
    );

    final decoded = SpellGenerationTask.fromJson(task.toJson());

    expect(decoded.id, task.id);
    expect(decoded.prompt, task.prompt);
    expect(decoded.previewUrl, task.previewUrl);
    expect(decoded.status, task.status);
    expect(decoded.createdAt, task.createdAt);
  });

  test('JsonPromptFileStore writes and reads prompt records', () async {
    final directory = await Directory.systemTemp.createTemp(
      'learn_flutter_storage_test_',
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final store = JsonPromptFileStore(directory: directory);
    final file = await store.writeRecords([
      PromptRecord(
        id: 'prompt_1',
        prompt: '测试 prompt',
        createdAt: DateTime.utc(2026, 8, 27, 10),
      ),
    ]);

    final records = await store.readRecords(file);

    expect(records, hasLength(1));
    expect(records.single.id, 'prompt_1');
    expect(records.single.prompt, '测试 prompt');
  });

  test('LearningMessageCatalog handles placeholders and fallback', () {
    const zhCatalog = LearningMessageCatalog(LearningLocale.zh);
    final zhPreview = zhCatalog.preview(name: 'Mia', count: 3);

    expect(zhPreview['welcome'], '欢迎回来，Mia');
    expect(zhPreview['credits'], '剩余 3 个金币');
    expect(zhPreview['fallback'], 'Fallback text from English');
  });

  test('FakeFirebaseAuthService signs in fails and signs out', () async {
    final service = FakeFirebaseAuthService();
    addTearDown(service.dispose);

    final failure = await service.signIn(
      FakeAuthProvider.google,
      failProvider: true,
    );
    expect(failure.state, FakeLoginState.authFailed);
    expect(failure.logged, isFalse);

    final success = await service.signIn(FakeAuthProvider.google);
    expect(success.state, FakeLoginState.signedIn);
    expect(success.user?.provider, FakeAuthProvider.google);

    final repeated = await service.signIn(FakeAuthProvider.apple);
    expect(repeated.state, FakeLoginState.signedIn);
    expect(repeated.user?.provider, FakeAuthProvider.google);

    service.signOut();
    expect(service.current.state, FakeLoginState.idle);
    expect(service.current.logged, isFalse);
  });

  test('FakeFirebaseAuthService handles backend failure and cancel', () async {
    final service = FakeFirebaseAuthService();
    addTearDown(service.dispose);

    final backendFailure = await service.signIn(
      FakeAuthProvider.line,
      failBackend: true,
    );
    expect(backendFailure.state, FakeLoginState.backendFailed);
    expect(backendFailure.logged, isFalse);

    final pending = service.signIn(FakeAuthProvider.facebook);
    service.cancel();
    final canceled = await pending;

    expect(canceled.state, FakeLoginState.canceled);
    expect(canceled.logged, isFalse);
    expect(service.current.state, FakeLoginState.canceled);
  });

  test(
    'FakeFirebaseAuthService ignores pending sign in after dispose',
    () async {
      final service = FakeFirebaseAuthService();
      final signIn = service.signIn(FakeAuthProvider.line);

      service.dispose();
      final snapshot = await signIn;

      expect(snapshot.state, FakeLoginState.logging);
      expect(snapshot.logged, isFalse);
    },
  );

  test('SpellAiTokenSnapshot reads JWT payload without exposing raw token', () {
    const header = 'eyJhbGciOiJub25lIn0';
    const payload =
        'eyJpYXQiOjE3ODc4MDAwMDAsImV4cCI6MTc4NzgwMzYwMCwiZmlyZWJhc2UiOnsic2lnbl9pbl9wcm92aWRlciI6Imdvb2dsZS5jb20ifX0';
    const signature = 'signature';
    const token = '$header.$payload.$signature';

    final snapshot = SpellAiTokenSnapshot.fromIdToken(
      uid: 'firebase_uid',
      idToken: token,
    );

    expect(snapshot.uid, 'firebase_uid');
    expect(snapshot.signInProvider, 'google.com');
    expect(
      snapshot.expiresAt,
      DateTime.fromMillisecondsSinceEpoch(1787803600000, isUtc: true),
    );
    expect(snapshot.maskedIdToken, isNot(contains(payload)));
  });

  test('SpellAiUserInfo maps backend user json and preserves raw data', () {
    final user = SpellAiUserInfo.fromJson({
      'custom_uid': 'custom_123',
      'user_name': 'Mia',
      'user_icon': 'https://example.com/avatar.png',
      'is_vip': true,
      'draw_num': 18,
      'daily_ad_limit': 2,
      'flag': 1,
      'subscribed_product_ids': ['spellai_yearly'],
      'use_coin_discount': true,
      'is_lifetime_vip': false,
      'remaining_chat_times': 7,
      'spark_remaining_chat_times': 5,
      'muse_remaining_chat_times': 3,
      'registered_version': '1.0.0',
      'extra_field': 'kept for full JSON display',
    });

    expect(user.uuid, 'custom_123');
    expect(user.userName, 'Mia');
    expect(user.isVip, isTrue);
    expect(user.subscribedProductIds, ['spellai_yearly']);
    expect(user.chatMuseAvailableCount, 3);
    expect(user.rawJson['extra_field'], 'kept for full JSON display');
  });

  testWidgets('Home page lists learning chapter entries', (
    WidgetTester tester,
  ) async {
    await _pumpLearningApp(tester);

    expect(find.text('Flutter 学习目录'), findsOneWidget);
    expect(find.text('03 Widget 生命周期'), findsOneWidget);
    expect(find.text('04 布局案例实验室'), findsOneWidget);
    expect(find.text('05 状态管理与 Riverpod'), findsOneWidget);
    expect(find.text('06 转场动画实验室'), findsOneWidget);
    expect(find.text('07 路由导航与页面组织'), findsOneWidget);

    for (final title in [
      '08 异步网络数据模型',
      '09 本地存储权限与文件',
      '10 音视频与媒体能力',
      '11 工程化调试测试构建',
      '13 多语言与本地化',
      '14 Firebase 登录与账号状态',
      '15 聊天键盘上移动画',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets(
    'Lifecycle demo counter increments and reacts to config changes',
    (WidgetTester tester) async {
      await _pumpLearningApp(tester);

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
    await _pumpLearningApp(tester);

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

    await _pumpLearningApp(tester);
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
    await _pumpLearningApp(tester);

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

    await _pumpLearningApp(tester);
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
    await _pumpLearningApp(tester);
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

    await _pumpLearningApp(tester);
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
    await _pumpLearningApp(tester);

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
    await _pumpLearningApp(tester);

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
    await _pumpLearningApp(tester);

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
    await _pumpLearningApp(tester);

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

  testWidgets('New chapter entries from 08 to 14 can be opened', (
    WidgetTester tester,
  ) async {
    final chapters = <String, String>{
      '08 异步网络数据模型': '模拟 SpellAI 请求链路',
      '09 本地存储权限与文件': '本地能力拆成三块',
      '10 音视频与媒体能力': '媒体来源与生命周期',
      '11 工程化调试测试构建': '改动前后的门禁清单',
      '13 多语言与本地化': '多语言字典实验',
      '14 Firebase 登录与账号状态': 'Firebase 登录链路模拟',
    };

    for (final entry in chapters.entries) {
      await _pumpLearningApp(tester);
      await tester.scrollUntilVisible(
        find.text(entry.key),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('回到学习首页'));
      await tester.pumpAndSettle();
      expect(find.text('Flutter 学习目录'), findsOneWidget);
    }
  });

  testWidgets('Chapter 15 chat page renders keyboard-driven chat surface', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await _pumpLearningApp(tester);
    await tester.scrollUntilVisible(
      find.text('15 聊天键盘上移动画'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('15 聊天键盘上移动画'));
    await tester.pumpAndSettle();

    expect(find.text('15 聊天键盘上移复刻'), findsOneWidget);
    expect(find.text('SpellAI Assistant'), findsOneWidget);
    expect(find.textContaining('点击输入框，观察 native 逐帧 inset'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(Transform), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Async network lab renders loading success and error states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AsyncNetworkLabPage()));

    expect(find.text('loading：正在模拟请求任务列表'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('success：共 3 个任务'), findsOneWidget);
    expect(find.textContaining('Crystal mage portrait'), findsOneWidget);

    await tester.tap(find.text('模拟错误'));
    await tester.pump();
    expect(find.text('loading：正在模拟请求任务列表'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('error：模拟 DioException'), findsOneWidget);
  });

  testWidgets('Async network lab ignores stale responses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AsyncNetworkLabPage()));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('模拟错误'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('重新加载成功'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('success：共 3 个任务'), findsOneWidget);
    expect(find.textContaining('error：模拟 DioException'), findsNothing);
  });

  testWidgets('Local storage lab saves prompt and switches permission', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const MaterialApp(home: LocalStorageLabPage()));

    await tester.enterText(find.byType(TextField), '测试 prompt');
    await tester.tap(find.text('保存最近 prompt'));
    await tester.pumpAndSettle();

    expect(find.text('测试 prompt'), findsWidgets);

    for (var i = 0; i < 6; i++) {
      if (find.text('部分授权').evaluate().isNotEmpty) {
        break;
      }
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('部分授权'));
    await tester.pumpAndSettle();

    expect(find.text('当前状态：部分授权'), findsOneWidget);
    expect(find.textContaining('iOS limited'), findsOneWidget);
  });

  testWidgets('Media lab switches source preview and video lifecycle', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const MaterialApp(home: MediaLabPage()));

    expect(find.text('当前来源：asset'), findsOneWidget);

    await tester.tap(find.text('network'));
    await tester.pumpAndSettle();
    expect(find.text('当前来源：network'), findsOneWidget);

    await tester.tap(find.text('模拟选择 file 图片'));
    await tester.pumpAndSettle();
    expect(find.text('file 图片预览'), findsOneWidget);

    expect(find.text('状态：未初始化'), findsOneWidget);

    await tester.tap(find.text('play'));
    await tester.pump();
    expect(find.text('play() ignored: not ready'), findsOneWidget);

    await tester.tap(find.text('initialize'));
    await tester.pump();
    expect(find.text('状态：初始化中'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('状态：已就绪'), findsOneWidget);

    await tester.tap(find.text('play'));
    await tester.pump();
    expect(find.text('状态：播放中'), findsOneWidget);

    await tester.tap(find.text('pause'));
    await tester.pump();
    expect(find.text('状态：已暂停'), findsOneWidget);
  });

  testWidgets('Localization lab switches locale and updates placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LocalizationLabPage())),
    );

    expect(find.text('当前 locale：en'), findsOneWidget);
    expect(find.text('Create with SpellAI'), findsOneWidget);
    expect(find.text('12 credits left'), findsOneWidget);

    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();

    expect(find.text('当前 locale：zh'), findsOneWidget);
    expect(find.text('用 SpellAI 创作'), findsOneWidget);
    expect(find.text('剩余 12 个金币'), findsOneWidget);
    expect(find.textContaining('Fallback text from English'), findsOneWidget);

    await tester.tap(find.text('模拟消耗 1 个金币'));
    await tester.pumpAndSettle();

    expect(find.text('剩余 11 个金币'), findsOneWidget);
  });

  testWidgets('Firebase auth lab signs in fails and signs out', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const MaterialApp(home: FirebaseAuthLabPage()));

    expect(find.text('状态：未登录'), findsOneWidget);

    await tester.tap(find.text('Google'));
    await tester.pump();
    expect(find.text('状态：登录中'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('状态：已登录'), findsOneWidget);
    expect(find.text('provider：google.com'), findsOneWidget);

    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    expect(find.text('状态：未登录'), findsOneWidget);

    await tester.tap(find.text('模拟供应商认证失败'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('状态：供应商认证失败'), findsOneWidget);

    await tester.tap(find.text('模拟供应商认证失败'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('模拟后端创建用户失败'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LINE'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('状态：后端创建用户失败'), findsOneWidget);
  });
}

Future<void> _pumpLearningApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: MyApp()));
}
