# 02 Dart 基础与 TS 迁移 - 教学正文

这一份是给“已经知道要学什么，但还不知道怎么做”的状态准备的。

你可以把它当成一节小课：先建立对照，再把一个最小练习写出来，最后去看目标项目里真实的写法。

## 先看结论

你不是在学“Dart 语法大全”，而是在把三件事翻译成 Dart：

1. TS 里的类型系统。
2. TS/JS 里的异步和对象模型。
3. 目标项目里的数据模型和工具扩展写法。

只要这三件事能落地，这章就算过关。

## 练习文件

本章对应两份文件：

- `lib/chapter_02/dart_migration.dart`
- `test/chapter_02_dart_migration_test.dart`

先读代码，再看测试。测试不是附属品，它是这章“我真的会了”的证据。

## 第 1 步：先把 TS 的心智搬过来

你可以先用下面这组对照理解 Dart：

- TS `type` / `interface` -> Dart `class`、`typedef`、`record`
- TS `undefined | null` -> Dart 空安全 `T?`
- TS `readonly` -> Dart `final`
- TS `Promise<T>` -> Dart `Future<T>`
- TS `async iterator` -> Dart `Stream<T>`
- TS 的工具函数 -> Dart `extension`

最容易卡住的不是语法，而是“什么时候该把值设成可空，什么时候该直接让类型保证它不能为空”。

## 第 2 步：先写一个数据模型

在 `lib/chapter_02/dart_migration.dart` 里，核心对象是 `SpellTask`。

它做了几件典型的 Dart 事：

- 字段都用 `final`，表达不可变数据。
- 构造函数用命名参数，读起来更清楚。
- `copyWith` 让你在不修改原对象的前提下生成新对象。
- `toJson/fromJson` 让对象和 Map 互相转换。

你可以把它理解成“TS 的 interface + 一点工厂函数 + 一点序列化”的组合。

## 第 3 步：理解空安全

看这几个点：

- `String? resultUrl` 表示它可以没有值。
- `createdAt` 不允许为空，所以必须在构造时保证。
- `fromJson` 里如果字段缺失，要么给默认值，要么明确报错。

这就是 Dart 空安全最重要的地方：它不是让你少写判断，而是逼你提前说明数据边界。

TS 里你可能会默认写：

```ts
type SpellTask = {
  id: string
  prompt: string
  status: 'pending' | 'running' | 'done' | 'failed'
  createdAt: string
  resultUrl?: string
}
```

Dart 里更常见的是把这个意图直接写进类型：

```dart
final String? resultUrl;
final DateTime createdAt;
```

## 第 4 步：理解命名参数

Dart 很喜欢命名参数，因为它能让调用点更像“声明需求”，而不是“记位置”。

例如：

```dart
SpellTask.create(
  id: 'task_001',
  prompt: 'Generate a spell card',
  status: SpellTaskStatus.pending,
)
```

这在 Flutter 里很常见，因为 Widget 参数特别多，命名参数能显著提高可读性。

## 第 5 步：理解 extension

在 `DateTimeLessonFormat` 里，我们给 `DateTime` 加了一个 `toLessonStamp()`。

这件事在 TS 里你可能会写成工具函数：

```ts
formatDateTime(date)
```

在 Dart 里，extension 更适合这种“给已有类型补一个小能力”的场景：

```dart
final label = DateTime(2026, 8, 20, 9, 5).toLessonStamp();
```

它的可读性更贴近“这个对象自己就会说这个格式”。

## 第 6 步：理解 async/await

`createSpellTask()` 是一个最小异步例子。

它做的事很简单：

1. 模拟等待。
2. 用当前时间创建一个任务。
3. 返回 `Future<SpellTask>`。

你在 TS 里已经很熟 `async function` 了，所以这里重点不是语法，而是返回值类型：

- `Future<T>` 表示未来会拿到 `T`。
- UI 里后面就可以拿它接 `FutureBuilder`、Riverpod 的 `FutureProvider`，或者别的异步管线。

## 第 7 步：先跑测试，再谈理解

执行：

```bash
fvm flutter test test/chapter_02_dart_migration_test.dart
```

你应该看到这些检查都通过：

- 模型字段能正确保存。
- `copyWith` 只改你传入的字段。
- `toJson/fromJson` 能互相转换。
- `DateTime` 扩展能格式化时间。
- 异步创建函数能正常返回 `Future<SpellTask>`。

如果这里过不了，不要急着往后学，先把这一章跑通。

## 第 8 步：把这章翻译回目标项目

回到 `flutter-spell-ai` 时，重点看这三个地方：

- `lib/model/`
- `lib/extension/`
- `lib/model/task_bean.dart`

你要问自己的问题是：

1. 它的 model 哪些字段是必填，哪些字段是可空？
2. 它的 JSON 结构和 Dart class 是怎么对应的？
3. 它有哪些 extension 是为了简化业务代码？

这些问题，比单纯背 Dart 语法更接近真实工作。

## 一次完整练习怎么做

照着下面顺序走一遍：

1. 打开 `lib/chapter_02/dart_migration.dart`。
2. 先读 `SpellTaskStatus` 和 `SpellTask`。
3. 再看 `DateTimeLessonFormat`。
4. 最后看 `createSpellTask()`。
5. 跑 `fvm flutter test test/chapter_02_dart_migration_test.dart`。
6. 回头自己重写一遍，不看文件直接写。

如果你能不看代码重新写出来，这章就真的进脑子了。

## 常见误区

- 把 Dart 当成“换皮 TS”。它像，但不是。
- 看到 `!` 就乱用。它是断言，不是安慰剂。
- 一开始就追求复杂泛型。先把普通 class、nullable、async 写稳。
- 只读文档不跑测试。那样会停在“认识”而不是“会用”。

## QA 问答

### Q1：为什么这章先学 class，而不是先背语法表？
因为 Flutter 里最终会频繁和 model、widget、provider 打交道，class 是最常用的承载形式。先会写对象，再补语法效率更高。

### Q2：`late` 和 `?` 怎么选？
如果值理论上可能不存在，就用 `?`。如果值一定会有，只是初始化得晚一点，就用 `late`。不要把它们混着用。

### Q3：为什么 `copyWith` 在 Flutter 里这么常见？
因为 Flutter 和状态管理里经常要保持不可变数据流，`copyWith` 能在不污染原对象的前提下生成新状态。

### Q4：`Future` 和 `Stream` 怎么分？
一次性结果用 `Future`，持续变化用 `Stream`。例如“创建任务”通常是 `Future`，“实时进度”更像 `Stream`。

### Q5：这章学完后，下一章应该看什么？
下一章直接进 `Flutter 运行模型与 Widget`，把语言能力接到 UI 层，开始理解 Widget、BuildContext 和生命周期。
