# Chapter 16 视频本地文件缓存设计指南

> 文档定位：稳定的设计约束与决策说明，不是逐行实施手册。
>
> 适用范围：`lib/chapter_16/` 的第一阶段视频本地文件缓存。

## 1. 目标

第一阶段把当前网络视频播放器演进为“优先使用本地缓存文件”的播放器，同时保持播放器 UI、控制层和缓存实现低耦合。

完成后应满足：

- 第一次访问网络视频时，将完整视频保存到 App 临时缓存。
- 再次访问同一视频时，直接使用有效的本地文件。
- 播放器 Widget 不直接依赖具体缓存库。
- 更换缓存库、关闭缓存或改成分片缓存时，不需要修改控制层。
- `VideoPlayerController` 仍只有一个明确所有者。
- 下载、初始化和页面销毁之间的异步边界被显式处理。
- 缓存失败和播放器初始化失败都能形成可理解、可恢复的状态。

第一阶段关注“完整文件缓存是否能在清晰边界内工作”，不追求大型视频平台的全部能力。

## 2. Discovery

### 2.1 当前实现

当前入口位于：

- `lib/chapter_16/video_page.dart`
- `lib/chapter_16/player/video_player_section.dart`
- `lib/chapter_16/player/controls/video_controls.dart`

设计基线中，`VideoPlayerSection` 直接通过网络 URL 创建 `VideoPlayerController`，并负责 controller 的初始化、自动播放和释放。`VideoControls` 只接收已经初始化的 controller，负责播放控制和控制层展示。

当前实施已经进入“来源接缝”阶段：新增 `VideoControllerFactory` / `NetworkVideoControllerFactory`，让网络 controller 的创建先经过工厂，后续缓存实现会替换工厂组合方式，而不是修改控制层。

当前可以保留的稳定边界：

- `VideoPlayerSection` 继续拥有 controller 生命周期。
- `VideoControls` 不参与缓存和 controller 创建。
- 全屏页未来复用同一个 controller，不重新创建或释放它。

需要隔离的变化：

- 当前来源是网络 URL。
- 第一阶段来源变为完整缓存文件。
- 后续可能变为网络直播、本地代理 URL、HLS/DASH 分片或用户离线文件。

### 2.2 SpellAI 可借鉴的实现

目标项目 `/Users/dev/Documents/Projects/flutter-spell-ai` 已有完整文件缓存思路：

- `lib/ui/pages/image2video/media/widget/video_view.dart` 使用下载管理器获取视频文件，完成后再交给播放器。
- `lib/engine/io/file_download_manager.dart` 负责缓存路径、任务复用、临时文件、完成后重命名、过期和淘汰。
- `StorageType.previewVideo` 使用临时缓存目录，并配置最大缓存数量和过期时间。
- 当前实现明确不支持断点续传，因此更适合较短的视频预览。

可以复用的是设计边界，而不是直接复制代码：

- 下载和播放分开。
- 未完成文件不能当作有效缓存播放。
- 同一 URL 的并发请求应复用同一个下载任务。
- 缓存必须有过期和淘汰策略。
- 页面不可见或销毁后，播放器资源要可靠回收。

不直接复用 SpellAI 代码的原因：

- 目标项目代码在本学习项目中只读。
- 其下载管理器依赖 SpellAI 自己的存储、网络、异常和生命周期基础设施。
- 本章需要先形成可以独立理解和验证的最小实现。

## 3. 概念边界

| 概念 | 含义 | 是否持久化 | 第一阶段是否实现 |
| --- | --- | --- | --- |
| 播放进度 | 当前播放到哪个时间点 | 默认否 | 已有，后续展示 |
| 播放缓冲 | 原生播放器已经准备好的时间范围 | 不保证 | 由播放器提供 |
| 本地文件缓存 | App 保存的完整视频文件 | 是，但可能被系统清理 | 是 |
| 预加载 | 在用户播放前提前准备当前或下一个视频 | 取决于实现 | 否 |
| 离线下载 | 用户明确要求长期保存的视频 | 是，具有独立管理语义 | 否 |

第一阶段的“缓存”不能被描述成“离线下载”：

- 缓存位于临时目录，系统可以清理。
- 缓存由淘汰规则自动管理。
- 用户没有长期保留它的承诺。
- 离线下载未来需要独立的任务、状态、存储位置和删除规则。

## 4. 约束清单

