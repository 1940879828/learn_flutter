import 'package:flutter/material.dart';
import 'package:keyboard_insets_adapter/keyboard_insets_adapter.dart';

import '../learning_navigation_controls.dart';

class ChatKeyboardJankPage extends StatefulWidget {
  const ChatKeyboardJankPage({super.key});

  @override
  State<ChatKeyboardJankPage> createState() => _ChatKeyboardJankPageState();
}

class _ChatKeyboardJankPageState extends State<ChatKeyboardJankPage> {
  // 聊天记录
  static final _messages = _buildMessages();

  // 输入框控制器
  final _controller = TextEditingController(text: '帮我把这张图改成电影感');
  // 焦点状态对像 拿它的 addListener 来监听焦点变化
  final _focusNode = FocusNode();
  // 输入框当前是否聚焦
  bool _inputFocused = false;

  @override
  void initState() {
    super.initState();
    // 配置监听输入框聚焦状态的回调函数
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 聚焦状态变化时执行这个回调函数
  void _handleFocusChanged() {
    if (_inputFocused == _focusNode.hasFocus) return;
    setState(() {
      _inputFocused = _focusNode.hasFocus;
    });
  }

  void _dismissKeyboard() {
    // 收起键盘 / 取消输入焦点 ，通知系统把当前键盘收起来
    KeyboardInsetsScope.maybeOf(context)?.dismiss();
  }

  // “这一段 UI 描述需要重新计算”时触发：
  // 1. Widget 第一次显示
  // 2. 当前 State 调用了 setState()
  // 3. 父组件 rebuild，带动子组件 build
  // 4. MediaQuery / Theme / Localizations 等依赖变化
  // 5. Riverpod / Provider / InheritedWidget 监听的数据变化
  // 6. FutureBuilder / StreamBuilder 收到新结果
  // 7. 动画每一帧驱动局部重建
  // 8. Hot reload
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 关掉 Flutter/Scaffold 默认的键盘避让，不让 body 自动缩小。
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF090A0F),
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('15 聊天键盘上移复刻'),
        actions: [
          IconButton(
            tooltip: '收起输入焦点',
            onPressed: _inputFocused ? _dismissKeyboard : null,
            icon: const Icon(Icons.keyboard_hide_outlined),
          ),
          const LearningHomeAction(),
        ],
      ),
      body: ClipRect(
        child: SafeArea(
          child: Column(
            children: [
              _NativeKeyboardStatusStrip(
                inputFocused: _inputFocused,
                movedMessages: _messages.length,
              ),
              const _ConversationHeader(),
              Expanded(
                child: ClipRect(
                  // 消息列表 + 输入栏整体包起来。键盘弹出时，只用 Transform 改变外层绘制位置，避免大布局每帧跟着变。
                  child: _KeyboardTranslatedPane(
                    // 性能隔离组件 这个子树可以单独重绘，尽量不要每次都连带父级或兄弟节点一起 repaint。
                    child: RepaintBoundary(
                      child: Column(
                        children: [
                          Expanded(
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                color: Color(0xFF11131B),
                              ),
                              child: ListView(
                                reverse: true,
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  16,
                                  14,
                                  18,
                                ),
                                children: [
                                  for (final message in _messages.reversed)
                                    _MessageBubble(message: message),
                                ],
                              ),
                            ),
                          ),
                          _ComposerBar(
                            controller: _controller,
                            focusNode: _focusNode,
                            inputFocused: _inputFocused,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyboardTranslatedPane extends StatelessWidget {
  const _KeyboardTranslatedPane({required this.child});

  final Widget child;

  static final _zeroKeyboardHeight = ValueNotifier<double>(0);

  @override
  Widget build(BuildContext context) {
    // 找不到返回 null
    final keyboard = KeyboardInsetsScope.maybeOf(context);

    // 监听 ValueListenable，值变了就重建自己的 builder 区域。
    return ValueListenableBuilder<double>(
      valueListenable: keyboard?.heightNotifier ?? _zeroKeyboardHeight,
      child: child,
      builder: (context, keyboardHeight, stableChild) {
        final keyboardProgress = keyboard?.progressNotifier.value ?? 0;
        final visualOffset = -keyboardHeight;

        debugPrint(
          '[chapter_15][keyboard] '
          'nativeKeyboardHeight=${keyboardHeight.toStringAsFixed(1)} '
          'nativeKeyboardProgress=${keyboardProgress.toStringAsFixed(3)} '
          'visualOffset=${visualOffset.toStringAsFixed(1)}',
        );

        return Transform.translate(
          offset: Offset(0, visualOffset),
          child: stableChild,
        );
      },
    );
  }
}

List<_DemoMessage> _buildMessages() {
  final messages = <_DemoMessage>[];
  const rounds = [
    (user: '今晚这张图的光影很漂亮，像电影截图。', assistant: '可以，我会保留脸部和姿势，只调整服装与光效。'),
    (user: '我想把角色衣服改成银色盔甲，再加一点魔法纹路。', assistant: '银色盔甲会加冷色边缘光，魔法纹路会控制在衣服和肩甲上。'),
    (user: '背景别太亮，保留一点暗色森林。', assistant: '森林会保持低饱和，角色周围只加很轻的轮廓光。'),
    (user: '再帮我试一个偏日系卡牌的版本。', assistant: '日系卡牌版本会强化线条、眼睛高光和边框装饰。'),
    (user: '这次不要太幼态。', assistant: '明白，会把比例和五官处理得更成熟。'),
    (
      user: '如果输入框弹起来，后面的列表是不是都会动？',
      assistant: '是的，如果 Scaffold 跟随系统键盘 resize，历史消息也会参与布局。',
    ),
    (
      user: '这就会导致很多 cell 在同一帧里重新布局？',
      assistant: '尤其是复杂消息气泡、图片、视频缩略图和 hero 区域，会比较明显。',
    ),
    (user: 'SpellAI 里的聊天页看起来就像这样。', assistant: '这个页面先复刻现象，后面再拆优化方向。'),
    (user: '输入框聚焦以后，系统默认键盘弹起。', assistant: 'Scaffold body 高度变化，列表重新计算可视范围。'),
    (
      user: '如果消息项本身很重，手感就会变卡。',
      assistant: '对，图片、富文本和多层阴影会放大键盘动画期间的 layout/raster 成本。',
    ),
  ];

  for (var i = 0; i < 4; i++) {
    for (final round in rounds) {
      messages.add(_DemoMessage('${round.user} #${i + 1}', true));
      messages.add(_DemoMessage('${round.assistant} #${i + 1}', false));
    }
    if (i == 1) {
      messages.add(
        const _DemoMessage.image(
          'assets/chapter_15/test.jpg',
          fromMe: true,
          caption: '用户发来的参考图：这类图片消息会增加布局和解码压力。',
        ),
      );
    }
    if (i == 2) {
      messages.add(
        const _DemoMessage.image(
          'assets/chapter_15/test2.jpg',
          fromMe: false,
          caption: '生成结果预览：键盘弹起时也会跟着列表重新计算位置。',
        ),
      );
    }
  }

  return messages;
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF171A24),
        border: Border(bottom: BorderSide(color: Color(0xFF252A38))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF65D46E), Color(0xFF64B5F6)],
              ),
            ),
            child: const Icon(Icons.auto_awesome, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SpellAI Assistant',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '静态消息列表',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '更多',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _DemoMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.fromMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = message.fromMe
        ? const Color(0xFF2FB866)
        : const Color(0xFF242938);
    final textColor = message.fromMe ? Colors.black : Colors.white;

    Widget child = Text(
      message.text,
      style: TextStyle(
        height: 1.3,
        color: textColor,
        fontSize: 14,
        fontWeight: message.fromMe ? FontWeight.w600 : FontWeight.w400,
      ),
    );

    if (message.imageAsset != null) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              message.imageAsset!,
              width: 260,
              height: 188,
              fit: BoxFit.cover,
            ),
          ),
          if (message.caption != null) ...[
            const SizedBox(height: 8),
            Text(
              message.caption!,
              style: TextStyle(
                height: 1.3,
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(message.fromMe ? 14 : 3),
                  bottomRight: Radius.circular(message.fromMe ? 3 : 14),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 底部输入栏
class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.focusNode,
    required this.inputFocused,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool inputFocused;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0F15),
        border: Border(top: BorderSide(color: Color(0xFF252A38))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton.filledTonal(
            tooltip: '添加括号',
            onPressed: () {
              controller.text += '()';
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length - 1,
              );
              focusNode.requestFocus();
            },
            icon: const Text(
              '( )',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D27),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: inputFocused
                      ? const Color(0xFF64B5F6)
                      : const Color(0xFF2C3242),
                ),
              ),
              child: TextField(
                controller: controller,
                // 在这里配置了“焦点监听对象”监听这个 TextField，这个 TextField的焦点聚焦状态发生变化之后会触发回调函数
                focusNode: focusNode,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: '输入 prompt',
                  hintStyle: TextStyle(color: Color(0xFF737B8C)),
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: '发送',
            onPressed: () {},
            icon: const Icon(Icons.arrow_upward),
          ),
        ],
      ),
    );
  }
}

