# 14 Firebase 登录与账号状态

## 学习目标

- 理解 Firebase 登录链路：第三方 provider、Firebase credential、后端用户创建、auth state 广播。
- 能区分登录中、登录成功、用户取消、供应商失败、后端创建失败、已登录重复点击。
- 能把 Web Firebase 登录里的 token 刷新/后端同步模式迁移成 Flutter App 可观察的 service。
- 为接手 SpellAI 登录页、认证服务、Firebase 初始化和账号状态监听打基础。

## Web 前端迁移映射

- Web 的 OAuth provider 登录，对应 Flutter 中 Google / Apple / Facebook / LINE SDK。
- Web 的 session/user store，对应 Flutter 中 `Authentication` 单例和 Riverpod `StreamProvider`。
- Web 的 id token 传后端换业务用户，对应 SpellAI 中登录成功后调用后端创建/同步用户。
- Web 的 `401/403 → force refresh token → retry once`，对应 App 侧可抽成统一 token retry helper，避免每个 API 调用点自己判断登录失效。
- Web 的 route guard，对应移动端页面根据 `logged`、VIP、金币等状态调整 UI。

## 核心概念清单

- Firebase initialize
- provider credential
- `FirebaseAuth.instance.signOut()`
- id token
- backend create current user
- auth state stream
- loading 防重复点击
- login cancel / auth failed / backend failed
- logout
- token 摘要显示和完整用户 JSON 展示
- 后端 401/403 后强刷 ID token 重试一次

## 最小练习

- `lib/chapter_14/fake_firebase_auth_models.dart`：模拟 provider 登录、状态流、用户信息。
- `lib/chapter_14/firebase_auth_lab_page.dart`：包含“状态模拟”和“真实 SpellAI”两个页签。
- `lib/chapter_14/spellai_auth_config.dart`：从 `--dart-define` 读取 SpellAI Firebase / 后端配置，不在源码里写 key。
- `lib/chapter_14/spellai_auth_service.dart`：执行真实 provider 登录、Firebase ID token 获取、`POST /users`、`GET /users/{uid}` 和 401/403 token retry。
- `lib/chapter_14/spellai_auth_models.dart`：解析 token 摘要、SpellAI 用户资料和完整 raw JSON。

操作顺序：

1. 从首页打开 `14 Firebase 登录与账号状态`。
2. 点击 Google，观察 `登录中 → 已登录`。
3. 点击退出登录。
4. 开启 `模拟供应商认证失败`，再点击 Apple。
5. 开启 `模拟后端创建用户失败`，再点击 LINE。
6. 在登录中点击 `取消登录`，理解 cancel 和失败不是一回事。

真实 SpellAI 页签运行前需要传入本机配置，例如：

```bash
fvm flutter run \
  --dart-define=SPELLAI_SERVER_ENV=test \
  --dart-define=SPELLAI_FIREBASE_API_KEY=... \
  --dart-define=SPELLAI_FIREBASE_APP_ID=... \
  --dart-define=SPELLAI_FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=SPELLAI_FIREBASE_PROJECT_ID=... \
  --dart-define=SPELLAI_FIREBASE_STORAGE_BUCKET=... \
  --dart-define=SPELLAI_FIREBASE_AUTH_DOMAIN=... \
  --dart-define=SPELLAI_LINE_CHANNEL_ID=...
```

不要把上面的真实值提交到仓库；token 也只在运行时从 Firebase user 获取，页面只显示 mask 后的摘要。

## 目标项目观察

优先阅读：

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/engine/service/thirds/firebase_service.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/engine/service/thirds/authentication.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/login/login_page.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/login/login_button.dart`
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/config/firebase_options.dart`

本轮观察：

- `firebase_service.dart` 在 `FirebaseServer` 中初始化 Firebase、Analytics、FCM，并监听登录状态用于 iOS on-device conversion。
- `authentication.dart` 定义 `AuthProvider`、`LoginState`、`AuthInfo`，并通过 StreamProvider 暴露 auth/user/coins/vip 状态。
- `Authentication.login` 会先走 provider credential，再拿 Firebase id token，再调用后端创建当前用户；后端失败时会退出 Firebase 用户。
- `login_page.dart` 使用 `_loading` 防止登录过程返回，并监听 `onAuthChangedProvider` 登录成功后关闭页面。
- `login_button.dart` 使用本地化文案和统一按钮尺寸，真实项目里登录 UI 也要考虑多语言长度。
- 学习项目新增的真实页签复刻了 SpellAI 的关键后端契约：`POST /users` 使用 `UID` / `Id-Token` 头，随后 `GET /users/{uid}` 展示完整业务用户信息。
- 从 `learn-next` 迁移来的优化点：后端返回 401/403 时，先 `getIdToken(true)` 强刷并重试一次；仍失败再退出 Firebase，避免 Firebase 和业务用户状态分裂。

## 完成标准

- 能画出 provider 登录到业务用户创建的完整链路。
- 能解释登录取消、供应商失败、后端创建失败为什么要分开处理。
- 能读懂 SpellAI 登录页如何监听 auth state 并关闭页面。
- 能知道学习项目不写真实 Firebase key、测试账号或环境密钥。
- 能打开真实 SpellAI 页签，确认配置缺失提示、provider 登录按钮、token 摘要、Firebase user 和完整 SpellAI user JSON 的关系。

## QA 问答

### Q1：Firebase 登录成功是否等于业务登录成功？
不一定。Firebase 成功只代表拿到了认证用户，真实项目还要把 token 交给后端创建或同步业务用户。

### Q2：为什么登录失败时可能需要退出 Firebase？
如果 Firebase 用户已创建但后端用户创建失败，前后端状态会不一致，退出可以避免 UI 误判为已登录。

### Q3：为什么登录页要监听 auth state？
登录结果可能来自 SDK 回调、账号绑定或恢复状态，监听统一状态比只依赖按钮回调更稳。

### Q4：为什么页面不显示完整 ID token？
ID token 是 bearer token，展示完整值等同于把登录凭据暴露给屏幕录制、日志和截图。学习页只显示首尾 mask 和过期时间，完整 token 只用于请求头。
