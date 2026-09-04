# learn_flutter

这是一个 Flutter/Dart 学习项目，用于从 Web 前端背景迁移到 Flutter，并最终接手：

`/Users/dev/Documents/Projects/flutter-spell-ai`

学习主线已经沉淀在 `notes/`：

- `notes/00-前言.md`：学习目标、阶段和完成标准
- `notes/01-索引.md`：学习路线、项目接手、方法论手册和日志入口
- `notes/10-音视频与媒体能力.md`：图片、音频、视频、相册、权限和播放控制专题
- `notes/12-flutter-spell-ai接手导读.md`：目标项目接手路线
- `notes/18-接手陌生Flutter项目方法论.md`：接手任何 Flutter 项目前的读码路线
- `notes/98-笔记模板.md`：新增学习笔记和方法论手册时的统一模板
- `notes/99-学习日志与任务看板.md`：当前进度和下一步

每次 agent session 的入口文件是 `AGENTS.md`。

## 推荐入口

如果是继续学习：

1. 先看 `notes/99-学习日志与任务看板.md` 的当前阶段和下一步。
2. 再看 `notes/01-索引.md` 选择学习章节或方法论手册。
3. 需要试验代码时，从 `lib/learning_home_page.dart` 进入对应 chapter。

如果是准备接手 SpellAI：

1. 先看 `notes/18-接手陌生Flutter项目方法论.md`。
2. 再看 `notes/12-flutter-spell-ai接手导读.md`。
3. 遇到具体问题时，回查对应章节或方法论手册。

## Flutter 常用命令

```bash
# 检查设备
fvm flutter devices

# 运行到默认设备
fvm flutter run

# 运行到指定设备
fvm flutter run -d <device_id>

fvm flutter run -d adb-a995b2d2-vlzDfF._adb-tls-connect._tcp | awk '!/InsetsSource|InsetsController|ActivityThread|AssistStructure|ViewRootImplStubImpl/ { print; fflush() }'

fvm flutter run -d 192.168.4.236:35891 2>&1 | awk '!/InsetsSource|InsetsController|ActivityThread|AssistStructure|ViewRootImplStubImpl/ { print; fflush() }'

# 运行起来后，终端里可以按
r   热重载 Hot reload
R   热重启 Hot restart
q   退出运行
```
