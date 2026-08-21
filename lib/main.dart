import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 这个 Widget 是整个应用的根节点。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 这是你整个应用使用的主题。
        //
        // 你可以试试：先运行 `flutter run`，你会看到应用顶部有一条紫色工具栏。
        // 然后不要退出应用，把下面 `colorScheme` 里的 `seedColor` 改成
        // `Colors.green`，再执行一次热重载。
        // 你可以在支持 Flutter 的 IDE 里点热重载按钮，或者在命令行里按 `r`。
        //
        // 这时你会发现计数器没有回到 0，因为热重载不会丢失应用状态。
        // 如果你想把状态也重置掉，需要使用热重启（hot restart）。
        //
        // 这不仅适用于数值，也适用于代码本身：大多数代码改动都可以通过热重载快速验证。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  // 这个 Widget 是应用的首页壳，它自己不保存会变化的状态。
  // 计数器状态被拆到下面的 CounterSection 里局部管理。

  // 父组件传进来的标题由首页壳使用。
  // Widget 子类里的字段通常都要标记成 `final`。

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 你可以试试：把这里改成一个指定颜色，比如 `Colors.amber`，
        // 然后热重载，看看 AppBar 的颜色会变化，而其它部分保持不变。
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 这里直接使用 `MyHomePage` 构造函数里传进来的 title，
        // 也就是上层在创建页面时给这个 AppBar 设置的标题。
        title: Text(title),
      ),
      body: const CounterSection(),
    );
  }
}

class CounterSection extends StatefulWidget {
  const CounterSection({super.key});

  @override
  State<CounterSection> createState() => _CounterSectionState();
}

class _CounterSectionState extends State<CounterSection> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 这句 `setState` 只会让 CounterSection 这块局部区域重新 build。
      // 首页壳 MyHomePage 不保存 `_counter`，所以它不需要跟着计数变化重建。
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // `Center` 是一个布局 Widget，它只接收一个子组件，
      // 并把这个子组件放在父组件的正中间。
      child: Column(
        // `Column` 也是一个布局 Widget，它接收多个子组件，并把它们竖直排列。
        // 默认情况下，它会在水平方向上包住自己的子组件，
        // 在垂直方向上尽量撑满父组件。
        //
        // `Column` 有很多属性可以控制尺寸和排列方式。
        // 这里我们用 `mainAxisAlignment` 把子组件在垂直方向居中。
        // 因为 `Column` 的主轴是竖直方向，交叉轴才是水平方向。
        //
        // 你可以试试：在 IDE 里打开 debug painting，
        // 或者在控制台里按 `p`，看看每个 Widget 的边框线。
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),
          Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ), // 这个尾随逗号能让 build 方法更方便自动格式化。
    );
  }
}
