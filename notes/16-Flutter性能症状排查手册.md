# 16 Flutter 性能症状排查手册

## 这份笔记解决什么问题

这不是“写代码前背一遍”的性能 checklist，而是已经出现卡顿、掉帧、输入不顺、滚动抖动、动画不跟手、内存上涨之后，用来按症状排查和修复的手册。

核心顺序：

1. 先复现：明确哪个页面、哪个动作、哪台设备、debug/profile/release 哪种模式会卡。
2. 再量化：用 Performance Overlay、DevTools Timeline、日志或真机录屏判断卡在 UI thread、Raster thread、平台交互、异步 IO 还是内存。
3. 再归因：从下面的坏味道里找最像的一类，不要一上来套“状态下沉”“加缓存”“用懒加载”。
4. 最后验证：改完用同一个动作重新测，确认卡顿减少，且产品行为没有被改掉。

Web 前端类比：

- UI thread 高，类似 React/Vue 一次状态变化导致大组件树 render、diff、计算属性都跑。
- Raster thread 高，类似浏览器合成层、滤镜、阴影、图片解码、重绘成本高。
- 平台交互卡，类似移动端浏览器键盘、WebView、视频、系统控件和页面布局不同步。
- 内存上涨，类似事件监听、定时器、订阅、媒体对象没有清理。

## 先判断卡在哪里

| 症状 | 优先怀疑 | 第一检查 |
| --- | --- | --- |
| 点击、输入、切换状态后整页卡 | 大范围 rebuild 或 build 重活 | Flutter DevTools rebuild、日志、`setState`/`watch` 位置 |
| 滚动列表掉帧 | 列表非懒加载、item 太重、图片解码 | `ListView.builder`、图片尺寸、item 内特效 |
| 动画期间掉帧 | 每帧 layout 或 raster 太重 | 动画是否改高度、padding、约束、clip、blur、阴影 |
| 键盘弹起末尾顿一下 | `MediaQuery.viewInsets` 或 Scaffold resize 不逐帧 | 是否依赖 `resizeToAvoidBottomInset` 或顶层 `viewInsets` |
| 只有真机卡，模拟器不明显 | 图片、平台视图、输入法、设备 GPU | profile/release 真机、平台日志 |
| 页面越用越慢 | controller、subscription、timer、media player 泄漏 | `dispose`、`ref.onDispose`、Memory 工具 |
| loading 期间 UI 停住 | 主 isolate 有同步重活 | JSON、排序、图片处理、文件扫描是否同步跑 |

## 1. 大范围 rebuild：状态下沉什么时候有用

场景定义：

- 一个局部状态变化，例如输入框焦点、倒计时、进度、选中态、键盘高度，却导致整个页面 build。
- DevTools 或日志显示父页面、列表、图片 item、导航区域都在同一次状态变化里重建。
- Riverpod 中在页面根部 `ref.watch` 了频繁变化的 provider，然后把结果一路传给大块 UI。

解决办法：

- 把 `setState` 放到真正需要变化的最小 `StatefulWidget` 中。
- Riverpod 里把 `ref.watch` 下沉到局部 `Consumer`，或用 `select` 只订阅需要的字段。
- 用 `ValueListenableBuilder`、`AnimatedBuilder` 时，把稳定的大块 UI 作为 `child` 传入，让 wrapper 更新而 child 不重建。
- 能 `const` 的 Widget 尽量 `const`，让 Flutter 更容易短路不必要的 rebuild。

不适用的情况：

- Raster thread 高时，状态下沉通常帮不上忙，应该看图片、clip、blur、阴影、shader。
- 数据本身变了，列表 item 的真实内容必须更新，不能为了少 rebuild 保留旧 UI。

验收方式：

- 同一个操作后，DevTools 中 rebuild 范围缩小。
- 页面行为不变，只是更新范围更小。

## 2. build 里有重活：最容易怎么写错，怎么提取

场景定义：

- `build()` 里出现排序、过滤、大量 map/group、JSON decode、正则构建、DFA 构建、同步文件读取、网络请求、controller 创建。
- 输入一个字、切换一次 tab、键盘弹起一次，这些计算就跟着重跑。

常见写错过程：

```dart
@override
Widget build(BuildContext context) {
  final visibleItems = allItems
      .where((item) => item.title.contains(keyword))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return ListView(children: visibleItems.map(_buildItem).toList());
}
```

一开始这样写很自然，因为 UI 需要展示过滤后的列表。但当 `keyword`、焦点、键盘、主题、父组件状态变化时，过滤和排序都会被重新执行。

提取思路：