| 约束 | 当前值 | 对架构的影响 |
| --- | --- | --- |
| 项目性质 | Flutter 学习项目，单人渐进实现 | 模块边界清楚，但不提前建设完整下载平台 |
| 当前媒体 | 单个、较短、可直接下载的 MP4 | 第一阶段可以采用完整文件缓存 |
| 播放器 | `video_player` | controller 仍是播放器状态和生命周期核心 |
| 目标平台 | 优先 Android、iOS、macOS | 可以使用本地文件 controller |
| Web | `VideoPlayerController.file` 不可用 | Web 必须网络回退，或明确排除在第一阶段外 |
| 首次播放 | 可以接受先完成短视频下载再播放 | 暂不实现边播边缓存 |
| 控制层 | 已独立为 `VideoControls` | 不允许向控制层泄漏缓存状态和缓存库类型 |
| 全屏 | 将复用同一个 controller | 全屏页不能重新下载、初始化或释放 controller |
| 后续变化 | 可能增加进度条、分片缓存、预加载 | 播放来源必须留一个稳定接缝 |

由这些约束可以排除：

- 在 `VideoControls` 内查询或下载缓存。
- 让普通态和全屏态分别创建缓存与 controller。
- 第一阶段直接引入 HLS/DASH、后台下载或本地代理服务器。
- 播放网络 URL 的同时，再独立下载同一个完整文件。
- 无上限地把所有视频永久保存在本地。

## 5. 模块划分

推荐目标结构：

```text
lib/chapter_16/player/
├── source/
│   └── video_controller_factory.dart
├── cache/
│   └── cached_video_controller_factory.dart
├── controls/
│   └── video_controls.dart
├── fullscreen_video_page.dart
└── video_player_section.dart
```

文件只在开始实现对应能力时创建。

| 模块 | 一句话职责 | 变化理由 | 依赖 | 被依赖 |
| --- | --- | --- | --- | --- |
| `VideoPage` | 组合视频区域和页面其他内容 | 页面内容变化 | `VideoPlayerSection` | 路由 |
| `VideoPlayerSection` | 管理唯一 controller 的完整生命周期 | 播放生命周期变化 | controller 工厂、控制层 | `VideoPage` |
| `VideoControllerFactory` | 定义如何异步获得一个可由调用方接管的 controller | 播放来源变化 | `video_player` | 播放区域、具体工厂 |
| `CachedVideoControllerFactory` | 将 URL 解析为有效缓存文件并创建文件 controller | 缓存策略变化 | 缓存库、工厂契约 | 组合入口 |
| `VideoControls` | 展示和操作已初始化的 controller | 控制 UI 变化 | `video_player` | 普通态和全屏态播放器 |
| `FullscreenVideoPage` | 使用现有 controller 展示全屏播放视图 | 全屏交互变化 | controller、控制层 | 播放区域 |

依赖方向：

```text
VideoPage
  └── VideoPlayerSection
        ├── VideoControllerFactory  ← CachedVideoControllerFactory
        └── VideoControls
```

缓存实现不能反向依赖 `VideoPlayerSection` 或 `VideoControls`。

## 6. 稳定接口契约

`VideoControllerFactory` 是播放器与缓存之间唯一需要提前固定的接缝。

概念接口：

```text
create(videoUrl) -> Future<VideoPlayerController>
```

契约要求：

- 输入是当前视频的远程地址。
- 返回的 controller 尚未执行 `initialize()`。
- 工厂可以返回网络、本地文件或其他播放器支持的 controller。
- 工厂不得调用 `play()`。
- 工厂不得保留并在之后释放已经返回的 controller。
- controller 返回后，所有权转移给 `VideoPlayerSection`。
- 创建失败通过 Future error 明确返回，不用空对象或永久 loading 表示失败。

选择“controller 工厂”而不是“缓存文件读取器”的原因：

- 播放器不需要知道最终来源是不是 `File`。
- 未来本地代理缓存仍可返回 network controller。
- Web 网络回退不需要伪造本地文件。
- 缓存策略替换不会改变控制层接口。

## 7. Controller 所有权

所有权与创建位置必须分开理解：

- 工厂负责创建 controller。
- `VideoPlayerSection` 接收后成为唯一所有者。
- `VideoPlayerSection` 负责 `initialize`、初始播放和 `dispose`。
- `VideoControls` 只能调用播放控制 API 和监听状态。
- `FullscreenVideoPage` 只能临时使用同一个 controller。
- 缓存模块不监听播放状态，也不管理 controller 生命周期。

任何时刻都不允许两个模块都认为自己应该释放同一个 controller。

## 8. 缓存数据流

### 8.1 缓存命中

```text
请求 controller
→ 根据稳定 cache key 查询文件
→ 校验缓存仍有效
→ 创建 file controller
→ 所有权交给 VideoPlayerSection
→ initialize
→ play
```

### 8.2 缓存未命中

