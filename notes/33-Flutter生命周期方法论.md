# 33 Flutter 生命周期方法论

## 这份手册解决什么问题

读 Flutter 大文件时，经常会看到 `initState()`、`didChangeDependencies()`、`build()`、`dispose()`、`mounted`、`addPostFrameCallback()` 混在一起。如果不先搞清它们各自的时间点，很容易把初始化、订阅、布局测量、异步回调和资源释放放错位置。

这份手册不是让你背生命周期，而是给你一个读码顺序：先问这个对象什么时候创建，再问它依赖谁、什么时候重建、什么时候释放。

## 什么时候使用

- 适合：读 `StatefulWidget`、输入框、动画、播放器、滚动、订阅、键盘、权限、异步请求页面。
- 不适合：完全纯展示的 `StatelessWidget`。这种组件通常只需要看构造参数和 `build()`。

## 一句话原则

谁创建资源，谁在对应生命周期释放；谁依赖上下文，就在上下文稳定的生命周期里读取。

## Web 前端迁移映射

| Web/Nuxt/Next/React | Flutter | 差异提醒 |
| --- | --- | --- |
| 组件函数执行 | `build()` | `build()` 可能频繁执行，不适合做副作用 |
| `useEffect(..., [])` | `initState()` + `dispose()` | 适合一次性创建和清理 controller、listener、timer |
| `useEffect(..., [props])` | `didUpdateWidget()` | 父组件传入的新配置变化时触发 |
| `useContext()` 依赖变化 | `didChangeDependencies()` | 适合依赖 `Theme`、`MediaQuery`、`Localizations`、InheritedWidget |
| ref 读 DOM 尺寸 | `GlobalKey` + `addPostFrameCallback()` | Flutter 要等一帧布局完成后才能安全拿尺寸 |
| 组件 unmount | `dispose()` | 必须释放自己创建的资源 |
| 页面可见性 / tab inactive | Route lifecycle / App lifecycle | 页面没销毁不代表可见；App 到后台也不等于 Widget dispose |

## 核心概念清单

- `Widget`：不可变配置，描述 UI 长什么样。
- `State`：保存可变状态和资源，生命周期比单次 `build()` 长。
- `Element`：把 Widget 配置和 State/RenderObject 关联起来，是复用状态的关键。
- `BuildContext`：当前 Element 在树里的位置，用来找父级依赖。
- `mounted`：当前 `State` 是否还在树上；异步回来后调用 `setState` 前常要检查。
- `InheritedWidget`：向子树提供上下文依赖，`Theme`、`MediaQuery`、`Localizations`、很多 scope 都属于这一类心智。

## StatefulWidget 生命周期顺序

首次挂载一个 `StatefulWidget` 时，常见顺序是：

```text
StatefulWidget constructor
-> createState()
-> State.initState()
-> State.didChangeDependencies()
-> State.build()
-> 子 Widget 按同样规则继续创建 / build
```

之后状态变化时，常见顺序是：

```text
事件 / 异步回调 / listener
-> setState()
-> 当前 State.build()
-> 需要更新的子树继续 build
```

父组件传给子组件的配置变了，但 Flutter 认为这是同一个位置、同一类 Widget 时：

```text
新的 Widget 实例创建
-> 旧 State.didUpdateWidget(oldWidget)
-> State.build()
```

依赖的上下文变化时，例如 `Theme`、`MediaQuery`、`KeyboardInsetsScope` 变化：

```text
Inherited 依赖变化
-> State.didChangeDependencies()
-> State.build()
```

销毁时：

```text
State.deactivate()
-> State.dispose()
```

`deactivate()` 表示暂时从树上移除，可能还会重新插回去；`dispose()` 才表示彻底销毁。日常业务代码里更常用 `dispose()`。

## 每个生命周期一般做什么

