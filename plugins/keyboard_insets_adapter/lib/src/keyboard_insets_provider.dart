// 把 controller 放进 Widget 树的上下文里，让下面的子组件不用手动层层传参，就能拿到 controller 或监听它暴露出来的状态。
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'keyboard_insets_controller.dart';
import 'keyboard_insets_state.dart';

// 键盘状态服务的外壳组件
class KeyboardInsetsProvider extends StatefulWidget {

  const KeyboardInsetsProvider({
    super.key,
    // 需要子组件参数
    required this.child,
    // 控制“这个键盘监听器现在要不要工作”
    this.enabled = true,
    // android是否开启EdgeToEdge模式 不启用时 Android 系统默认帮 App 预留安全区
    this.androidEdgeToEdge = false,
  });

  final Widget child;
  final bool enabled;

  /// Opt-in only. The adapter never globally calls
  /// WindowCompat.setDecorFitsSystemWindows(window, false) by default.
  final bool androidEdgeToEdge;

  @override
  State<KeyboardInsetsProvider> createState() => _KeyboardInsetsProviderState();
}

class _KeyboardInsetsProviderState extends State<KeyboardInsetsProvider> {
  // 订阅入口 连接到原生端也叫 keyboard_insets_adapter/events 的那条事件通道
  static const EventChannel _eventChannel = EventChannel(
    'keyboard_insets_adapter/events',
  );

  late final KeyboardInsetsController _controller;
  StreamSubscription<dynamic>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _controller = KeyboardInsetsController();

    if (widget.enabled) {
      // 开始监听键盘状态
      _startListening();
    }
  }

  // 当父组件重新传给 KeyboardInsetsProvider 的参数变了时，决定要不要重新开监听、停监听，或者重新配置 native。
  @override
  void didUpdateWidget(KeyboardInsetsProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 监听状态切换
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startListening();
      } else {
        _stopListening();
      }
    }

    // androidEdgeToEdge 状态切换
    if (widget.enabled &&
        widget.androidEdgeToEdge != oldWidget.androidEdgeToEdge) {
      _configureNative();
    }
  }

  // 开始从原生侧接收键盘事件，并把事件转成 Dart 的键盘状态，再交给 controller 更新给 UI 用。
  void _startListening() {
    // 之前已经有一个事件订阅，就先取消掉。
    _eventSubscription?.cancel();

    // 从原生 EventChannel 开始接收广播流
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen((
      // 原生传过来的原始数据叫 raw
      dynamic raw,
    ) {
      // 判断原生传来的数据是不是 Map
      if (raw is Map) {
        // 把原生 Map 转成 Dart 侧的结构化状态
        _controller.handleNativeEvent(KeyboardInsetsState.fromMap(raw));
      }
      // 如果 EventChannel 出错，这里先吞掉错误，不让 Flutter 页面直接崩掉。
    }, onError: (_) {});

    // 注册一个“当前这一帧 Flutter 画完之后再执行”的回调。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 这个 State 还在 Widget 树上，没有被 dispose
      // 监听功能现在仍然启用
      if (mounted && widget.enabled) {
        _configureNative();
      }
    });
  }

  Future<void> _configureNative() {
    // 告诉原生侧当前是否启用 Android edge-to-edge
    return KeyboardInsetsController.configureNative(
      androidEdgeToEdge: widget.androidEdgeToEdge,
    );
  }

  void _stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardInsetsScope(controller: _controller, child: widget.child);
  }
}

//InheritedNotifier：把一个 notifier 放到上层，
// 子组件可以通过 context.dependOnInheritedWidgetOfExactType 订阅它。
// 当这个 notifier.notifyListeners() 时，依赖它的子组件会 rebuild。

// 传递 “键盘状态控制器对象” 给子组件
class KeyboardInsetsScope extends InheritedNotifier<KeyboardInsetsController> {
  const KeyboardInsetsScope({
    super.key,
    required KeyboardInsetsController controller,
    required super.child,
    // 把传进来的 controller 交给父类 InheritedNotifier 的 notifier 字段。
  }) : super(notifier: controller);

  // 定义一个静态方法 它返回的一定是 KeyboardInsetsController，不允许为空
  static KeyboardInsetsController of(BuildContext context) {
    // 从当前 context 往父级找最近的 KeyboardInsetsScope
    final scope = context
        .dependOnInheritedWidgetOfExactType<KeyboardInsetsScope>();

    // 开发模式下检查：如果上面没找到 Scope，就报一个更好懂的错误。
    assert(
      scope != null,
      'No KeyboardInsetsProvider found in the widget tree.',
    );
    return scope!.notifier!;
  }

  // 从 context 找 controller，但返回值可以为空
  static KeyboardInsetsController? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<KeyboardInsetsScope>()
        ?.notifier;
  }

  // 更新时是否应该通知
  // 当我这个 Scope 自己更新了，要不要通知下面用过我的 Widget？
  @override
  bool updateShouldNotify(KeyboardInsetsScope oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
