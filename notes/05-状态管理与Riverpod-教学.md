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
- `lib/chapter_05/case_00_state_management_lab_page.dart`
- `lib/chapter_05/case_01_set_state_example_page.dart`
- `lib/chapter_05/case_02_notifier_provider_example_page.dart`
- `lib/chapter_05/case_03_provider_example_page.dart`
- `lib/chapter_05/case_04_future_provider_example_page.dart`
- `lib/chapter_05/case_05_async_notifier_repository_example_page.dart`
- `lib/chapter_05/case_06_comprehensive_task_board_page.dart`
- `lib/chapter_05/task_models.dart`
- `lib/chapter_05/task_repository.dart`
- 目标项目里的 `lib/app.dart` 和 `lib/pool/`

## 本章练习页面

项目首页现在有 `05 状态管理与 Riverpod` 入口。

入口页下面拆成 6 个案例，建议按顺序看：

1. `01 StatefulWidget + setState`：只学本地状态。
2. `02 NotifierProvider`：把状态修改逻辑从 Widget 挪到 controller。
3. `03 Provider 派生数据`：用 `Provider` 从已有状态计算统计、筛选和展示文案。
4. `04 FutureProvider`：用一次性异步请求理解 `AsyncValue.when`。
5. `05 AsyncNotifier + repository`：用 repository 管数据来源，用 `AsyncNotifier` 管 loading、error、data。
6. `06 综合任务看板`：最后看多个 provider 如何组合。

当前 repository 是 `FakeSpellTaskRepository`，没有打真实接口。它故意用 `Future.delayed` 和可控错误模拟真实接口，因为本章重点是状态流转，不是 HTTP。真实网络请求会在第 07 章展开。

最后的综合任务看板模拟了 `flutter-spell-ai` 里常见的“生成任务列表”：

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

1. 先点 `01 StatefulWidget + setState`，确认不用 Riverpod 也能管理局部状态。
2. 再点 `02 NotifierProvider`，观察 Widget 如何用 `read` 调 controller。
3. 再点 `03 Provider 派生数据`，观察统计文案不是手写状态，而是从任务列表算出来。
4. 再点 `04 FutureProvider`，观察 loading/data 切换和刷新。
5. 再点 `05 AsyncNotifier + repository`，点错误按钮，看 error 状态如何进入 UI。
6. 最后点 `06 综合任务看板`，观察 `watch/read/listen` 同时出现时怎么分工。

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

## Provider 类型对比和使用场景

Riverpod 里的 provider 不是一种东西，而是一组“状态容器 / 依赖声明方式”。

你可以先用这张表建立判断：

| 类型 | UI 读到什么 | 主要解决什么问题 | 适合场景 | 不适合场景 |
| --- | --- | --- | --- | --- |
| `Provider<T>` | 普通的 `T` | 声明一个同步依赖，或者从其他 provider 派生一个同步结果 | repository 注入、api client 注入、从任务列表计算统计文案、过滤后的列表 | 自己内部需要修改状态、需要 loading/error/data |
| `FutureProvider<T>` | `AsyncValue<T>` | 声明一个一次性异步读取 | 页面初始化加载、远程配置、详情页 GET 请求、简单列表请求 | 需要很多操作方法，比如新增、删除、重试、分页、提交表单 |
| `NotifierProvider<Notifier, State>` | 普通的 `State` | 管理同步可变状态，并把修改逻辑收口到 controller | 筛选条件、tab 选择、表单草稿、本地任务列表、本地计数器 | 远程请求状态，尤其是 loading/error/data 很多的场景 |
| `AsyncNotifierProvider<Notifier, State>` | `AsyncValue<State>` | 管理异步状态，并把加载、刷新、提交、错误处理收口到 controller | 远程任务列表、生成任务状态、带 repository 的业务模块、需要刷新和错误重试的页面 | 只是一个简单开关、简单筛选条件、纯同步派生值 |
| `StreamProvider<T>` | `AsyncValue<T>` | 订阅一条持续变化的数据流 | 登录状态流、实时消息、WebSocket、数据库 watch、下载进度流 | 普通一次性请求 |

### 和你说的 custom provider 有什么区别？

如果你说的 `custom provider` 是“自己写一个 provider，把 repository 或 controller 暴露出去”，那它本质上更像 `Provider<T>` 或 `NotifierProvider`：

```dart
final repositoryProvider = Provider<SpellTaskRepository>((ref) {
  return FakeSpellTaskRepository();
});
```

这种写法只是在声明“谁提供这个对象”，它自己不自动帮你处理异步的 `loading/error/data`。

而 `FutureProvider` 这段：

```dart
final futureTasksProvider = FutureProvider<List<SpellTaskItem>>((ref) {
  final repository = ref.watch(spellTaskRepositoryProvider);
  return repository.fetchTasks();
});
```

表达的是“这个 provider 的值来自一个 Future”。所以 UI 读到的不是 `List<SpellTaskItem>`，而是 `AsyncValue<List<SpellTaskItem>>`。这就是为什么页面里可以写：

```dart
tasksAsync.when(
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => Text('$error'),
  data: (tasks) => Text('任务数量：${tasks.length}'),
);
```

换句话说：

- `Provider<Repository>`：提供数据源。
- `FutureProvider<List<Task>>`：调用数据源，并把异步过程包装成 UI 能消费的状态。
- `AsyncNotifierProvider<TaskController, List<Task>>`：不只加载数据，还集中管理刷新、重试、新增、删除、提交等操作。

### 选择口诀

先不要背 API，先按问题选：

- 只是提供一个对象：用 `Provider`。
- 只是从已有状态算一个结果：用 `Provider`。
- 只是做一次异步读取：用 `FutureProvider`。
- 有同步状态，还要暴露操作方法：用 `NotifierProvider`。
- 有远程数据，还要管理 loading、error、刷新、提交：用 `AsyncNotifierProvider`。
- 数据会持续推送变化：用 `StreamProvider`。

### 用 Web 前端类比

可以粗略这样迁移理解：

- `Provider<ApiClient>` 像在 React Context 里提供一个 `apiClient`。
- `Provider<Summary>` 像 `useMemo`，从已有数据派生一个结果。
- `FutureProvider` 像一个最小版 `useQuery`，负责请求和 loading/error/data。
- `NotifierProvider` 像 Zustand / Redux slice，状态和 action 放在一起。
- `AsyncNotifierProvider` 像 `useQuery + mutation/actions` 的组合，适合业务模块收口。

不过 Riverpod 和 React 最大的不同是：provider 不挂在组件函数里，而是声明在组件外面。Widget 通过 `ref.watch` 订阅它，通过 `ref.read` 调用它。

### 对应本章案例

- `01 StatefulWidget + setState`：先理解不用 Riverpod 时，状态怎么放在页面本地。
- `02 NotifierProvider`：学习同步状态和 action 怎么从 Widget 移出去。
- `03 Provider 派生数据`：学习 `Provider` 如何做同步派生值。
- `04 FutureProvider`：学习一次性异步请求和 `AsyncValue.when`。
- `05 AsyncNotifier + repository`：学习远程数据、repository、loading、error、data 的完整收口。
- `06 综合任务看板`：学习多个 provider 组合时怎么分层。

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