- 如果结果只依赖输入参数，提取成纯函数，并在上层状态变化时只在数据变更处计算。
- 如果结果依赖 provider 状态，做成派生 provider，例如 `filteredTasksProvider`。
- 如果初始化成本高但结果稳定，例如敏感词 DFA、正则集合、格式化器，放到 `initState`、静态 final、service 或 provider 初始化中。
- 如果是异步数据，不要在 `build` 里创建 `Future`；放到 `initState`、`FutureProvider`、`AsyncNotifier` 或 repository 层。

修复后的形态：

```dart
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final keyword = ref.watch(keywordProvider);
  return filterAndSortTasks(tasks, keyword);
});
```

验收方式：

- 非数据相关的 UI 变化不会重新触发重计算。
- 复杂计算可以独立测试。
- build 方法重新回到“读取状态 + 组装 Widget”。

## 3. 长列表：优先用内置懒加载，库只解决特定形态

场景定义：

- 消息、图库、历史记录、任务列表、瀑布流、搜索结果超过几十项。
- 当前写法是 `ListView(children: items.map(...).toList())`、`Column(children: ...)` 外面套滚动。

解决办法：

- 普通纵向列表：优先 `ListView.builder`。
- 网格：优先 `GridView.builder`。
- 多段页面：用 `CustomScrollView + SliverList/SliverGrid`。
- item 高度固定时，提供 `itemExtent`、`prototypeItem` 或稳定尺寸，减少布局计算。
- 分页数据：可以评估 `infinite_scroll_pagination` 这类分页库，但简单列表先用 `ScrollController + repository` 就够。
- 瀑布流：目标项目里已有 `waterfall_flow` / `flutter_staggered_grid_view`，这种是布局形态库，不是通用性能药。

不适用的情况：

- 列表只有十几项，item 很轻，懒加载收益有限。
- item 本身包含大图、视频、模糊、复杂阴影时，只改 builder 不够，还要继续看图片和绘制成本。

## 4. 图片：固定尺寸、缩略图、缓存是基础，不是全部

场景定义：

- 图片列表滚动卡、首次进入白一下、键盘或动画期间图片重新布局。
- 图片没有固定宽高，加载完成后撑开布局。
- 列表里直接展示原图或超大网络图。

解决办法：

- 列表里的图片必须有稳定尺寸，优先用固定宽高或 aspect ratio。
- 优先展示缩略图，点击详情页再加载大图。
- 网络图使用项目已有缓存能力，例如 `cached_network_image`；本地或 asset 图也要避免超大原图直接进列表。
- 能预判马上要看的图片时，用 `precacheImage`。
- 对大图指定解码目标尺寸，例如 `cacheWidth/cacheHeight`，避免用小容器显示超大 bitmap。
- 图片消息、图库 cell 外层加稳定占位，加载前后不要改变 item 高度。

验收方式：

- 滚动或键盘动画期间，图片不会突然改变尺寸。
- Memory 不因为缓存无限增长而持续上涨。

## 5. 动画复杂：需求复杂不等于每帧 layout 复杂

场景定义：

- 产品要求复杂转场、键盘联动、卡片展开、列表联动动画。
- 开发第一反应是 `AnimatedContainer`、改高度、改 padding、改列表约束，结果每帧 layout。

解决办法：

- 先区分视觉复杂和布局复杂：能用 `Transform`、`Opacity` 表达的，不要每帧改高度和约束。
- `AnimatedBuilder`、`ValueListenableBuilder` 要把重 UI 放到 `child`。
- 动画期间不要重算列表数据、不要触发网络请求、不要改变 item 数量。
- 对复杂但静态的子树加 `RepaintBoundary`，把重绘边界隔开。
- 键盘这类系统动画不要优先依赖 `MediaQuery.viewInsets`，更适合用原生逐帧 inset 驱动轻量 wrapper。

不适用的情况：

- 如果动画本身就是展开真实内容，高度变化是产品语义的一部分，就不能假装不 layout；这时要减少参与 layout 的子树，或分阶段渲染。

## 6. Opacity、Clip、阴影、模糊：需求要特效，也要控制作用范围

场景定义：

- 复杂卡片、毛玻璃、圆角图片、阴影气泡、半透明蒙层在列表或动画中大量出现。
- Raster thread 高，UI thread 不一定高。

解决办法：

- 特效范围尽量小，不要给整页套 `BackdropFilter` 或大面积 blur。
- 列表 item 里的毛玻璃、模糊、复杂阴影要谨慎，必要时改成静态背景图、渐变遮罩或更轻的视觉方案。
- 不需要裁剪时关闭裁剪；需要圆角图片时，让图片尺寸稳定，减少动画中的裁剪变化。
- 动画中的阴影、模糊、clip 尽量避免每帧变化。
- 静态复杂层可以用 `RepaintBoundary` 隔开，但不要乱加；边界太多也有管理成本。

