# 12 flutter-spell-ai 接手导读

## 目标

本章在完成系统学习后使用，用于把 Flutter/Dart 能力映射到真实项目 `/Users/dev/Documents/Projects/flutter-spell-ai`。

## 已知项目画像

- 项目名：Spellai
- 类型：Flutter 移动端应用
- 方向：AI 图片/视频生成、图库、模板、聊天/角色、内购、广告、多语言、Firebase、数据分析
- Flutter：`3.35.7`
- Dart SDK：`>=3.9.0 <4.0.0`
- 包名：
  - Android：`com.ai.polyverse.spell.pro`
  - iOS：`com.ai.polyverse.spell.ios`

## 第一轮阅读顺序

第一轮目标不是理解所有业务，而是画出“应用如何启动、页面如何到达、数据如何回来、媒体如何被保存”的路径。

1. `AGENTS.md`：确认目标项目规则。重点记住使用 FVM、不要手改生成文件、API 写在 `lib/repository/remote/api.dart`、model 写在 `lib/model/`。
2. `pubspec.yaml`：确认 Flutter `3.35.7`、Dart `>=3.9.0 <4.0.0`，标出 `dio`、`go_router`、`riverpod`、`shared_preferences`、`sqflite`、`path_provider`、`permission_handler`、`image_picker`、`photo_manager`、`video_player`、Firebase、内购、广告和私有依赖。
3. `lib/main.dart` / `lib/main_debug.dart`：确认 production/test 环境入口差异。
4. `lib/entry.dart`：看 `AppScopedView` 如何创建 `MaterialApp.router`、`ProviderScope`、本地化、主题、根 Overlay。
5. `lib/app.dart`：看全局单例如何初始化 Prefs、Paths、Firebase、IAP、BusinessService、广告、缓存池、视频滤镜池等。
6. `lib/routing/router.dart` / `lib/routing/routers.dart`：从 `PageKeys` 看所有页面路径，再看 image2video、preview、login、shop 等高风险路由如何构建。
7. `lib/repository/remote/api.dart`：选 1-2 个 API 方法，不要整文件硬读。建议先看 `performDraw`、`performOneImageToVideoDraw`、`queryDrawProcess`。
8. `lib/model/`：优先看 API 返回用到的 model 源文件，再看对应 `*.g.dart` 了解生成结果；不要手改 `*.g.dart`。
9. `lib/ui/pages/image2video/`：从 `v_create_page.dart` 进入，再读 `i2v_create_widget.dart`、`e2v_create_widget.dart`、`t2v_create_widget.dart`、`providers/`、`params/`、`media/`。
10. `lib/utils/video_player_controllers.dart`、`lib/utils/album_utils.dart`、`lib/utils/images_helper.dart`：理解媒体来源、播放器创建、相册权限、内部文件保存。

## 重点模块

### 入口与应用服务

- `lib/main.dart`
- `lib/main_debug.dart`
- `lib/entry.dart`
- `lib/app.dart`

关注初始化顺序、环境配置、全局服务、provider 注入和错误处理。

本轮观察：

- `main.dart` 设置 `ServerEnv.production`，`main_debug.dart` 设置 `ServerEnv.test`。
- `initMain` 会 `deferFirstFrame`，等待 `App().init()` 完成后再 `runApp`，最后 `allowFirstFrame`。
- `entry.dart` 中 `ProviderScope` 禁止自动 retry，debug 下挂 `TalkerRiverpodObserver`。
- `App().init()` 有顺序初始化和并行/非重要初始化；Firebase、Prefs、Paths、设备 ID、IAP、广告、业务服务等都在这里进入全局生命周期。

### 路由与页面

- `lib/routing/router.dart`
- `lib/routing/routers.dart`
- `lib/ui/pages/`

关注页面参数、`extra` 传参、返回栈、图片/视频创建入口。

本轮观察：

