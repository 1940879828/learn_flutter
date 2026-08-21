# 03 Flutter 运行模型与 Widget - 教学正文

这一章的重点不是背名词，而是建立一个很关键的心智：Flutter 不是 DOM，也不是模板引擎，而是围绕 Widget、Element、RenderObject 协作的渲染系统。

## 先看结论

你可以先把这一章理解成三句话：

1. `Widget` 是配置，不是活对象。
2. `Element` 是 Widget 和渲染之间的中间层。
3. `StatefulWidget` 之所以重要，是因为它把“会变的东西”放进了 `State`。

## 练习文件

- `lib/main.dart`
- `test/widget_test.dart`

建议顺着 `main -> MyApp -> MyHomePage -> _MyHomePageState` 看，先看谁负责创建页面，再看谁负责保存状态。

## 第 1 步：先认清运行入口

`runApp()` 会把最外层的 Widget 挂到屏幕上。

你可以先问自己：

- 谁是应用入口？
- 谁决定主题？
- 谁决定首页？

在这个学习仓里，`MyApp` 就是根 Widget，`MaterialApp` 决定全局主题和路由入口，`home` 决定首页。

## 第 2 步：区分 Widget 和 State

`StatelessWidget` 适合纯展示。
`StatefulWidget` 适合有生命周期和可变状态的页面。

在 `MyHomePage` 里：

- `title` 是配置
- `_counter` 是状态
- `setState()` 负责告诉 Flutter“我变了”

这就是 Flutter 最基础的更新路径。

## 第 3 步：理解 build 的含义

`build()` 不是“创建页面一次就结束”，而是“每次状态变化时重新描述 UI”。

你在这一步要建立的习惯是：

- `build()` 写的是界面长什么样
- `setState()` 只负责触发重新描述
- 真正变化的是 UI 描述，不是你手动改某个控件实例

## 第 4 步：理解生命周期

这一章至少先记住这几个钩子：

- `initState()`：首次初始化
- `dispose()`：页面销毁时释放资源
- `didUpdateWidget()`：外部配置变了时响应

如果你后面要接动画、计时器、播放器、订阅流，这几个点会越来越重要。

## 第 5 步：理解 Key

`Key` 的作用是告诉 Flutter：哪些 widget 应该被复用，哪些应该被重新绑定。

你现在只需要先记住两类常见场景：

- 列表重排
- 表单/状态项复用

## 第 6 步：跑一次最小练习

先做两件事：

1. 点击按钮，观察计数器变化。
2. 改一个文本或颜色，热重载看是否生效。

你要试着自己回答：

- 为什么热重载后数字没清零？
- 为什么改颜色后 UI 会更新？

## 第 7 步：回到目标项目

优先读：

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/main.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/entry.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/app.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/home/`

重点看三件事：

1. 应用入口在哪里。
2. 初始化逻辑在哪里。
3. 页面是怎么拆分的。

## 完成标准

- 能解释为什么 Flutter 的 widget 经常重建但页面不会“全坏掉”。
- 能说清楚 `StatelessWidget` 和 `StatefulWidget` 的边界。
- 能从按钮点击找到对应的状态更新路径。

## QA 问答

### Q1：为什么 Flutter 不是 DOM 更新模型？
因为它的核心是 Widget/Element/RenderObject 三层协作，不是浏览器 DOM diff。`build()` 只是重新描述界面。

### Q2：为什么 `setState()` 只在 `State` 里？
因为状态属于页面生命周期的一部分，`State` 才是保存和管理可变状态的地方。

### Q3：`BuildContext` 是什么？
它是当前 Widget 在树中的位置和上下文入口，经常用于查找父级组件、主题、路由和依赖。

### Q4：`dispose()` 通常释放什么？
计时器、控制器、订阅、focus 节点、动画控制器等需要手动清理的资源。

### Q5：为什么面试常问 Key？
因为 Key 直接关系到状态复用和列表更新正确性，是 Flutter 基础里很实用的一块。
