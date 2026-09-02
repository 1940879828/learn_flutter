enum KeyboardInsetsEventType { willShow, didShow, willHide, didHide, move }

class KeyboardInsetsState {
  const KeyboardInsetsState({
    required this.height,
    required this.progress,
    required this.isVisible,
    required this.eventType,
    required this.duration,
    required this.timestamp,
  });

  const KeyboardInsetsState.hidden()
    : height = 0,
      progress = 0,
      isVisible = false,
      eventType = KeyboardInsetsEventType.didHide,
      duration = 0,
      timestamp = 0;

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

KeyboardInsetsEventType _eventTypeFromNative(String? type) {
  return switch (type) {
    'keyboardWillShow' => KeyboardInsetsEventType.willShow,
    'keyboardDidShow' => KeyboardInsetsEventType.didShow,
    'keyboardWillHide' => KeyboardInsetsEventType.willHide,
    'keyboardDidHide' => KeyboardInsetsEventType.didHide,
    _ => KeyboardInsetsEventType.move,
  };
}
