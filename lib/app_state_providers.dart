import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_flutter/app_router.dart';
import 'package:learn_flutter/chapter_07/route_lab_models.dart';

final appLocaleProvider = StateProvider<Locale?>((ref) {
  return null;
});

final appThemeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// 用 Riverpod 创建并托管一个 RouteLabSession 实例。
final routeLabSessionProvider = Provider<RouteLabSession>((ref) {
  final session = RouteLabSession();
  // 当这个 Provider 被 Riverpod 销毁时，顺便调用：
  ref.onDispose(session.dispose);
  return session;
});

// 用 Riverpod 创建并托管一个 RouteLabSession 实例。
final appRouterProvider = Provider<GoRouter>((ref) {
  // 拿实例
  final session = ref.watch(routeLabSessionProvider);
  final router = createLearningRouter(session);
  ref.onDispose(router.dispose);
  return router;
});
