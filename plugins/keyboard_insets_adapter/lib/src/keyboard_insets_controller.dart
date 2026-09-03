// 持有这些状态，并提供改变状态/触发动作的方法，比如处理原生事件、更新 notifier、dismiss 键盘。
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'keyboard_insets_state.dart';

// 保存键盘高度、进度、是否可见。
class KeyboardInsetsController extends ChangeNotifier {
  KeyboardInsetsController();

  // 方法通道 Flutter 通过它喊原生：执行一下 dismiss，然后原生回一个结果。
  static const MethodChannel _methodChannel = MethodChannel(
    'keyboard_insets_adapter',
  );

  // 键盘高度
  final ValueNotifier<double> heightNotifier = ValueNotifier(0);
  // 键盘动画进度 0～1
  final ValueNotifier<double> progressNotifier = ValueNotifier(0);
  // 键盘是否可见
  final ValueNotifier<bool> isVisibleNotifier = ValueNotifier(false);
  // 完整键盘状态快照 创建一份“键盘当前是隐藏的”默认状态
  final ValueNotifier<KeyboardInsetsState> stateNotifier = ValueNotifier(
    const KeyboardInsetsState.hidden(),
  );

  double get height => heightNotifier.value;
  double get progress => progressNotifier.value;
  bool get isVisible => isVisibleNotifier.value;
  KeyboardInsetsState get state => stateNotifier.value;

  // 收起键盘
  Future<void> dismiss({bool keepFocus = false}) async {
    try {
      await _methodChannel.invokeMethod<void>('dismiss', {
        // keepFocus 控制的是：收起键盘时，要不要保留输入框焦点
        'keepFocus': keepFocus,
      });
    } on MissingPluginException {
      // 如果原生插件没注册成功，或者当前环境根本没有这个插件实现
      // 比如 在 macOS/Web/Desktop 上跑，但插件只实现了 iOS/Android
      if (!keepFocus) {
        // 找到当前正在聚焦的输入框，让它失去焦点。
        FocusManager.instance.primaryFocus?.unfocus();
      }
    }
  }

  // 把原生传来的某一帧键盘状态，分发到 Dart 侧的几个状态出口里。
  void handleNativeEvent(KeyboardInsetsState nextState) {
    // 保存完整的一帧键盘状态
    stateNotifier.value = nextState;
    // 单独更新“键盘是否可见”
    isVisibleNotifier.value = nextState.isVisible;

    // 如果这帧不是 willShow / willHide 预告事件，才更新动画进度和高度。
    //   will 事件只是告诉你“键盘准备开始弹出/收起”，它的高度可能是目标值，
    //   不适合立刻拿来移动 UI。真正驱动 UI 位移的是后面的 move、didShow、didHide。
    if (!nextState.isWillEvent) {
      progressNotifier.value = nextState.progress;
      heightNotifier.value = nextState.height;
    }

    // 通知所有直接监听 KeyboardInsetsController 的地方：状态变了
    notifyListeners();
  }

  // Dart 侧给原生插件发配置的入口
  static Future<void> configureNative({required bool androidEdgeToEdge}) async {
    try {
      // 通过 MethodChannel 调用原生侧的 configure 方法，把 androidEdgeToEdge 这个配置传给 iOS/Android 原生代码。
      await _methodChannel.invokeMethod<void>('configure', {
        'androidEdgeToEdge': androidEdgeToEdge,
      });
    } on MissingPluginException {
      // The package is intentionally inert on unsupported platforms.
    }
  }

  @override
  void dispose() {
    heightNotifier.dispose();
    progressNotifier.dispose();
    isVisibleNotifier.dispose();
    stateNotifier.dispose();
    super.dispose();
  }
}