```text
请求 controller
→ 查询未命中
→ 下载到临时文件
→ 下载完整且校验成功
→ 原子转为有效缓存文件
→ 创建 file controller
→ 所有权交给 VideoPlayerSection
```

### 8.3 失败

至少区分：

- 缓存查询失败。
- 网络下载失败。
- 磁盘空间或文件写入失败。
- 缓存文件损坏。
- controller 创建或初始化失败。

缓存文件损坏时，可以执行一次“删除损坏缓存并重新获取”的明确恢复流程，但不能无限重试。缓存基础设施不可用但网络仍可播放时，可以由具体工厂选择网络回退；该行为必须可观察，不能静默掩盖持续性缓存故障。

## 9. 异步生命周期

完整文件下载使 controller 从同步创建变为异步创建，因此必须覆盖以下竞态：

```text
页面开始下载
→ 用户退出页面
→ 下载完成并返回 controller
```

此时应满足：

- 不再初始化或播放返回的 controller。
- 立即释放已经创建但无人接管的 controller。
- 不对已销毁 State 调用 `setState`。
- 下载任务是否继续，由缓存策略决定，而不是由 UI 假装任务不存在。

还需要保持：

- controller 未创建时，`dispose` 可以安全执行。
- controller 已创建但初始化失败时，仍会被释放。
- 多次构建不会重复创建下载任务或 controller。
- 将来允许 `videoUrl` 改变时，需要显式取消旧结果或让旧结果失效。

## 10. 缓存身份、过期与淘汰

### 10.1 Cache key

优先级：

1. 稳定的 `videoId + contentVersion`。
2. 后端提供的内容 hash 或稳定资源 key。
3. 学习项目中暂时使用规范化 URL。

如果生产 URL 含签名、token 或短期查询参数，不能无条件把完整 URL 当长期身份，否则同一视频会重复缓存。反过来，也不能只删除所有查询参数；当查询参数代表不同清晰度、剪辑版本或授权内容时，会产生错误复用。

### 10.2 有效性

有效性可以综合：

- 服务端 `Cache-Control`、ETag 或 Last-Modified。
- App 配置的最长保留时间。
- 业务内容版本。
- 本地文件存在性和必要的完整性校验。

第一阶段的具体缓存天数应在实施时根据视频大小和测试场景决定，不在本文档中固定。

### 10.3 淘汰

缓存必须同时考虑：

- 最近最少使用顺序。
- 最大文件数量。
- 最大磁盘字节数。
- 最长未使用时间。
- 系统主动清理临时目录的可能性。

只限制文件数量对视频并不充分：两个相同数量的视频集合可能相差数 GB。若第一阶段采用的缓存库只能方便地限制数量，应明确这是阶段性能力，并把总字节数治理作为升级条件。

## 11. 状态与错误要求

播放器页面至少需要表达：

| 状态 | 用户看到什么 | 可执行动作 |
| --- | --- | --- |
| 查询缓存/下载中 | 明确的准备状态 | 可以离开页面 |
| 初始化播放器 | 视频区域 loading | 可以离开页面 |
| 播放成功 | 视频与控制层 | 播放、暂停、全屏 |
| 获取文件失败 | 具体但不泄漏内部信息的错误 | 重试 |
| 播放器初始化失败 | 播放失败提示 | 重试或返回 |

不要用额外延迟、假 loading、吞错或无限重试掩盖真实状态。

下载进度属于缓存获取状态；播放进度和 `controller.value.buffered` 属于播放器状态。它们可以在同一个视觉进度条中组合，但数据含义不能混为一谈。

## 12. 关键方案决策

| 决策点 | 方案 | 判断 |
| --- | --- | --- |
| Widget 直接调用缓存库 | 文件少，但 UI 同时承担下载和播放职责 | 不采用 |
| 注入 `Future<File>` 读取器 | 缓存隔离简单，但播放器被固定为本地文件来源 | 可用但不推荐作为长期接缝 |
| 注入 controller 工厂 | 来源可替换，生命周期所有权仍明确 | 第一阶段推荐 |
| 外部传入已初始化 controller | 播放 UI 很纯，但所有权和错误状态被推到页面外 | 当前不采用 |
| 完整文件缓存 | 实现简单，适合短 MP4；首次播放需等待完整下载 | 第一阶段采用 |
| 边播边缓存 | 起播快且少浪费流量，但需原生缓存或本地代理 | 后续按触发条件升级 |
| HLS/DASH 分片缓存 | 支持长视频和多码率，但需要媒体与服务端链路配合 | 第一阶段不做 |

## 13. 阶段级演进

实施时必须先重新读取当时的代码和依赖，再决定具体类名、字段和修改顺序。本文档只固定阶段目标：

