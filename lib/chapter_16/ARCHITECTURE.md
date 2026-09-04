# Chapter 16 复杂视频页拆分与演进方案

## 0. 当前情况

当前 `video_page.dart` 同时包含三类职责：

1. `VideoPage` 负责页面骨架和视频下方内容。
2. `_VideoCard` 负责创建、初始化和释放 `VideoPlayerController`，并展示 loading、error、success。
3. `_PlayPauseButton` 负责监听播放状态以及触发播放、暂停。

当前代码规模不大，但计划中的评论、全屏、弹幕、进度条和设置会沿不同方向变化。继续全部写进一个文件，会让播放器生命周期、每帧更新和评论请求互相影响。

本方案采用 feature-first 组织：所有内容仍留在 `chapter_16` 业务域内，只拆确定会独立变化的部分。

## 1. 设计约束

| 约束 | 当前判断 | 对拆分的影响 |
| --- | --- | --- |
| 项目性质 | Flutter 学习项目，单人逐步实现 | 每一步都必须小且可运行，不一次创建所有目录 |
| 页面目标 | 视频、控制栏、全屏、设置、弹幕、评论 | 播放器域和评论域必须分开 |
| 播放状态 | position、buffering 等状态会高频变化 | 只重建需要变化的小组件，不刷新整个页面 |
| 播放器生命周期 | controller 必须初始化一次并可靠释放 | controller 由一个明确的 StatefulWidget 持有 |
| 全屏 | 普通态和全屏态需要保持同一播放进度 | 全屏视图复用 controller，不能重新创建播放器 |
| 弹幕 | 必须跟随播放时间、暂停、seek 和倍速 | 弹幕调度独立于普通 UI 动画，但以播放器时间为准 |
| 评论 | 包含网络、分页、刷新、点赞和回复 | 与播放器状态隔离，后续单独使用 Provider/Repository |
| 复用范围 | 当前只服务第 16 章 | 组件先留在 feature 内，不提升到 `lib/ui/widget/` |

由这些约束可以排除两个方案：

- 不采用“所有 Widget 都放一个文件”，因为播放器与评论的变化方向已经明确不同。
- 不采用“每个小 Widget 都立刻单独一个文件”，因为会提前制造大量只有几行的文件和跳转成本。

## 2. 推荐的目标结构

以下是目标形态，不要求现在一次建齐：

```text
lib/chapter_16/
├── ARCHITECTURE.md
├── video_page.dart
├── player/
│   ├── video_player_section.dart
│   ├── fullscreen_video_page.dart
│   ├── controls/
│   │   ├── video_controls.dart
│   │   ├── video_progress_bar.dart
│   │   └── video_settings_sheet.dart
│   └── danmaku/
│       ├── danmaku_item.dart
│       ├── danmaku_controller.dart
│       └── danmaku_overlay.dart
└── comments/
    ├── comment.dart
    ├── comments_section.dart
    ├── comments_provider.dart
    └── comments_repository.dart
```

只有开始实现对应功能时才创建对应目录和文件。

## 3. 模块职责与依赖

| 模块 | 一句话职责 | 依赖 | 谁会使用它 |
| --- | --- | --- | --- |
| `VideoPage` | 接收页面参数并组合播放器与评论区 | `VideoPlayerSection`、`CommentsSection` | 路由 |
| `VideoPlayerSection` | 拥有播放器 controller 及其完整生命周期 | `video_player`、控制栏、弹幕层 | `VideoPage` |
| `VideoControls` | 组合播放、进度、设置和全屏入口 | 已初始化的 controller | `VideoPlayerSection` |
| `VideoProgressBar` | 显示时间、缓冲进度并处理 seek | 已初始化的 controller | `VideoControls` |
| `FullscreenVideoPage` | 使用同一个 controller 显示全屏播放器 | controller、控制栏、弹幕层 | 全屏入口 |
| `DanmakuOverlay` | 绘制当前播放时间应该可见的弹幕 | 弹幕调度结果 | 普通态与全屏态播放器 |
| `DanmakuController` | 根据播放时间、暂停、seek、倍速计算弹幕轨道 | controller 的时间状态、弹幕列表 | `DanmakuOverlay` |
| `CommentsSection` | 展示评论状态、列表、分页和输入入口 | comments provider | `VideoPage` |
| `CommentsProvider` | 管理加载、刷新、分页、点赞和发送状态 | repository | 评论区 Widget |
| `CommentsRepository` | 封装评论数据来源 | API 或本地 fake 数据 | comments provider |