- `PageKeys` 枚举同时保存 path 和 `show()` 方法，封装 `go/push/replace/pushReplacement`。
- `routers.dart` 用 `AppRoute` / `AdaptiveRoute` 建路由，很多页面依赖 `queryParameters` 和 `extra`。
- 图片转视频路由包括 `i2vCreatePage`、`i2vResultPage`、`f2vCreatePage`、`f2vList`、`filterPicker`、`slidePicker`。
- 内购、登录、订阅弹窗等使用自定义 adaptive dialog 约束，属于高风险 UI 路由。

### 数据与网络

- `lib/repository/remote/`
- `lib/repository/db/`
- `lib/model/`
- `lib/engine/net/`

关注 API 统一入口、错误模型、JSON 生成、本地数据库。

本轮观察：

- `lib/repository/remote/api.dart` 是远程 API 大入口，使用 `appDio`、`postPlus`、`DioPlusOptions`、`CancelToken`、`RetryPolicy`。
- `performDraw` 会从 `PromptBuilderParams` 拼 body，再用 `DrawResultModel.fromJson` 解析。
- `performOneImageToVideoDraw` / `performTTVDraw` / `performElementToVideoDraw` 会从 `VRenderParams` 和 extra 模型拼视频生成参数。
- `lib/model/result.dart` 提供 `Result<T>`、`VariableList<T>` 状态容器。
- `lib/model/app_error.dart` 把 `DioException` 映射为 network、timeout、cancel、unauthorized、server、unknown 等类型。
- `lib/model/` 中大量 `*.g.dart` 是 `json_serializable` 产物，阅读时看源文件，更新时跑生成命令。

### 媒体能力

- `lib/ui/pages/image2video/`
- `lib/engine/photo_lab/`
- `lib/engine/video_drawing/`
- `lib/utils/video_player_controllers.dart`
- `lib/utils/album_utils.dart`
- `lib/utils/images_helper.dart`
- `lib/engine/io/`

关注图片选择、视频模板、视频播放、文件下载、相册保存、权限和失败提示。

本轮观察：

- `video_player_controllers.dart` 根据 `asset/file/network/uri` 创建真实 `VideoPlayerController`。
- `v_create_page.dart` 用 `TabController` 管理 I2V/E2V/T2V 三个入口，页面离开时释放 tab controller。
- `ResultVideoPlayer` 用 file controller 播放结果视频，初始化前显示 loading/cover，dispose 时移除 listener 并释放 controller。
- `VideoView` 更像列表播放器：结合下载、可见性、播放器池和独占事件，决定何时创建/释放播放器。
- `album_utils.dart` 负责保存图片/视频到系统相册，处理 iOS limited 和 Android 旧版存储权限，并写入本地图库记录。
- `images_helper.dart` 负责 `image_picker`、内部图片目录、命名、尺寸读取和临时图清理。

### 商业化与线上能力

- Firebase
- Google/Facebook/Line 登录
- 广告
- 内购
- 分析与 Crashlytics
- 多语言

这些模块不要一开始就深挖，先能识别边界，等需要改相关功能时再专题学习。

## 接手策略

### 第一步：只读不改

- 跑项目依赖安装前先确认私有 hosted/git package 是否可访问。
- 能跑则跑 `fvm flutter pub get`、`fvm flutter analyze`、已有 focused test。
- 如果本机缺少私有依赖、证书、Firebase、本地配置，记录缺口，不要随意改配置绕过。
- 画出入口、路由、网络、媒体链路。

### 第二步：改低风险 UI

- 修改文案、样式、小组件。
- 不碰支付、登录、Firebase、权限、数据库迁移。
- 优先选无远程请求、无持久化、无权限、无多语言生成的局部页面。
- 改完至少跑 analyze 和对应页面的手工验收。

### 第三步：改单一页面逻辑