| 阶段 | 做什么 | 不做什么 | 完成标志 |
| --- | --- | --- | --- |
| 来源接缝 | 让播放器通过稳定工厂获得 controller | 不改变现有播放行为 | 网络实现下行为与基线一致 |
| 完整文件缓存 | 增加缓存工厂并切换组合入口 | 不添加分片、预加载和下载中心 | 首次下载后从本地文件播放 |
| 生命周期加固 | 覆盖退出、失败、损坏缓存和重试 | 不用延迟或吞错止血 | 无泄漏、无销毁后更新 |
| 缓存验证 | 验证命中、过期、淘汰和离线重播 | 不把临时缓存承诺为永久离线 | 行为与缓存策略一致 |
| 播放体验 | 增加播放、缓冲和必要的下载反馈 | 不混淆三种进度语义 | 用户能理解当前状态 |

### 13.1 当前实施进度

2026-09-04 已开始第一阶段的“来源接缝”落地：

- 已新增 `lib/chapter_16/player/source/video_controller_factory.dart`，定义 controller 创建接口和当前网络实现。
- `VideoPlayerSection` 正在从直接创建 network controller，改为通过 `controllerFactory` 异步创建 controller。
- 当前目标仍是保持网络播放行为不变，尚未接入完整文件缓存、缓存库、过期淘汰或下载进度。
- 本阶段重点验证异步创建、页面退出、controller 初始化和 `dispose` 的所有权边界。

## 14. 升级触发条件

出现以下事实时，再从完整文件缓存升级：

| 观察到的事实 | 下一步能力 |
| --- | --- |
| 首次播放等待明显不可接受 | 边播边缓存或流媒体分片 |
| 用户通常只看视频开头 | 按字节范围或分片缓存，避免完整下载 |
| 页面变成上下滑动视频流 | 当前视频优先级与下一条首段预加载 |
| 视频出现多清晰度 | HLS/DASH 与自适应码率 |
| 用户要求永久离线观看 | 独立离线下载领域与后台任务 |
| 大量缓存导致磁盘压力 | 按总字节数的 LRU 和缓存管理页 |
| URL 经常过期 | 稳定内容 ID 与刷新 URL 契约 |
| 内容受 DRM 或授权限制 | 使用平台支持的受保护离线方案 |

不要仅因为“大型平台都这么做”就提前加入分片代理、后台服务或复杂任务数据库。升级应由已观察到的产品和性能信号触发。

## 15. 架构验收标准

- `VideoControls` 不导入任何缓存包或缓存实现。
- `VideoPlayerSection` 不导入具体缓存包。
- 更换 controller 工厂不需要修改控制层。
- controller 只初始化一次、释放一次。
- 缓存命中时不重复下载。
- 缓存未命中时不会同时发起独立播放请求和完整文件下载。
- 未完成或损坏的文件不会作为有效缓存播放。
- 页面在下载期间退出不会导致 controller 泄漏或销毁后更新。
- 普通态和全屏态复用同一 controller。
- 缓存有明确的身份、过期和淘汰规则。
- Android、iOS、macOS 的文件播放行为分别验证；Web 范围明确。

## 16. 给实施 Agent 的动态检查清单

实施前：

- 重新读取 `lib/chapter_16/player/` 当前代码，不能假设本文档创建时的代码仍未变化。
- 检查 `pubspec.yaml`、锁定版本和所选缓存库当前 API。
- 确认当前目标平台和是否需要 Web 回退。
- 检查用户已有未提交修改，不覆盖或回退。
- 先记录网络播放基线，再建立来源接缝。

实施后：

- 执行格式化和 `fvm flutter analyze lib/chapter_16`。
- 运行相关 focused 测试和工程测试。
- 手动验证首次加载、再次进入、断网重播、失败重试和下载中退出。
- 检查 controller、listener 和异步结果的释放路径。
- 根据实际实现更新本指南中的设计事实，但不要写入易过期的逐行操作步骤。

## 17. 参考资料

- Flutter `video_player`：<https://pub.dev/packages/video_player>
- Flutter Cache Manager：<https://pub.dev/packages/flutter_cache_manager>
- Android Media3 播放缓存：<https://developer.android.com/media/media3/exoplayer/network-stacks>
- Android Media3 离线下载：<https://developer.android.com/media/media3/exoplayer/downloading-media>
- Apple AVFoundation 离线播放与存储：<https://developer.apple.com/documentation/avfoundation/offline-playback-and-storage>
- Bilibili 视频播放公开专利：<https://patentimages.storage.googleapis.com/80/96/8a/f77dcd08b79296/CN111510789B.pdf>

这些资料用于理解能力边界。具体依赖版本和平台 API 必须在实施时重新核对。
