// 当前状态快照
enum KeyboardInsetsEventType { willShow, didShow, willHide, didHide, move }

// 原生传来的一帧键盘状态
class KeyboardInsetsState {
  const KeyboardInsetsState({
    // 键盘当前遮住页面底部的高度。
    required this.height,
    // 键盘动画进度，范围0 ~ 1
    required this.progress,
    // 键盘是否可见
    required this.isVisible,
    // 这次原生事件的类型。
    // willShow = 键盘准备弹出
    // move     = 键盘动画中，每一帧高度变化
    // didShow  = 键盘已经弹出完成
    // willHide = 键盘准备收起
    // didHide  = 键盘已经收起完成
    required this.eventType,
    // 系统告诉我们的键盘动画时长
    required this.duration,
    // 这次事件发生的时间戳。
    required this.timestamp,
  });

  // 返回 键盘隐藏情况的状态
  const KeyboardInsetsState.hidden()
    : height = 0,
      progress = 0,
      isVisible = false,
      eventType = KeyboardInsetsEventType.didHide,
      duration = 0,
      timestamp = 0;

  // 清洗原生数据 确定返回值类型
  factory KeyboardInsetsState.fromMap(Map<dynamic, dynamic> map) {
    final height = (map['height'] as num?)?.toDouble() ?? 0;
    final eventType = _eventTypeFromNative(map['type'] as String?);

    return KeyboardInsetsState(
      height: height,
      progress: ((map['progress'] as num?)?.toDouble() ?? 0).clamp(0, 1),
      isVisible: map['isVisible'] as bool? ?? height > 0,
      eventType: eventType,
      duration: (map['duration'] as num?)?.toDouble() ?? 0,
      timestamp:
          (map['timestamp'] as num?)?.toDouble() ??
          DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
  }

  final double height;
  final double progress;
  final bool isVisible;
  final KeyboardInsetsEventType eventType;
  final double duration;
  final double timestamp;

  // 当前这条原生事件 是否在动画的准备阶段
  bool get isWillEvent =>
      eventType == KeyboardInsetsEventType.willShow ||
      eventType == KeyboardInsetsEventType.willHide;

  @override
  String toString() {
    return 'KeyboardInsetsState('
        'height: $height, '
        'progress: $progress, '
        'isVisible: $isVisible, '
        'eventType: $eventType, '
        'duration: $duration'
        ')';
  }
}

// 原生事件类型字符串映射到 dart enum类型
KeyboardInsetsEventType _eventTypeFromNative(String? type) {
  return switch (type) {
    'keyboardWillShow' => KeyboardInsetsEventType.willShow,
    'keyboardDidShow' => KeyboardInsetsEventType.didShow,
    'keyboardWillHide' => KeyboardInsetsEventType.willHide,
    'keyboardDidHide' => KeyboardInsetsEventType.didHide,
    _ => KeyboardInsetsEventType.move,
  };
}