验收方式：

- Performance Overlay 中 Raster thread 降下来。
- 视觉需求保留，但特效面积、数量或变化频率下降。

## 7. Platform View、WebView、视频、广告：不能不用，但要隔离

场景定义：

- 页面包含 `WebView`、视频播放器、广告 SDK、地图、原生相机/相册预览。
- 卡顿只在真机明显，尤其叠加滚动、圆角、透明、转场、键盘时。

解决办法：

- 能放独立页面就不要塞进复杂滚动列表。
- 避免对 platform view 做圆角裁剪、透明、复杂 transform、嵌套动画。
- 转场或键盘动画期间，可以用封面图/截图/placeholder 承接，动画结束再恢复真实 platform view。
- 视频列表优先展示封面，只有可见且需要播放的 item 初始化播放器。
- 广告、WebView、播放器要有明确生命周期，离屏、页面退出、tab 切换时暂停或释放。

不适用的情况：

- 产品确实要求内嵌播放或内嵌 WebView 时，优化目标不是“消灭 platform view”，而是缩小它和 Flutter 动画、滚动、裁剪的交叉面积。

## 8. 异步和加载：不是“异步跑加载”这么简单

场景定义：

- loading 时 UI 卡住，或者数据回来后整页抖一下。
- `build()` 里发请求、创建 Future、同步解析大 JSON、同步扫描文件。
- 页面退出后异步结果还回来 setState。

解决办法：

- 网络请求放 repository/service，页面只订阅状态。
- Riverpod 场景优先考虑 `FutureProvider`、`AsyncNotifier` 或显式状态模型，别在 build 里创建 Future。
- 重 CPU 工作，例如大 JSON 解析、图片处理、文件批量扫描，用 `compute` 或 isolate。
- 搜索、重复点击、页面退出后应废弃旧结果，可以用 `CancelableOperation`、请求 token、递增 request id 或 provider dispose 机制。
- loading 状态要完整建模：idle/loading/success/empty/error/canceled/stale，不要只靠一个 bool。

验收方式：

- loading 期间 UI 能滚动、点击反馈正常。
- 页面退出后没有 setState after dispose。
- 慢请求、失败、取消、重复触发都有明确分支。

## 9. dispose：不只是“记得写”

场景定义：

- 页面反复进入退出后越来越慢。
- 日志重复打印、事件重复响应、视频还在后台播、滚动监听还在触发。

需要盘点的对象：

- `TextEditingController`、`ScrollController`、`AnimationController`、`FocusNode`。
- `Timer`、`StreamSubscription`、事件总线订阅、socket、播放器、WebView/广告相关 controller。
- 手动创建的 `ChangeNotifier`、`ValueNotifier`。

解决办法：

- 谁创建，谁释放；对象生命周期要和页面、provider 或 service 生命周期一致。
- `StatefulWidget` 中在 `dispose` 里释放 controller、subscription、timer。
- Riverpod 中用 `ref.onDispose` 清理资源。
- 异步回调回来后先判断 `mounted`，但不要把 `mounted` 当作取消机制；真正需要取消的任务要取消或废弃结果。

验收方式：

- 页面反复进出后没有重复监听。
- Memory 曲线不会持续上涨。
- 日志不会出现 dispose 后继续回调。

## 开发前预防坏味道

写新功能前，用这几个问题快速扫一遍：

- 这个状态变化会不会让整个页面 rebuild？能不能下沉到局部？
- 这个 build 方法里有没有排序、过滤、解析、请求、controller 创建？
- 这个列表未来会不会超过几十项？如果会，先用 builder。
- 这个图片是否有稳定尺寸？列表里是不是缩略图？
- 这个动画是在改视觉位置，还是在改布局约束？
- 这个特效是否出现在列表或动画里？面积和数量能不能收窄？
- 这个 platform view 是否和滚动、圆角、透明、转场、键盘交叉？
- 这个异步任务失败、取消、页面退出、重复触发时会怎样？
- 这个 controller、subscription、timer、播放器由谁释放？

## Agent 执行规则

后续 agent 遇到性能问题时，必须先写出一条因果链：

```text
用户动作 -> 哪个状态/系统事件变化 -> 哪些 Widget 或渲染层参与 -> 哪个线程/阶段变慢 -> 用什么证据确认
```

在没有证据前，不要直接宣称“用状态下沉”“加缓存”“换懒加载”就能解决。优化完成后，必须说明：

- 保留了哪些产品行为。
- 改小了哪一类成本。
- 用什么命令、日志、DevTools 或真机动作验证。
- 哪些风险还没被覆盖。
