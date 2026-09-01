# 22 Repository 与数据模型分层方法论

## 这份手册解决什么问题

页面直接拼 `Map<String, dynamic>`、直接调用 Dio、直接判断错误码，会让 UI 和后端协议绑死。字段一改，多个页面一起坏；错误策略一改，到处补丁。

这份手册用于划清 ApiClient、Repository、Model 和 UI State 的职责边界。

## 什么时候使用

- 适合：新增接口、改接口参数、接入新 model、整理页面请求逻辑、写测试。
- 不适合：完全静态页面、没有数据来源的局部展示。

## 一句话原则

Model 负责数据形状，Repository 负责业务语义，UI 只负责状态展示和用户动作。

## 决策表

| 内容 | 放在哪里 | 原因 |
| --- | --- | --- |
| baseUrl、header、timeout、interceptor | ApiClient / Dio 层 | 网络基础设施 |
| 接口 body 拼装 | params / repository | 避免 UI 关心协议细节 |
| JSON 字段映射 | model | 类型安全，可生成 |
| 错误码转业务错误 | repository / error mapper | 统一处理 |
| loading/error/empty/data | UI state / provider | 页面消费 |
| 重试、刷新、提交动作 | AsyncNotifier / repository | 可测试 |
| mock 数据 | fake repository | 不污染真实 API |

## 固定检查问题

```text
这个字段是后端 DTO，还是页面展示状态？
接口参数由页面直接拼，还是有 params/model 承接？
错误在网络层、业务层、UI 层分别做什么？
model 改动是否需要跑 codegen？
这个 repository 能不能用 fake 实现测试？
```

## Flutter 实现拆分

```text
ApiClient
  只处理 HTTP/SDK 调用和原始响应。

Repository
  提供业务方法，例如 createTask、loadGallery、saveResult。

Model
  表达接口入参、返回值、枚举和序列化。

Provider / VM
  调用 repository，并把结果转成页面状态。

Widget
  展示状态，不直接拼协议。
```

## 常见坏味道

- 页面里到处写 `Map<String, dynamic>`。
- model 字段可空性随便写，导致运行时崩。
- 手改 `*.g.dart`。
- repository 只是一层无意义转发，没有隐藏任何细节。
- UI 根据 HTTP status code 做业务判断。
- 一个 model 同时承担接口 DTO、表单状态、UI 展示状态。

## 验收标准

- 页面不直接依赖 Dio 和原始 JSON。
- model 有明确 fromJson/toJson 或 codegen。
- repository 方法名表达业务动作，而不是 HTTP 路径。
- 错误映射集中处理。
- JSON roundtrip 或 repository fake 可以覆盖核心行为。

## 对 SpellAI 的映射

- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/repository/remote/api.dart`：远程 API 大入口。
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/model/`：接口模型和生成文件。
- `/Users/dev/Documents/Projects/flutter-spell-ai/lib/ui/pages/image2video/params/`：视频生成参数装配。

读 SpellAI 时不要从 `api.dart` 顶到尾硬读。先选一个页面按钮，追到 repository/API、params、model、UI 状态，再沉淀链路。