依赖方向保持为：页面负责组合，业务组件管理自己的状态，叶子 Widget 通过参数和 callback 接收数据与动作。

## 4. 状态归属

| 状态 | 放置位置 | 更新方式 |
| --- | --- | --- |
| 初始化 Future | `VideoPlayerSection` State | 只创建一次，由 `FutureBuilder` 展示三态 |
| 底层播放状态 | `VideoPlayerController` | 由需要它的局部 Widget 监听 |
| 控制栏显隐 | `VideoControls` 本地 State | 点击视频或计时后局部更新 |
| 拖动中的进度 | `VideoProgressBar` 本地 State | 拖动期间使用临时值，结束后 `seekTo` |
| 全屏状态 | 全屏导航或播放器协调层 | 进入时切横屏，退出时恢复方向和系统栏 |
| 弹幕开关、透明度、字号 | 播放设置状态 | 需要跨视频保存时再放 Provider/本地存储 |
| 弹幕轨道和当前位置 | `DanmakuController` | 以视频 position 为时间源 |
| 评论列表和分页 | `CommentsProvider` | 使用 Async 状态表达 loading/error/data |
| 评论输入框文字 | `CommentInput` 本地 controller | 只影响输入组件 |

不要把视频 position 每一帧同步到页面级 Riverpod Provider。它会扩大重建范围；播放器 controller 已经是适合高频播放状态的 `ValueListenable`。

## 5. 第一次拆分：只拆现有代码

第一次只形成三个 Dart 文件：

```text
lib/chapter_16/
├── video_page.dart
└── player/
    ├── video_player_section.dart
    └── controls/
        └── video_controls.dart
```

### 第 1 步：建立验证基线

改代码前先确认：

- 从首页可以进入第 16 章。
- 视频初始化后能够播放。
- 播放和暂停图标能跟随 controller 状态变化。
- 返回上一页后没有 controller 或 listener 生命周期异常。
- 执行 `fvm flutter analyze lib/chapter_16`。

这一轮只记录当前行为，不改变 UI。

### 第 2 步：抽出控制栏

创建 `player/controls/video_controls.dart`。

移动边界：

- 新建公开 Widget `VideoControls`，构造参数接收 `VideoPlayerController`。
- 当前 `_PlayPauseButton` 及其 State 移入这个文件，仍可保持私有。
- `VideoControls` 当前只组合一个播放暂停按钮；将来的进度、设置和全屏按钮都从这里加入。
- `VideoControls` 不创建也不释放 controller。

完成后，原 `_VideoCardState` 只通过 `VideoControls(controller: _controller)` 使用控制栏。

完成标准：播放行为和图标变化与拆分前一致，listener 仍能在按钮销毁时移除。

### 第 3 步：抽出播放器生命周期

创建 `player/video_player_section.dart`。

移动边界：

- `_VideoCard` 改名为公开的 `VideoPlayerSection` 并移入新文件。
- `_VideoCardState` 改名为私有的 `_VideoPlayerSectionState`。
- controller、初始化 Future、loading/error/success 和 `dispose` 一起移动。
- 引入并组合 `VideoControls`。
- `VideoPlayerSection` 对外暂时只接收 `String videoUrl`。

必须整体移动 controller 的创建和释放，避免一个文件创建、另一个文件释放。

完成标准：页面反复进入和退出后仍只初始化一次、释放一次，视频和按钮行为保持一致。

### 第 4 步：收窄页面职责

清理 `video_page.dart`：

- 保留 `VideoPage`、`Scaffold`、页面布局、测试 URL 和下方内容。
- 使用公开的 `VideoPlayerSection`。
- 删除已经搬走的播放器和按钮实现。
- 如果页面本身没有 State、controller 或生命周期逻辑，将 `VideoPage` 改成 `StatelessWidget`。
- 删除不再使用的 `cupertino.dart` 和 `video_player.dart` import。

完成标准：只看 `video_page.dart` 就能快速看懂页面由“播放器区域 + 内容区域”组成。

### 第 5 步：格式化并回归

每完成一个移动步骤都执行：

```text
fvm dart format lib/chapter_16
fvm flutter analyze lib/chapter_16
```

第一次拆分全部完成后，再运行现有工程测试，并手动重复进入、播放、暂停、退出页面。

## 6. 后续功能的演进顺序

### 阶段 A：基础控制栏

实现顺序：播放暂停、当前时间、总时长、可拖动进度条。

新增 `video_progress_bar.dart` 的时机：进度条开始同时处理展示、拖动临时值和 seek，不能再用一句话描述为普通按钮。