// 原生键盘状态条
class _NativeKeyboardStatusStrip extends StatelessWidget {
  const _NativeKeyboardStatusStrip({
    required this.inputFocused,
    required this.movedMessages,
  });

  final bool inputFocused;
  final int movedMessages;

  static final _zeroKeyboardHeight = ValueNotifier<double>(0);
  static final _zeroKeyboardProgress = ValueNotifier<double>(0);
  static final _hiddenKeyboard = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final keyboard = KeyboardInsetsScope.maybeOf(context);

    return ValueListenableBuilder<double>(
      valueListenable: keyboard?.heightNotifier ?? _zeroKeyboardHeight,
      builder: (context, keyboardHeight, _) {
        return ValueListenableBuilder<double>(
          valueListenable: keyboard?.progressNotifier ?? _zeroKeyboardProgress,
          builder: (context, keyboardProgress, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: keyboard?.isVisibleNotifier ?? _hiddenKeyboard,
              builder: (context, keyboardVisible, _) {
                return _StatusStrip(
                  inputFocused: inputFocused,
                  keyboardVisible: keyboardVisible || keyboardHeight > 1,
                  keyboardInset: keyboardHeight,
                  keyboardProgress: keyboardProgress,
                  visualOffset: -keyboardHeight,
                  movedMessages: movedMessages,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.inputFocused,
    required this.keyboardVisible,
    required this.keyboardInset,
    required this.keyboardProgress,
    required this.visualOffset,
    required this.movedMessages,
  });

  final bool inputFocused;
  final bool keyboardVisible;
  final double keyboardInset;
  final double keyboardProgress;
  final double visualOffset;
  final int movedMessages;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusText = keyboardVisible
        ? 'native逐帧整体上移 ${visualOffset.toStringAsFixed(0)}，height=${keyboardInset.toStringAsFixed(0)}，progress=${keyboardProgress.toStringAsFixed(2)}'
        : inputFocused
        ? '输入框已聚焦；等待 native keyboard frame 驱动整块聊天内容上移'
        : '点击输入框，观察 native 逐帧 inset 驱动的整体上移效果';

    return Material(
      color: const Color(0xE6171A24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              keyboardVisible ? Icons.keyboard_outlined : Icons.chat_outlined,
              color: colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoMessage {
  const _DemoMessage(this.text, this.fromMe)
    : imageAsset = null,
      caption = null;

  const _DemoMessage.image(
    this.imageAsset, {
    required this.fromMe,
    required this.caption,
  }) : text = '';

  final String text;
  final bool fromMe;
  final String? imageAsset;
  final String? caption;
}
