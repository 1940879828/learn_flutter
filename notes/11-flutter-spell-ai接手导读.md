# 11 flutter-spell-ai 接手导读

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

1. `README.md`：目录结构和项目约定。
2. `AGENTS.md`：目标仓库对 agent 的要求。
3. `pubspec.yaml`：依赖、assets、fonts、插件和生成能力。
4. `lib/main.dart` / `lib/main_debug.dart`：入口差异。
5. `lib/entry.dart`：真实启动流程。
6. `lib/app.dart`：全局服务、provider、pool。
7. `lib/routing/router.dart` / `lib/routing/routers.dart`：页面和跳转。
8. `lib/repository/remote/`：远程 API。
9. `lib/model/`：业务数据结构。
10. `lib/ui/pages/image2video/`：视频能力入口。
11. `lib/utils/album_utils.dart` / `lib/utils/images_helper.dart`：图库和权限。

## 重点模块

### 入口与应用服务

- `lib/main.dart`
- `lib/main_debug.dart`
- `lib/entry.dart`
- `lib/app.dart`

关注初始化顺序、环境配置、全局服务、provider 注入和错误处理。

### 路由与页面

- `lib/routing/router.dart`
- `lib/routing/routers.dart`
- `lib/ui/pages/`

关注页面参数、`extra` 传参、返回栈、图片/视频创建入口。

### 数据与网络

- `lib/repository/remote/`
- `lib/repository/db/`
- `lib/model/`
- `lib/engine/net/`

关注 API 统一入口、错误模型、JSON 生成、本地数据库。

### 媒体能力

- `lib/ui/pages/image2video/`
- `lib/engine/photo_lab/`
- `lib/engine/video_drawing/`
- `lib/utils/video_player_controllers.dart`
- `lib/utils/album_utils.dart`
- `lib/utils/images_helper.dart`
- `lib/engine/io/`

关注图片选择、视频模板、视频播放、文件下载、相册保存、权限和失败提示。

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

- 跑项目依赖安装。
- 跑 analyze/test。
- 画出入口、路由、网络、媒体链路。

### 第二步：改低风险 UI

- 修改文案、样式、小组件。
- 不碰支付、登录、Firebase、权限、数据库迁移。

### 第三步：改单一页面逻辑

- 找一个页面内可验证的小需求。
- 写 focused test 或手工验收步骤。
- 修改后跑 analyze/test。

### 第四步：进入媒体/业务链路

- 先读完整链路。
- 明确输入、输出、权限、失败状态。
- 再动图片/视频/音频相关代码。

## 待补充

- [ ] 目标项目能否在本机完整运行。
- [ ] 常用 flavor / debug entry。
- [ ] API 环境配置方式。
- [ ] 登录所需本地配置。
- [ ] 图片转视频完整链路图。
- [ ] 新增音频能力的技术选型。

## QA 问答（面试官常问）

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
