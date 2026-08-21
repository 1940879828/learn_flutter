import 'package:flutter/material.dart';

class LifecycleDemoPage extends StatelessWidget {
  const LifecycleDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('03 Widget 生命周期')),
      body: const LifecycleHost(),
    );
  }
}

class LifecycleHost extends StatefulWidget {
  const LifecycleHost({super.key});

  @override
  State<LifecycleHost> createState() => _LifecycleHostState();
}

class _LifecycleHostState extends State<LifecycleHost> {
  bool _useChineseLabel = false;
  bool _showCounter = true;

  String get _counterLabel {
    if (_useChineseLabel) {
      return '你已经点击按钮这么多次：';
    }
    return 'You have pushed the button this many times:';
  }

  void _toggleLabel() {
    setState(() {
      _useChineseLabel = !_useChineseLabel;
    });
  }

  void _toggleCounter() {
    setState(() {
      _showCounter = !_showCounter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_showCounter) CounterSection(label: _counterLabel),
          const SizedBox(height: 16),
          TextButton(onPressed: _toggleLabel, child: const Text('切换外部文案')),
          TextButton(
            onPressed: _toggleCounter,
            child: Text(_showCounter ? '移除计数器' : '恢复计数器'),
          ),
        ],
      ),
    );
  }
}

class CounterSection extends StatefulWidget {
  const CounterSection({super.key, required this.label});

  final String label;

  @override
  State<CounterSection> createState() => _CounterSectionState();
}

class _CounterSectionState extends State<CounterSection> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('CounterSection initState：首次创建状态对象');
  }

  @override
  void didUpdateWidget(covariant CounterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
      'CounterSection didUpdateWidget：外部配置变化，'
      'oldLabel=${oldWidget.label}, newLabel=${widget.label}',
    );
  }

  @override
  void dispose() {
    debugPrint('CounterSection dispose：状态对象被销毁，释放资源');
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // 这句 `setState` 只会让 CounterSection 这块局部区域重新 build。
      // 首页壳不保存 `_counter`，所以它不需要跟着计数变化重建。
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(widget.label),
        Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
