# 03 Flutter 运行模型与 Widget

## 学习目标

- 理解 Flutter 不是 DOM，而是 Widget、Element、RenderObject 三层协作。
- 掌握 StatelessWidget、StatefulWidget、BuildContext、生命周期。
- 能从目标项目页面代码中识别组件边界。

## Web 前端迁移映射

- React/Vue 组件类似 Flutter Widget，但 Flutter Widget 是不可变配置对象。
- React render / Vue template 更新类似 Flutter `build()`，但 Flutter 没有浏览器 DOM diff。
- CSS 级联不存在，样式通常通过 Widget 参数、Theme 和组合表达。
- React hooks 的一部分心智可迁移到 Flutter hooks/Riverpod，但生命周期不同。

## 核心概念清单

- `runApp`
- `MaterialApp` / `CupertinoApp`
- `StatelessWidget`
- `StatefulWidget` 与 `State`
- `initState`、`dispose`、`didUpdateWidget`
- `BuildContext`
- Widget 树、Element 树、RenderObject 树
- `setState`
- Key 的用途

## 最小练习

做一个小页面：

- 显示一个计数器。
- 点击按钮增加计数。
- 页面初始化时打印日志。
- 页面销毁时释放一个模拟资源。

## 目标项目观察

优先阅读：

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/main.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/entry.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/app.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/home/`

观察问题：

- 应用真正入口在哪里？
- 哪些初始化放在 `App` 服务对象里？
- 页面 Widget 如何拆分？

## 完成标准

- 能解释为什么 Flutter Widget 经常被重建但不等于重新创建所有底层对象。
- 能知道什么时候需要 `dispose`。
- 能从目标项目页面定位一个按钮点击后的代码路径。

## QA 问答

### Q1：为什么 Flutter 不是“DOM 重渲染”模型？
Flutter 通过 Widget、Element、RenderObject 分层工作，`build()` 重建的是配置，渲染对象复用会尽量避免无意义开销，不等同于浏览器每次全量重绘 DOM。

### Q2：`StatefulWidget` 和 `StatelessWidget` 的实际边界是什么？
`StatelessWidget` 只接受不可变输入，`StatefulWidget` 持有可随生命周期变化的状态对象 `State`，适合输入事件、动画、订阅、计时器等需要生命周期管理的场景。

### Q3：`setState` 为什么不能在 `build()` 里直接调用？
在构建过程中触发状态变更会导致重复构建甚至异常，Flutter 需要状态变更在事件回调、异步回调或生命周期阶段进行，再触发下一次构建。

### Q4：`context` 出现 “depend on an ancestor” 报错该怎么看？
通常是把 `BuildContext` 用在了不在正确 widget 树上的时机（如异步后已弹栈），要确认 context 生命周期和作用域，必要时升级到更高层 context 或用 `mounted`。

### Q5：为什么面试会问 `Key`？
`Key` 决定了元素复用和状态绑定，尤其列表重排、表单项复用时能避免状态错位，是 Flutter 性能和正确性的常见考点。
