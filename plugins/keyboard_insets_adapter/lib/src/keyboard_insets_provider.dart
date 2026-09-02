import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'keyboard_insets_controller.dart';
import 'keyboard_insets_state.dart';

class KeyboardInsetsProvider extends StatefulWidget {
  const KeyboardInsetsProvider({
    super.key,
    required this.child,
    this.enabled = true,
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
      _startListening();
    }
  }

  @override
  void didUpdateWidget(KeyboardInsetsProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startListening();
      } else {
        _stopListening();
      }
    }

    if (widget.enabled &&
        widget.androidEdgeToEdge != oldWidget.androidEdgeToEdge) {
      _configureNative();
    }
  }

  void _startListening() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen((
      dynamic raw,
    ) {
      if (raw is Map) {
        _controller.handleNativeEvent(KeyboardInsetsState.fromMap(raw));
      }
    }, onError: (_) {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled) {
        _configureNative();
      }
    });
  }

  Future<void> _configureNative() {
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

class KeyboardInsetsScope extends InheritedNotifier<KeyboardInsetsController> {
  const KeyboardInsetsScope({
    super.key,
    required KeyboardInsetsController controller,
    required super.child,
  }) : super(notifier: controller);

  static KeyboardInsetsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<KeyboardInsetsScope>();
    assert(
      scope != null,
      'No KeyboardInsetsProvider found in the widget tree.',
    );
    return scope!.notifier!;
  }

  static KeyboardInsetsController? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<KeyboardInsetsScope>()
        ?.notifier;
  }

  @override
  bool updateShouldNotify(KeyboardInsetsScope oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
