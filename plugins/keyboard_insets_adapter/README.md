# keyboard_insets_adapter

本仓库自用的薄 Flutter plugin，只提供原生键盘遮挡高度、进度和可见状态。

它参考 `flutter_keyboard_controller` 1.0.4 的原生键盘事件采集思路，但不包含
`KeyboardAvoidingView`、`KeyboardAwareScrollView`、`KeyboardChatScrollView`、
`KeyboardToolbar` 或 `KeyboardStickyView` 等高级 Widget。