| 生命周期 | 执行时间 | 一般做什么 | 不适合做什么 |
| --- | --- | --- | --- |
| constructor | Widget 配置对象被创建 | 接收 `final` 参数 | 读取 `context`、创建需要释放的复杂资源 |
| `createState()` | StatefulWidget 首次挂载前 | 创建 State 对象 | 写业务逻辑 |
| `initState()` | State 第一次插入树后，只执行一次 | 创建 controller、focus node、animation controller、timer、订阅非 context 依赖 | 用 `context.dependOnInheritedWidgetOfExactType` 读取依赖 |
| `didChangeDependencies()` | `initState()` 后立刻执行一次；之后依赖变化会再执行 | 读取 `Theme`、`MediaQuery`、Localizations、scope；按依赖重新订阅 | 写每次 build 都该做的普通 UI 逻辑 |
| `build()` | 首次、`setState`、父级更新、依赖变化时都可能执行 | 根据当前状态描述 UI | 请求接口、创建 Future、注册 listener、调用 `setState` |
| `didUpdateWidget(oldWidget)` | 父组件传入同位置同类型的新 Widget 配置 | 对比新旧参数，更新 controller、动画、订阅源 | 处理和父参数无关的初始化 |
| `setState()` | 状态变化时由你主动调用 | 标记当前 State 需要重新 build | 在 `build()` 同步过程中直接调用 |
| `addPostFrameCallback()` | 当前帧 build/layout/paint 之后 | 读尺寸、滚动到某位置、打开依赖布局结果的弹窗 | 当成通用延迟修复手段 |
| `deactivate()` | State 暂时离开树 | 极少数场景处理临时移除 | 释放最终资源 |
| `dispose()` | State 永久销毁，只执行一次 | remove listener、cancel timer/subscription、dispose controller | 调用 `setState`、依赖还会继续可用的逻辑 |
| `reassemble()` | 热重载时，debug 模式 | 调试工具或特殊缓存刷新 | 生产逻辑 |

## `super.xxx()` 应该怎么放

通常按 Flutter 惯例：

```dart
@override
void initState() {
  super.initState();
  // 创建自己的 listener / controller
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // 读取 context 依赖，必要时重新订阅
}

@override
void dispose() {
  // 先释放自己创建的资源
  super.dispose();
}
```

记法：

- `initState()`、`didChangeDependencies()`：先 `super`，再做自己的初始化。
- `dispose()`：先清理自己的资源，最后 `super.dispose()`。

`super.didChangeDependencies()` 的意思是先让父类 `State` 完成框架生命周期处理，再读取新的上下文依赖。

## 父子组件生命周期顺序

首次创建时，通常是父先走到 `build()`，然后子组件才开始创建：

```text
Parent.initState()
-> Parent.didChangeDependencies()
-> Parent.build()
   -> Child.initState()
   -> Child.didChangeDependencies()
   -> Child.build()
```

销毁时，常见心智是子资源先被移除，父再完成自己的销毁；你读代码时重点不是死背日志顺序，而是确认每一层都释放自己创建的资源：

```text
Child.dispose()
-> Parent.dispose()
```

父组件 `setState()` 后，不代表所有子 State 都会销毁。只要子 Widget 在树中的位置、类型和 key 能匹配，子 State 通常会被复用，只是 `build()` 可能再执行。

## App 生命周期不是 Widget 生命周期

移动端还有 App 级生命周期，常通过 `WidgetsBindingObserver` 或 `AppLifecycleListener` 观察：

| 状态 | 大致含义 | 常见处理 |
| --- | --- | --- |
| `resumed` | App 在前台可交互 | 恢复播放、刷新必要数据 |
| `inactive` | 过渡态或暂不可交互 | 暂停敏感交互 |
| `paused` | App 到后台 | 暂停视频、停止定位、保存草稿 |
| `detached` | 引擎脱离宿主视图 | 少见，通常不写普通业务 |
| `hidden` | 视图不可见 | 桌面/多平台场景更常见 |

