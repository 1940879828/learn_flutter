# 05 状态管理与 Riverpod - 教学正文

这一章的核心是：状态不是一坨东西，而是分层的。你要知道哪些状态放本地，哪些状态上提，哪些状态应该让 Riverpod 管。

## 先看结论

先把状态分成四类：

1. 局部 UI 状态
2. 页面状态
3. 全局服务状态
4. 远程数据状态

## 练习文件

- `notes/05-状态管理与Riverpod.md`
- `lib/chapter_05/state_management_lab_page.dart`
- 目标项目里的 `lib/app.dart` 和 `lib/pool/`

## 本章练习页面

项目首页现在有 `05 状态管理与 Riverpod` 入口。

这个练习页模拟了 `flutter-spell-ai` 里常见的“生成任务列表”：

- 任务列表状态：`spellTaskListProvider`
- 筛选条件状态：`taskFilterProvider`
- 异步远程提示：`remoteHintProvider`
- 派生统计数据：`taskSummaryProvider`
- 派生筛选列表：`filteredTasksProvider`

学习时重点看三条线：

1. `ref.watch(...)`：页面订阅状态，状态变了 UI 自动重建。
2. `ref.read(...)`：按钮点击时读取 controller，然后触发状态更新。
3. `ref.listen(...)`：状态变化时做副作用，比如弹出 SnackBar。

你可以先运行页面，然后按这个顺序练：

1. 点 `新增任务`，观察统计数字和列表变化。
2. 点筛选 chip，观察列表过滤和 SnackBar。
3. 点任务右侧的完成按钮，观察任务状态和统计数字变化。
4. 点远程提示右侧刷新按钮，观察 `FutureProvider` 重新加载。
5. 回到代码里找 `NotifierProvider`、`FutureProvider` 和 `Provider` 分别负责什么。

## 第 1 步：先分清状态类型

最容易犯的错是“什么都往全局放”。

你应该先问：

- 这个状态只影响一个按钮吗？
- 这个状态影响整个页面吗？
- 这个状态要跨页面共享吗？
- 这个状态是网络来的数据吗？

答案不同，放的位置也不同。

## 第 2 步：理解 Riverpod 的基本角色

Riverpod 可以把它理解成：

- 依赖注入
- 状态管理
- 可测试的数据流

它最重要的不是 API 名字，而是“依赖声明”这件事。

## 第 3 步：先会 watch / read / listen

你只要先记住：

- `watch`：订阅变化
- `read`：只读一次
- `listen`：监听副作用

很多页面逻辑其实都卡在这里。

## 第 4 步：先做一个最小任务列表

建议你做：

- 一个 `FutureProvider` 模拟加载任务
- 一个 `NotifierProvider` 控制筛选条件
- 一个刷新按钮
- 一个 loading / error / empty 状态展示

重点不是界面，而是状态流转。

当前项目里的 05 章练习已经实现了这个任务列表的最小版本。你后续可以继续扩展：

- 增加 `error` 状态。
- 增加异步加载状态。
- 把新增任务从固定文案改成输入框。
- 把 `SpellTaskStatus.running` 改成定时完成，练 `dispose` 和异步取消。

## 第 5 步：理解 ProviderScope

`ProviderScope` 是 Riverpod 的作用域边界。

你可以把它理解成：

- 这里定义了 provider 能活多久
- 这里决定状态是否共享
- 这里影响测试和隔离

## 第 6 步：理解 Notifier / AsyncNotifier

当状态开始有“更新逻辑”，就不要把逻辑堆在 Widget 里。

把它挪进 `Notifier` 或 `AsyncNotifier`，通常更可测，也更好维护。

## 第 7 步：回到目标项目

优先读：

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/app.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/pool/video_filter_pool.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/pool/diffusion_model_pool.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/photo_lab/prompt/provider/`

重点看：

1. 哪些数据被抽成 pool。
2. 哪些远程配置用 provider 加载。
3. provider 生命周期怎么影响页面。

## 完成标准

- 能解释 `watch/read/listen` 的区别。
- 能独立写一个简单 Riverpod demo。
- 能看懂目标项目一个 provider 的数据来源和消费者。

## QA 问答

### Q1：为什么状态管理不能全塞进 Widget？
因为 Widget 负责描述 UI，不适合承载复杂副作用和跨页面状态。

### Q2：`FutureProvider` 适合什么？
适合一次性异步数据，比如配置、列表加载、远程初始化。

### Q3：简单筛选条件适合放哪里？
旧版 Riverpod 常用 `StateProvider` 表达筛选条件、开关、单值输入。当前项目接入的是 Riverpod 3，所以练习代码用 `NotifierProvider` 表达同类状态。

### Q4：为什么 `Notifier` 更适合业务逻辑？
因为它把状态修改集中起来了，测试和维护都更稳。

### Q5：为什么 Riverpod 在 Flutter 项目里很常见？
因为它兼顾了依赖声明、生命周期管理和可测试性，适合中大型项目。
