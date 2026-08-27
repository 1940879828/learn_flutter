# 12 flutter-spell-ai 接手导读 - 教学正文

这一章不是“学 Flutter”的内容，而是“把 Flutter 能力接回真实项目”的操作说明。

## 先看结论

你接手这个项目时，优先顺序应该是：

1. 入口
2. 路由
3. 状态
4. 网络
5. 模型
6. 媒体

## 练习文件

- `notes/12-flutter-spell-ai接手导读.md`
- `/Users/dev/Documents/Projects/flutter-spell-ai`

## 本章教学闭环

这章不是写代码，而是建立接手时的导航系统。

```text
入口
→ App 初始化
→ ProviderScope / MaterialApp.router
→ PageKeys / routes
→ 页面参数
→ API / model
→ 媒体 / 文件 / 权限
→ 测试和工程门禁
```

你不需要第一天读懂所有页面。你需要先知道自己站在哪里，以及改动会影响哪些边界。

## 第 1 步：先只读不改

先别急着动功能。

先看：

- 入口在哪里
- 启动流程怎么走
- 页面之间怎么跳
- 数据从哪来

## 第 2 步：先画执行路径

你要尽量回答出这几个问题：

- 程序从哪启动
- 初始化放在哪
- 路由怎么组织
- 全局状态怎么注入

本轮读到的执行路径：

1. `main.dart` 设置生产环境，`main_debug.dart` 设置测试环境。
2. 两者都调用 `initMain`。
3. `initMain` 先 `deferFirstFrame`，等待 `App().init()`，再 `runApp(const AppScopedView())`。
4. `AppScopedView` 构建 `ProviderScope` 和 `MaterialApp.router`。
5. 路由来自全局 `appRouter`，页面路径集中在 `PageKeys` 和 `routers.dart`。
6. 页面再调用 `ApiService`、model、pool/provider、媒体工具和本地存储。

## 第 3 步：先找低风险切入点

第一次改目标项目，建议从低风险开始：

- 文案
- 样式
- 小组件

先不要碰支付、登录、Firebase、权限、数据库迁移这类高风险链路。

低风险不是“看起来代码少”，而是满足这些条件：

- 不改变 API 入参和返回解析。
- 不改变持久化格式。
- 不改变权限请求时机。
- 不改变播放器/controller 生命周期。
- 不影响登录、支付、广告、打点。
- 能用一个页面操作或一个 focused test 验证。

## 第 4 步：媒体链路要单独看

这个项目后面一定会碰到：

- 图片
- 视频
- 相册保存
- 权限

这些东西要先看完整链路，再动手。

媒体链路第一轮只读顺序：

1. `video_player_controllers.dart`：asset/file/network/uri 如何创建 controller。
2. `v_create_page.dart`：I2V/E2V/T2V tab 如何组织。
3. `params/`：创建页入参如何建模。
4. `providers/`：渲染状态如何流动。
5. `media/result_video_player.dart`：结果视频如何播放和释放。
6. `album_utils.dart`：图片/视频如何保存到系统相册。
7. `images_helper.dart`：图片如何选择、保存到内部目录、读取尺寸。

## 第 5 步：准备你的接手笔记

你可以把这些问题记下来：

- 入口文件是哪几个
- 主要路由文件在哪
- 主要 provider/pool 在哪
- 主要 model 在哪
- 媒体功能在哪

## 第 6 步：回到目标项目

先按下面顺序看：

1. `README.md`
2. `AGENTS.md`
3. `pubspec.yaml`
4. `lib/main.dart`
5. `lib/entry.dart`
6. `lib/app.dart`
7. `lib/routing/`
8. `lib/model/`
9. `lib/repository/`
10. `lib/ui/pages/image2video/`

本轮已完成只读观察：

- 入口和 debug/prod 环境差异已定位。
- `App().init()` 的全局初始化职责已定位。
- `PageKeys`、`AppRoute`、`AdaptiveRoute` 的路由组织已定位。
- 远程 API 大入口 `lib/repository/remote/api.dart` 已定位。
- model 和 `*.g.dart` 生成文件边界已定位。
- image2video 页面、provider、params、media 子目录已定位。
- 相册保存、图片内部存储、视频 controller 封装已定位。
- 目标项目自定义 lint 和严格 analyzer 规则已定位。

## 完成标准

- 能快速说出项目的执行路径。
- 能找到每个大模块的边界。
- 能判断一个改动是不是高风险。
- 能说出第一批适合练手的小功能类型。
- 能说出暂时不要碰的模块和原因。
- 能在修改前选择对应工程门禁：pub get、analyze、test、build_runner、gen-l10n。

## QA 问答

### Q1：接手项目时先看什么？
入口、路由、状态、网络、模型，再看核心业务页。

### Q2：为什么要先只读不改？
因为先建立路径图，后面修改才不会误伤。

### Q3：什么算高风险区域？
支付、登录、权限、数据库迁移、媒体链路、原生配置。

### Q4：为什么要先改低风险页面？
这样能先熟悉项目风格和流程，减少第一次改动的回滚成本。

### Q5：接手时最有用的习惯是什么？
把“文件在哪里”变成“执行路径是什么”。