- 找一个页面内可验证的小需求。
- 写 focused test 或手工验收步骤。
- 修改后跑 analyze/test。
- 如果页面依赖 provider/pool，先确认状态拥有者和 dispose/refresh 触发点。
- 如果页面依赖 route extra，先确认调用方是否都传了同一类型。

### 第四步：进入媒体/业务链路

- 先读完整链路。
- 明确输入、输出、权限、失败状态。
- 再动图片/视频/音频相关代码。
- 视频链路要额外确认 controller 生命周期、下载状态、页面可见性、App 前后台行为。
- 相册链路要额外确认 iOS limited、Android 版本差异、保存失败提示和本地图库记录。

## 第一批可以先改的小功能类型

- 纯 UI 文案和 spacing 调整，但如果文案来自 `.arb`，要按 l10n 流程处理。
- 某个页面内的非关键提示卡片、空状态、按钮禁用态展示。
- 不改变接口 body 的列表筛选、排序、局部显示逻辑。
- 只读型 model 字段展示，前提是字段已存在且 fromJson 已覆盖。
- 学习性质的日志或 debug-only 辅助显示，避免进入生产行为。

## 暂时不要碰的模块

- 登录、认证、Firebase、Line/Facebook/Google sign-in。
- 内购、金币、订阅、广告和打点归因。
- 数据库迁移、本地图库 DAO、用户资产持久化。
- `App().init()` 初始化顺序和全局单例生命周期。
- 图片/视频保存到系统相册、权限请求、平台原生配置。
- `*.g.dart`、`localization_intl_*.dart` 等生成文件。
- 私有 package 版本、Flutter/Android/iOS 原生构建配置。

## 风险边界

| 区域 | 风险 | 第一次接手建议 |
| --- | --- | --- |
| 入口初始化 | 白屏、服务未就绪、打点/登录状态异常 | 只读，先画顺序 |
| 路由 extra/query | 类型转换崩溃、返回栈异常 | 先找所有调用方 |
| 网络 API | 参数错、重试/取消失效、错误提示错 | 先写 focused 验证 |
| model/codegen | 字段丢失、生成文件漂移 | 改源文件后跑 build_runner |
| 权限/相册 | 审核风险、保存失败、limited 误判 | 真机验证后再改 |
| 视频播放 | 泄漏、黑屏、列表卡顿 | 先查 dispose 和可见性 |
| 支付/广告/Firebase | 线上收入和归因风险 | 不作为第一批练手 |

## 待后续实机确认

- 目标项目能否在本机完整运行。
- 私有 hosted package、git package、Firebase、本地环境配置是否齐全。
- 常用 flavor / debug entry 和真实调试命令。
- 登录所需本地配置和测试账号策略。
- 图片转视频完整链路图，包括上传、渲染、轮询、结果页、保存相册。
- 新增音频能力的技术选型：短音效、长音频、录音、音视频混合分别评估。

## QA 问答

### Q1：接手一个大型 Flutter 项目时，你先看什么文件？
先看入口（main/entry）、路由、状态注入、网络层、模型层，再看核心业务页面。先建立“程序执行路径”，再看 UI 表现。

### Q2：如何快速判断某处功能是否“可改”？
看依赖链、状态边界和持久化影响：有无副作用、是否影响跨模块状态、是否涉及权限或支付，优先选择可回滚、可验证的小入口。

### Q3：这个项目的 `assets`、`.arb`、`.g.dart` 为什么都要保守改？
因为它们牵涉构建产物与多语言、数据模型一致性。错误改动会引发运行期崩溃或平台回归。

### Q4：你会如何验证音视频链路改动不踩坑？
明确输入输出、权限、失败态、播放态、保存态，先做离线路径再做端到端路径，最后验证主流程里每个状态都有用户可见反馈。

### Q5：面对私有插件和 git 依赖，你怎么降低改动风险？
先确认版本来源和变更窗口，避免在缺链路验证下升级；优先减少触达面，必要时隔离测试用例验证 API 行为。
