# 02 Dart 基础与 TS 迁移

## 学习目标

- 理解 Dart 的变量、类型、空安全、函数、类、扩展、枚举、泛型。
- 建立 Dart 和 TypeScript 的差异地图。
- 能读懂目标项目中常见的 Dart 写法。

## Web 前端迁移映射

- TypeScript 的 `interface/type` 常被 Dart 的 `class`、`record`、`typedef`、泛型替代。
- TS 的 `undefined | null` 在 Dart 中主要通过空安全的 `T?` 表达。
- JS Promise 对应 Dart `Future<T>`。
- JS async iterator / stream 场景对应 Dart `Stream<T>`。
- TS module export/import 对应 Dart library/import/export。
- TS extension function 没有原生等价物，Dart 有 `extension`，目标项目大量使用。

## 核心概念清单

- `final`、`const`、`var`、显式类型
- 空安全：`?`、`!`、`??`、`?.`、`late`
- 命名参数、必填参数、默认值
- 类、构造函数、factory 构造
- `mixin`、`extension`、`sealed`、`base`、`final class`
- `Future`、`async`、`await`
- `record` 和 pattern matching
- package/import/export 组织方式

## 最小练习

在本仓库写一个 Dart/Flutter 小练习：

- 定义一个 `SpellTask` 模型，包含 id、prompt、status、createdAt。
- 写一个异步函数模拟创建任务，返回 `Future<SpellTask>`。
- 用 extension 给 `DateTime` 增加格式化方法。
- 用 `enum` 表达任务状态。

## 目标项目观察

优先阅读：

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/extension/`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/model/`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/model/task_bean.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/model/v_draw.dart`

观察问题：

- 哪些模型依赖 `json_serializable` 生成 `.g.dart`？
- 哪些 extension 是为了让业务代码更短？
- 目标项目是否使用 Dart 3 的 record、sealed、final class？

## 完成标准

- 能用自己的话说明 Dart 空安全和 TS null/undefined 的不同。
- 能读懂一个目标项目 model 文件和它对应的 `.g.dart`。
- 能解释 extension 为什么在这个项目里很常见。

## QA 问答（面试官常问）

### Q1：Dart 的 `final`、`const` 和 `var` 的区别是什么？
`final` 是运行时一次赋值后不可变；`const` 是编译期常量（必须在编译时可确定），`var` 只是类型推断变量，可以后续赋予同一类型值但仍可变。

### Q2：Dart 空安全里 `T?`、`late`、`!` 分别解决什么问题？
`T?` 说明可空，`late` 表示延迟初始化但保证最终赋值，`!` 是断言该值非空。面试时你可以解释这是把空值问题显式写进类型系统，避免运行期空指针。

### Q3：你会怎么把一个 TS 的 `interface` 迁移到 Dart？
通常会用 `class`（或 `record`/`typedef`）来表达数据结构，再配合 `json_serializable` 做序列化。目标项目大量使用的是 `class + .g.dart` 生成方式。

### Q4：什么时候用 `extension`，和 TS 的 helper 函数比有什么优势？
当你想给现有类型加能力而不修改定义时，`extension` 很合适；它在代码可读性和调用点集中上比散落的 util 函数更直观，也更符合 Flutter 风格。

### Q5：Dart 的 `async/await` 和 Promise 有什么本质差异？
语义上都表示异步流程，但 Dart 的 `Future` 更深度集成在语言和 Flutter 生命周期中，搭配 `Stream`、`Zone` 等能力处理 UI 任务更自然。
