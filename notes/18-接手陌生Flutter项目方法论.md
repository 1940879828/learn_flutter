# 18 接手陌生 Flutter 项目方法论

## 这份手册解决什么问题

拿到一个陌生 Flutter 项目时，最容易犯的错是先钻进某个页面改代码，然后才发现它背后连着初始化、路由、状态、远程接口、本地缓存、权限、支付、广告或平台配置。

这份手册解决的是：如何在改动前快速建立项目地图，判断哪里能先动、哪里必须先验证、哪里暂时不要碰。

核心原则：

```text
先画执行路径，再判断改动边界。
先找低风险入口，再进入高风险链路。
先验证本地门禁，再谈真实设备和线上影响。
```

## 第一轮只读路线

第一轮目标不是读懂所有业务，而是回答 8 个问题：

| 问题 | 先看哪里 | 产出 |
| --- | --- | --- |
| App 怎么启动 | `main.dart`、`entry.dart`、`app.dart` | 初始化顺序图 |
| 页面怎么到达 | `routing/`、路由枚举、导航 helper | 页面路径图 |
| 全局状态从哪里来 | `ProviderScope`、Riverpod providers、service locator | 状态注入图 |
| 数据怎么回来 | API client、repository、model | 请求链路图 |
| 本地数据放哪里 | prefs、SQLite、文件目录、缓存池 | 存储分层表 |
| 平台能力怎么接 | 权限、相册、相机、视频、WebView、推送 | 平台能力表 |
| 高风险模块有哪些 | 登录、支付、广告、Firebase、数据库迁移 | 禁动清单 |
| 怎么验证改动 | analyze、test、build、真机路径 | 门禁清单 |

## 读码顺序

### 1. 先读项目规则

先看：

```text
AGENTS.md
README.md
analysis_options.yaml
pubspec.yaml
```

确认：

- Flutter/Dart 版本。
- 是否必须使用 FVM。
- 代码生成命令。
- 多语言生成命令。
- 私有依赖和平台配置。
- 不允许改的生成文件、密钥、线上配置。

### 2. 读启动入口

先找：

```text
lib/main.dart
lib/main_debug.dart
lib/entry.dart
lib/app.dart
```

目标是画出：

```text
main
-> 环境选择
-> Flutter binding
-> 全局服务初始化
-> ProviderScope / app scope
-> MaterialApp.router
-> 首屏
```

重点观察：

- 是否 `deferFirstFrame`。
- 是否有 Firebase、IAP、广告、数据库、缓存池初始化。
- 哪些初始化必须完成首屏才能出现。
- 哪些初始化是后台或可失败的。

不要一开始就改初始化顺序。初始化链路的小改动很容易变成白屏、登录态异常、支付状态异常或埋点丢失。

### 3. 读路由地图

先看：

```text
lib/routing/
```

确认：

- path 如何定义。
- `go`、`push`、`replace`、`pushReplacement` 是否被封装。
- 页面参数来自 path、query 还是 extra。
- 登录拦截、会员拦截、实验入口和弹窗路由在哪里。
- 返回值通过 `pop(result)` 还是全局状态传递。

读路由时不要只看目标页面。要反向找所有调用方，尤其是 `extra` 传参。`extra` 类型不一致是 Flutter 项目里很常见的隐藏崩溃点。

### 4. 读状态边界

先确认项目用的是：

- `setState`
- Riverpod
- Provider
- BLoC
- GetX
- service singleton
- 混合方案

读状态时问：

- 这个状态的拥有者是谁？
- 生命周期跟页面走，还是跟 App 走？
- 状态变化会 rebuild 多大范围？
- 异步错误放在哪里？
- 页面退出后异步结果会不会回来更新已销毁 UI？

状态边界没看清前，不要把逻辑从一个层随手搬到另一个层。

### 5. 读网络和 model

先看：

```text
lib/repository/
lib/engine/net/
lib/model/
```

确认：

- API 是否有统一 client。
- token、header、重试、取消、错误映射在哪里。
- repository 是否负责业务语义。
- model 是否用 `json_serializable` 或其他 codegen。
- 生成文件是否禁止手改。

页面不要直接拼复杂接口 body。复杂 body 应该由 params、repository 或 builder 负责，否则后续很难测试，也容易让 UI 混入业务副作用。

### 6. 读本地存储

把本地数据按用途分层：

| 数据类型 | 常见位置 | 风险 |
| --- | --- | --- |
| 小配置、开关、已读状态 | prefs / shared_preferences | 版本升级后语义漂移 |
| 结构化列表、历史记录 | SQLite / DAO | 迁移和数据一致性 |
| 图片、视频、缓存文件 | app documents/cache/tmp | 清理策略和磁盘占用 |
| 登录 token、敏感数据 | secure storage 或 SDK 内部 | 泄漏和退出清理 |

不要把所有本地状态都当成 `localStorage`。移动端有沙箱、系统权限、卸载清理、备份策略和平台差异。

### 7. 读平台能力

平台能力包括：

- 相机、相册、麦克风、通知、定位。
- WebView、视频播放器、地图、广告。
- 文件保存、分享、剪贴板。
- iOS/Android 原生配置。

每个能力都要确认：

