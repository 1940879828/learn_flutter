# 05 状态管理与 Riverpod - 闯关练习

## 练习目标

这份练习不是再做一个完整教程，而是把第五章拆成一组小关卡。每一关只练一个判断点，最后自然合成一个极简任务面板。

你当前的主要卡点是：provider 类型、`watch` / `read` / `listen`、异步状态这些单点还容易混。所以本练习先不追求复杂 UI，也不追求一次写完。

## 总原则

- UI 极简，只保留能观察状态变化的文字、按钮、列表。
- 每关先回答“状态放哪里”，再敲代码。
- 每关只新增一个核心概念。
- 不先看最终答案；先按提示自己敲，再对照已有案例修正。
- 所有练习代码优先放在 `lib/chapter_05/`。

## 最终小案例

案例名：极简生成任务面板。

界面只需要这些内容：

- 一个标题。
- 一个当前筛选条件。
- 一个任务数量统计。
- 一个任务列表。
- 三到四个按钮：刷新、切换筛选、添加本地任务、模拟失败。
- 一个 SnackBar，用来观察副作用。

业务语义模拟 `flutter-spell-ai` 的生成任务列表，但不接真实接口：

- 任务可以是等待中、生成中、已完成、失败。
- 任务列表先来自假的异步 repository。
- 筛选条件是本地页面状态。
- 统计文案由任务列表派生。
- 按钮事件通过 controller 修改状态。

## 闯关路线

### 第 1 关：局部 UI 状态

核心问题：这个状态只影响当前页面的一小块 UI 吗？

只做一个按钮和一行文字：

- 文案显示当前选择的筛选条件。
- 按钮点击后在“全部”和“进行中”之间切换。
- 先使用 `StatefulWidget` 和 `setState`。

通过标准：

- 能说出为什么这一关暂时不需要 Riverpod。
- 能说出 `setState` 触发的是当前 `State` 对应子树重建。

### 第 2 关：同步状态上提到 NotifierProvider

核心问题：这个状态虽然简单，但修改逻辑是否应该从 Widget 移出去？

把第 1 关的筛选条件移动到 `NotifierProvider`：

- Widget 通过 `watch` 读取当前筛选条件。
- 按钮点击时通过 `read` 调用 controller 方法。
- UI 仍然只显示一行文字和一个按钮。

通过标准：

- 能说出 `watch` 为什么放在 build 里。
- 能说出按钮事件里为什么用 `read`。
- 能说出 controller 负责的是“怎么改状态”，Widget 负责的是“怎么展示状态”。

### 第 3 关：Provider 派生值

核心问题：这个值是不是可以从已有状态算出来，而不是单独存一份？

增加一个固定任务列表，并基于筛选条件派生展示列表：

- 原始任务列表先写成同步数据。
- 筛选条件仍然来自第 2 关的 provider。
- 新增一个 `Provider` 计算过滤后的任务列表。
- UI 显示过滤后的任务标题。

通过标准：

- 能说出为什么过滤后的列表不应该再单独存成状态。
- 能说出派生 `Provider` 依赖哪些 provider。
- 能说出源状态变化时，派生值如何自动更新。

### 第 4 关：FutureProvider 和 AsyncValue

核心问题：数据是不是来自一次性异步读取？

把固定任务列表改成假的异步加载：

- repository 延迟返回任务列表。
- `FutureProvider` 调用 repository。
- UI 使用 `AsyncValue` 展示 loading、error、data。
- 先不做新增、删除、复杂刷新。

通过标准：

- 能说出 `FutureProvider` 适合“一次性异步读取”。
- 能说出 UI 读到的是 `AsyncValue`，不是普通列表。
- 能独立解释 loading、error、data 三个分支。

### 第 5 关：AsyncNotifier + repository

核心问题：异步数据是否还需要动作方法，比如刷新、添加、失败重试？

把任务列表从 `FutureProvider` 升级到 `AsyncNotifierProvider`：

- repository 仍然是假数据源。
- controller 负责初次加载、刷新、添加本地任务、模拟失败。
- UI 仍然极简，只通过按钮触发动作。

通过标准：

- 能说出为什么这关不再只用 `FutureProvider`。
- 能说出 repository 和 controller 的分工。
- 能说出异步错误应该进入状态，而不是静默吞掉。

### 第 6 关：watch / read / listen 合流

核心问题：订阅、触发动作、副作用分别放在哪里？

在第 5 关基础上补齐三类使用：

- `watch`：页面展示任务列表、筛选条件、统计文案。
- `read`：按钮点击后调用刷新、添加、失败方法。
- `listen`：当任务添加成功或加载失败时弹 SnackBar。

通过标准：

- 能不用背定义，直接从使用场景判断 `watch` / `read` / `listen`。
- 能说出 SnackBar 为什么属于副作用。
- 能说出为什么不要在 build 里直接弹 SnackBar。

## 每关敲代码前的固定问题

每一关开始前，先回答这四个问题：

1. 这关的原始状态是什么？
2. 有没有派生状态？
3. 有没有异步 loading / error / data？
4. UI 里哪些地方需要 `watch`，哪些按钮事件只需要 `read`？

## 第 1 关开始提示

先新建一个独立练习页面，不急着挂到首页入口。

建议页面名：`ChallengeStateBasicsPage`。

先只实现最小 UI：

- Scaffold。
- AppBar 标题：`05 闯关 01 局部状态`。
- body 里一个 Column。
- 一行 Text 显示当前筛选。
- 一个按钮切换筛选。

这一关先不要引入 Riverpod。你要先体验“这个状态本来就可以很本地”，否则后面很容易把所有东西都往 provider 里塞。

## 和已有案例的关系

如果卡住，可以回看：

- 第 1 关参考 `case_01_set_state_example_page.dart`。
- 第 2 关参考 `case_02_notifier_provider_example_page.dart`。
- 第 3 关参考 `case_03_provider_example_page.dart`。
- 第 4 关参考 `case_04_future_provider_example_page.dart`。
- 第 5 关参考 `case_05_async_notifier_repository_example_page.dart`。
- 第 6 关参考 `case_06_comprehensive_task_board_page.dart`。

注意：参考不是复制。每关都要先自己判断状态边界，再借已有案例查语法。