注意：App 进入后台，页面的 `dispose()` 不一定执行。`dispose()` 只代表 Widget 从树里被永久移除。

## 路由和生命周期的关系

Flutter 页面被 `push` 到下一页下面时，旧页面通常还在导航栈里，不会立刻 `dispose()`。所以：

- A 页面 `push` 到 B 页面，A 常常只是不可见，不等于销毁。
- B 页面 `pop` 后，A 可能继续使用原来的 State。
- A 被 `replace` 或从栈中移除时，才更可能 `dispose()`。

如果播放器、相机、动画需要“页面不可见就暂停”，不能只依赖 `dispose()`，还要考虑 route observer、可见性或 App lifecycle。

## 读大文件时的固定检查问题

```text
这个类是 StatelessWidget 还是 StatefulWidget？
State 里保存了哪些状态和资源？
哪些资源在 initState 创建？有没有在 dispose 释放？
有没有在 didChangeDependencies 读取 context/scope 依赖？
didUpdateWidget 有没有处理父参数变化？
build 里有没有请求、订阅、创建 controller、创建 Future？
异步回调回来后有没有检查 mounted？
页面 push 到下一页时，是不可见还是被销毁？
父组件重建时，子 State 是复用还是重建？key 有没有影响？
```

## 用第 15 章文件套一遍

`lib/chapter_15/chat_keyboard_jank_page.dart` 的生命周期主线是：

```text
initState
-> 监听 FocusNode 的焦点变化

build
-> 描述聊天页结构
-> _KeyboardTranslatedPane 根据键盘高度用 Transform.translate 移动内容
-> 顶部状态条通过 KeyboardInsetsScope 读取 native keyboard height/progress

dispose
-> 移除 focus listener
-> dispose FocusNode 和 TextEditingController
```

为什么键盘高度读取不放在 `initState()`？

因为 `KeyboardInsetsScope` 来自 widget 树上的 context。当前页面把它放在 `_NativeKeyboardStatusStrip.build()` 和 `_KeyboardTranslatedPane.build()` 里读取，由 `ValueListenableBuilder` 只重建状态条或外层 transform；复杂聊天列表作为 `child` 保持稳定。

## 常见坏味道

- 在 `build()` 里发请求、创建 `Future`、注册 listener。
- 创建了 `TextEditingController`、`AnimationController`、`FocusNode`，但忘了 `dispose()`。
- 异步请求回来后直接 `setState()`，页面退出时出现 setState after dispose。
- 在 `initState()` 里读取需要依赖 inherited context 的对象。
- 把 `addPostFrameCallback()` 当成万能修复，用它遮蔽真正的状态建模问题。
- 父组件一重建就误以为子组件 State 会全部重建。
- 以为页面不可见就一定 `dispose()`，导致播放器、订阅、计时器继续跑。

## 验收标准

- 能画出一个 `StatefulWidget` 从创建到销毁的顺序。
- 能说明 `initState()`、`didChangeDependencies()`、`didUpdateWidget()`、`build()`、`dispose()` 的区别。
- 能解释为什么 `build()` 里不应该做副作用。
- 能在读到 controller、listener、subscription、timer 时主动寻找对应的释放位置。
- 能解释 `mounted` 解决的是“避免更新已销毁 UI”，不是取消异步任务本身。

## 对 SpellAI 的映射

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/app.dart`：看 App 初始化和全局状态注入，不要把 App 生命周期和单个页面 `dispose()` 混在一起。
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/chat/`：聊天输入、键盘、滚动和列表状态要特别关注焦点、controller、listener 和页面可见性。
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/image2video/`：视频生成和结果预览容易涉及异步任务、播放器 controller、下载状态和页面退出后的回调。
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/media/`：媒体预览、视频播放、缓存和保存相册都需要明确 initialize、pause、dispose 的边界。

以后接手这些页面时，先不要急着改 UI，先找生命周期对象：谁创建、谁监听、谁释放、页面不可见时谁还在跑。