- 触发时机。
- 权限预热。
- 拒绝后的降级路径。
- 真机和模拟器差异。
- 前后台切换后的生命周期。

平台能力不适合只靠 analyzer 判断，最终需要模拟器或真机验证。

### 8. 读商业化和线上能力

高风险模块包括：

- 登录和账号绑定。
- Firebase。
- 内购、订阅、金币、额度。
- 广告和归因。
- 埋点、Crashlytics。
- 数据库迁移。

第一次接手时先识别边界，不要把这些模块作为练手入口。它们的问题往往不是“代码能不能跑”，而是线上收入、账号状态、审核和数据一致性。

## 改动选型

### 低风险改动

适合第一批练手：

- 页面内纯 UI spacing、颜色、布局微调。
- 非关键文案，前提是按多语言流程处理。
- 空状态、loading、错误提示展示。
- 只读字段展示，字段已经存在且 model 已覆盖。
- debug-only 辅助信息。

判断标准：

```text
不改接口 body
不改持久化结构
不改权限时机
不改登录/支付/广告/Firebase
不改全局初始化顺序
能用本地步骤验证
```

### 中风险改动

需要 focused test 或完整手工路径：

- 单页面业务逻辑。
- 页面参数传递。
- repository 方法新增或改名。
- model 字段新增。
- provider 状态拆分。
- 列表筛选、排序、分页。

判断标准：

```text
改动影响一个功能闭环
有清楚输入输出
能写测试或复现步骤
失败时能回滚
```

### 高风险改动

需要完整链路验证，通常不作为第一次接手入口：

- 登录、退出、账号删除、token 刷新。
- 支付、订阅、金币、额度。
- 广告、归因、A/B 实验。
- 数据库迁移。
- 相册保存、系统权限、平台原生配置。
- App 初始化顺序。
- 私有依赖升级。

判断标准：

```text
影响账号、收入、权限、数据一致性、平台审核或线上观测。
```

## 修改前固定问题

动手前先回答：

```text
我要改的是哪个用户动作？
这个动作经过哪些页面、provider、repository、API、model、存储？
失败态有哪些？
是否涉及权限、账号、支付、广告、数据库或平台配置？
怎么验证成功？
怎么验证没有破坏旧路径？
```

答不出来时，先继续读码，不要急着改。

## Flutter 实现拆分检查

修改页面时，优先维持 feature-first：

```text
lib/ui/pages/<feature>/
  page.dart        页面入口、路由参数、Scaffold、顶层编排
  *.vm.dart        页面状态、订阅、数据加载、导航和副作用
  provider/        feature 内状态和派生值
  widget/          feature 内局部 UI
```

不要因为 UI 相似就抽全局组件。只有语义稳定、行为稳定、未来变化方向也一致，才放到共享层。

## 验证门禁

按改动风险选择：

| 改动 | 最小验证 |
| --- | --- |
| docs-only | 检查链接、路径、索引和拼写 |
| Dart 纯逻辑 | focused unit test + `fvm flutter analyze` |
| Widget/UI | focused widget test 或手工验收 + `fvm flutter analyze` |
| 路由 | 手工跑通进入、返回、参数、redirect |
| model/codegen | build_runner + JSON roundtrip test |
| l10n | 改 `.arb` + `fvm flutter gen-l10n` + 长文案布局检查 |
| 权限/媒体/platform view | 模拟器/真机验证 |
| 登录/支付/广告 | 测试账号、测试环境、完整回归路径 |

## 常见坏味道

- 只看目标页面，不找入口和调用方。
- 看到 `extra` 就直接强转，不确认所有来源。
- 在 Widget 里直接拼 API body 或处理复杂业务副作用。
- 把本地存储都当成简单 key-value。
- 手改 `*.g.dart` 或本地化生成文件。
- 为了绕过本机配置，修改生产配置或密钥读取逻辑。
- 只跑 analyzer，不做真实路径验证。
- 把高风险模块当成第一次练手入口。

## 对 SpellAI 的映射

接手 SpellAI 时，优先按这条路线：

```text
AGENTS.md
-> pubspec.yaml
-> lib/main.dart / lib/main_debug.dart
-> lib/entry.dart
-> lib/app.dart
-> lib/routing/router.dart / routers.dart
-> lib/repository/remote/api.dart
-> lib/model/
-> lib/ui/pages/image2video/
-> lib/utils/video_player_controllers.dart
-> lib/utils/album_utils.dart
-> lib/utils/images_helper.dart
```

第一次适合改：

- 局部文案和空状态。
- 小范围 UI 布局。
- 不改变接口参数的展示逻辑。
- 已存在字段的只读展示。

第一次不适合改：

- `App().init()` 初始化顺序。
- 登录和 Firebase。
- 内购、广告、金币、订阅。
- 相册权限和保存链路。
- 数据库迁移。
- 私有依赖版本。

## 完成标准

看完并应用这份手册后，应该能输出：

- 一张入口初始化图。
- 一张路由和页面参数图。
- 一张网络/model/repository 链路图。
- 一张本地存储和平台能力表。
- 一份高风险模块清单。
- 一个第一批可改的小任务列表。
- 对每个任务的验证门禁。
