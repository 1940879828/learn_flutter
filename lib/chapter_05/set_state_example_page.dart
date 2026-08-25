import 'package:flutter/material.dart';

class SetStateExamplePage extends StatefulWidget {
  const SetStateExamplePage({super.key});

  @override
  State<SetStateExamplePage> createState() => _SetStateExamplePageState();
}

class _SetStateExamplePageState extends State<SetStateExamplePage> {
  int _count = 0;
  bool _highlight = false;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  void _toggleHighlight() {
    setState(() {
      _highlight = !_highlight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _highlight
        ? const Color(0xFFE8F5E9)
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(title: const Text('01 StatefulWidget + setState')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('本地点击次数：$_count'),
                    const SizedBox(height: 12),
                    Text('高亮状态：${_highlight ? '开启' : '关闭'}'),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilledButton(
                          onPressed: _increment,
                          child: const Text('setState 加一'),
                        ),
                        OutlinedButton(
                          onPressed: _toggleHighlight,
                          child: const Text('切换高亮'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
