# 05 状态管理与 Riverpod

## 学习目标

- 理解 Flutter 状态的分类：局部 UI 状态、页面状态、全局服务状态、远程数据状态。
- 掌握 Riverpod 的基本使用。
- 为阅读目标项目的 provider、pool、service 打基础。

## Web 前端迁移映射

- React `useState` / Vue `ref` 类似局部状态。
- React Query / SWR 的远程数据缓存心智可迁移到 Riverpod 的 provider。
- Pinia/Zustand/Redux 的全局状态心智可迁移，但 Riverpod 更强调依赖声明和可测试性。
- hooks_riverpod 和 React hooks 名字相似，但依赖生命周期由 Flutter/Riverpod 管理。

## 核心概念清单

- `ProviderScope`
- `Provider`
- `FutureProvider`
- `StreamProvider`
- `Notifier` / `AsyncNotifier`
- `NotifierProvider`
- `ref.watch`、`ref.read`、`ref.listen`
- provider dispose 和缓存
- provider 命名、调试日志

## 最小练习

做一个任务列表：

- `FutureProvider` 模拟拉取任务列表。
- `NotifierProvider` 控制筛选条件和任务列表。
- 一个按钮触发刷新。
- 加载、错误、空状态都要展示。

当前代码练习拆成多个独立页面：

- `case_00_state_management_lab_page.dart`：05 章案例目录页。
- `case_01_set_state_example_page.dart`：对应 `01 StatefulWidget + setState`。
- `case_02_notifier_provider_example_page.dart`：对应 `02 NotifierProvider`。
- `case_03_provider_example_page.dart`：对应 `03 Provider 派生数据`。
- `case_04_future_provider_example_page.dart`：对应 `04 FutureProvider`。
- `case_05_async_notifier_repository_example_page.dart`：对应 `05 AsyncNotifier + repository`。
- `case_06_comprehensive_task_board_page.dart`：对应 `06 综合任务看板`。

## 目标项目观察

优先阅读：

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/app.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/pool/video_filter_pool.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/pool/diffusion_model_pool.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/photo_lab/prompt/provider/`

观察问题：

- 目标项目哪些数据被抽象成 pool？
- `FutureProvider` 用来加载哪些远程配置？
- provider 的生命周期是否影响页面返回、刷新、缓存？

## 完成标准

- 能解释 `watch/read/listen` 的区别。
- 能独立写一个 Riverpod demo。
- 能读懂目标项目一个 provider 的数据来源和消费者。

## QA 问答

### Q1：Flutter 状态管理常见分类有哪些？
常见分法有局部 UI 状态、共享页面状态、应用级状态、服务/数据层状态。面试时通常考你什么时候用哪一层，避免过度上提共享状态。

### Q2：`ref.watch` 和 `ref.read` 什么时候用？
`watch` 会订阅变化并触发重建；`read` 用于一次性读取或触发动作，常见在按钮事件里读 provider 而不建立订阅。

### Q3：`ProviderScope` 的作用是什么？
它定义了 provider 的作用域边界，限定了依赖注入和状态生命周期。复杂页面常用嵌套 scope 控制状态隔离。

### Q4：为什么会用 `StateNotifier/AsyncNotifier`？
适合将状态更新逻辑集中在一个可测试、可组合的类中，避免在 widget 里堆积副作用和状态切片。Riverpod 3 中更推荐先看 `Notifier` / `AsyncNotifier` 这条线。

### Q5：Rivers/ Riverpod 怎么做异步数据？
`AsyncValue` 配合 `FutureProvider`/`AsyncNotifier` 表达 loading/error/data 三态，天然适配 UI 的异步反馈。
