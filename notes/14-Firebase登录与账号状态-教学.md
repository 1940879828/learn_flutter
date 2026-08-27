# 14 Firebase 登录与账号状态 - 教学正文

这一章先用 fake service 学状态链路，再用真实 SpellAI 页签把 Firebase token 和后端用户同步跑通。核心原则仍然不变：配置、token、测试账号不进源码。

## 先看结论

登录链路可以拆成：

```text
用户点击 provider
→ 第三方 SDK 获取 credential
→ FirebaseAuth 登录
→ 读取 id token
→ 后端创建/同步业务用户
→ 后端 401/403 时强刷 token 重试一次
→ 更新 Authentication 状态
→ auth stream 通知 UI
```

## 练习文件

- `notes/14-Firebase登录与账号状态.md`
- `lib/chapter_14/fake_firebase_auth_models.dart`
- `lib/chapter_14/firebase_auth_lab_page.dart`
- `lib/chapter_14/spellai_auth_config.dart`
- `lib/chapter_14/spellai_auth_service.dart`
- `lib/chapter_14/spellai_auth_models.dart`
- 目标项目的 `firebase_service.dart`、`authentication.dart`、`ui/pages/login/`

## 第 1 步：先分清两种用户

Firebase user 不等于业务 user。

Firebase 解决“这个人是谁”；业务后端解决“这个人在 SpellAI 里有什么权限、金币、VIP、图库、历史记录”。

所以真实项目登录成功后，还要把 id token 交给后端。

## 第 2 步：把 Web 登录实现迁移成 App 链路

`learn-next` 里的 Firebase 登录实现有一个值得迁移的设计：

```text
先用当前/cached ID token 请求后端
→ 如果后端返回 401/403
→ Firebase getIdToken(true) 强刷
→ 同一个请求重试一次
→ 仍失败才清理登录态
```

Flutter App 里没有 `signInWithPopup`、Zustand、Next Server Action，但这个错误恢复策略本身可以复用。学习项目的 `SpellAiAuthService._withTokenRetry` 就是这个迁移版。

## 第 3 步：理解状态

最少要分清：

- `logging`：正在打开 provider 或等待后端。
- `signedIn`：业务链路完成。
- `canceled`：用户主动关闭，不是错误。
- `authFailed`：Google/Apple/Facebook/LINE 供应商失败。
- `backendFailed`：Firebase 成功但后端用户创建失败。

这些状态对应的 UI 文案和恢复动作不同，不能都当成一个“登录失败”。

## 第 4 步：做最小练习

课堂操作：

1. 打开 `14 Firebase 登录与账号状态`。
2. 点击 Google，观察状态变成已登录。
3. 再点 Apple，观察“已经登录”路径。
4. 点击退出登录。
5. 打开供应商失败开关，点击 Facebook。
6. 打开后端失败开关，点击 LINE。
7. 登录中点击取消登录。

真实 SpellAI 页签操作：

1. 用 `--dart-define` 传入 SpellAI Firebase 配置和后端环境。
2. 点击 `恢复当前用户`，确认 Firebase 当前是否已有登录态。
3. 点击 Google / Apple / Facebook / LINE，观察 `供应商认证中 → Firebase 已登录 → 同步 SpellAI 后端用户 → 业务登录完成`。
4. 查看 `Firebase 用户`、`ID token 摘要`、`SpellAI 用户摘要`、`完整 SpellAI 用户 JSON`。
5. 点击退出登录，确认 Firebase 和本地 provider 状态都清空。

## 第 5 步：回到 SpellAI

重点读：

- `engine/service/thirds/firebase_service.dart`
- `engine/service/thirds/authentication.dart`
- `ui/pages/login/login_page.dart`
- `ui/pages/login/login_button.dart`

本轮已观察到：

- Firebase 初始化在 `FirebaseServer` 中完成。
- 登录状态由 `Authentication` 单例持有，并用 Riverpod `StreamProvider` 暴露。
- `AuthProvider` 覆盖 Apple、Facebook、Google、LINE、anonymous 等 provider id。
- `LoginState` 明确区分 cancel、authFailed、createFailed、requestFailed、alreadyLinked。
- 登录页使用 `_loading` 和 `PopScope` 防重复/防返回，并监听 `onAuthChangedProvider`。
- 后端创建用户走 `POST /users`，headers 里带 `UID` 和 `Id-Token`。
- 用户资料走 `GET /users/{uid}`，返回 `custom_uid`、`user_name`、`is_vip`、`draw_num`、chat 剩余次数等业务字段。

## 完成标准

- 能解释 Firebase user 与业务 user 的边界。
- 能说清登录过程为什么需要 loading 锁。
- 能解释 401/403 后为什么只强刷 token 重试一次。
- 能定位 SpellAI 登录按钮文案来自多语言文件，登录动作来自 `Authentication().login(provider)`。

## QA 问答

### Q1：为什么真实配置不写进学习项目？
Firebase client config 虽然通常不是服务端密钥，但它仍然属于环境配置。学习项目用 `--dart-define` 注入，避免把不同环境、测试账号、临时 token 或本机配置写进 git。

### Q2：为什么登录中要禁用按钮？
避免并发打开多个 provider 登录页，也避免后端创建用户时出现重复请求。

### Q3：什么改动属于登录高风险？
provider 配置、token 传递、后端创建用户、退出逻辑、账号绑定、删除账号、VIP/金币同步都属于高风险。

### Q4：真实 App 和 Web 最大差异是什么？
Web 是 popup/redirect；App 是 native provider SDK、bundle id、URL scheme、SHA、平台回调和 app lifecycle。差异主要在入口和配置，后端 token 同步链路可以保持一致。