完成标志：播放时局部进度更新；拖动期间 UI 稳定；松手后跳到目标时间；页面其他区域不跟着每帧 rebuild。

### 阶段 B：全屏与横屏

新增 `fullscreen_video_page.dart`，接收现有 controller，而不是接收 URL 后重新创建 controller。

关键约束：

- 进入全屏保留播放位置和暂停状态。
- 普通态和全屏态共用同一套 `VideoControls`。
- 返回、手势返回和异常退出都能恢复屏幕方向与系统栏。
- controller 的所有权仍属于 `VideoPlayerSection`，全屏页不调用 `dispose`。

### 阶段 C：设置面板

新增 `video_settings_sheet.dart`。第一版只处理已经存在的能力，例如倍速、循环和静音。

设置仅在当前视频有效时可以留在播放器 State；需要跨页面或下次启动保留时，再提升为 Provider 并接本地存储。

### 阶段 D：弹幕

创建 `player/danmaku/`。先定义 `DanmakuItem` 的稳定数据字段：ID、出现时间、文本以及必要的展示属性。

弹幕调度必须处理：

- 播放与暂停。
- seek 向前和向后。
- buffering。
- 倍速变化。
- 普通态与全屏态切换。
- Widget dispose 后停止动画和监听。

第一版只做少量假数据和固定轨道。确认时间同步正确后，再处理碰撞、轨道复用和大数据量性能。

### 阶段 E：评论区

创建 `comments/`，评论状态不得放入播放器 controller。

第一版可使用 fake repository，完整表达 loading、empty、error、success 和 retry。之后再增加分页、点赞、回复和发送。

页面保持顶部播放器固定时，评论列表放进剩余空间的 `Expanded` 内独立滚动，避免嵌套多个无边界滚动组件。

## 7. 关键技术决策

| 决策 | 选择 | 理由 | 什么时候需要调整 |
| --- | --- | --- | --- |
| 目录组织 | chapter 内 feature-first | 播放器和评论独立变化，又只服务本章 | 多个业务页需要同一播放器时再提升到共享层 |
| controller 所有权 | `VideoPlayerSection` State | 初始化与释放处于一个生命周期边界 | 需要跨路由长期后台播放时再提升所有权 |
| 控制栏状态 | controller + Widget 本地 State | 高频状态靠近使用处，减少页面重建 | 多个播放器视图需同步控制时再增加协调层 |
| 评论状态 | Riverpod Provider + Repository | 评论是异步业务数据，生命周期不同 | 纯静态演示阶段可先用本地 State |
| 弹幕时间源 | 视频 position | 暂停、seek、倍速时保持同步 | 不应改为独立 Timer 时间源 |
| 文件粒度 | 一个稳定职责一个文件 | 控制复杂度，同时避免碎片化 | 文件出现多个独立变化理由时继续拆 |
| `part` | 当前不使用 | 独立 Widget 用显式 import 和参数更容易追踪 | 多文件必须共享大量私有页面状态时再评估 |
| 播放器封装库 | 继续使用 `video_player` | 目标是学习并定制控制、设置和弹幕 | 只想快速获得标准控制 UI 时再评估 Chewie |

## 8. 实现时必须守住的边界

- 跨文件使用的 Widget 不能以 `_` 开头；配套 State 和文件内部小 Widget 可以保持私有。
- `createState` 返回具体类型，例如 `State<VideoPlayerSection>`，不要用宽泛的 `State<StatefulWidget>` 掩盖类型写错。
- controller 只能有一个所有者，只有所有者调用 `dispose`。
- `addListener` 与 `removeListener` 必须成对；如果未来允许替换 controller，需要在 `didUpdateWidget` 中迁移监听。
- 初始化、网络评论、弹幕数据都要表达 loading、error 和 dispose 后返回的情况。
- 全屏、设置和弹幕只通过 controller 或明确参数通信，不读取页面 State 的私有字段。
- 先保证行为一致再移动下一块，不在同一步同时拆文件、改 UI 和新增功能。

## 9. 每阶段验收清单

- 页面首次进入能加载并播放视频。
- 加载失败时用户能看到错误状态。
- 播放、暂停和图标状态一致。
- 离开页面后没有继续播放、`setState after dispose` 或 listener 泄漏。
- 全屏前后保持同一个播放位置。
- seek、暂停、缓冲、倍速时弹幕仍与视频时间一致。
- 评论加载和滚动不会让播放器每帧 rebuild。
- `fvm dart format lib/chapter_16` 无额外改动。
- `fvm flutter analyze lib/chapter_16` 通过。
- 对应阶段的 focused 测试和工程测试通过。

