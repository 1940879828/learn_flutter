import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'keyboard_insets_state.dart';

class KeyboardInsetsController extends ChangeNotifier {
  KeyboardInsetsController();

  static const MethodChannel _methodChannel = MethodChannel(
    'keyboard_insets_adapter',
  );

  final ValueNotifier<double> heightNotifier = ValueNotifier(0);
  final ValueNotifier<double> progressNotifier = ValueNotifier(0);
  final ValueNotifier<bool> isVisibleNotifier = ValueNotifier(false);
  final ValueNotifier<KeyboardInsetsState> stateNotifier = ValueNotifier(
    const KeyboardInsetsState.hidden(),
  );

  double get height => heightNotifier.value;
  double get progress => progressNotifier.value;
  bool get isVisible => isVisibleNotifier.value;
  KeyboardInsetsState get state => stateNotifier.value;

  Future<void> dismiss({bool keepFocus = false}) async {
    try {
      await _methodChannel.invokeMethod<void>('dismiss', {
        'keepFocus': keepFocus,
      });
    } on MissingPluginException {
      // Desktop/widget-test fallback: remove Flutter focus even without native.
      if (!keepFocus) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    }
  }

  void handleNativeEvent(KeyboardInsetsState nextState) {
    stateNotifier.value = nextState;
    isVisibleNotifier.value = nextState.isVisible;

    if (!nextState.isWillEvent) {
      progressNotifier.value = nextState.progress;
      heightNotifier.value = nextState.height;
    }

    notifyListeners();
  }

  static Future<void> configureNative({required bool androidEdgeToEdge}) async {
    try {
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
