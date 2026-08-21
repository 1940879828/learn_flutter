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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 这个 Widget 是应用的首页，并且是有状态的。
  // 这意味着它下面会有一个 State 对象，State 里保存会影响界面显示的数据。

  // 这个类是 State 的配置对象。
  // 它保存父组件传进来的值（这里是 title），并在 State 的 build 方法里使用。
  // Widget 子类里的字段通常都要标记成 `final`。

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 这句 `setState` 会告诉 Flutter：这个 State 里的内容变了。
      // Flutter 随后会重新执行下面的 build 方法，让界面显示最新值。
      // 如果我们直接改 `_counter`，但不调用 `setState()`，build 不会重新执行，
      // 界面上看起来就不会有变化。
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 只要调用了 `setState`，这个方法就会重新执行。
    // 例如上面的 `_incrementCounter` 就会触发它。
    //
    // Flutter 已经把 build 的重建做得很快了，
    // 所以你通常只需要重建需要更新的部分，不用手动逐个修改 Widget 实例。
    return Scaffold(
      appBar: AppBar(
        // 你可以试试：把这里改成一个指定颜色，比如 `Colors.amber`，
        // 然后热重载，看看 AppBar 的颜色会变化，而其它部分保持不变。
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 这里直接使用 `MyHomePage` 里传进来的 title，
        // 也就是上层在创建页面时给这个 AppBar 设置的标题。
        title: Text(widget.title),
      ),
      body: Center(
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
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // 这个尾随逗号能让 build 方法更方便自动格式化。
    );
  }
}
