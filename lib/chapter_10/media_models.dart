enum MediaSourceKind {
  asset('asset', '随 App 打包，适合图标、默认封面、内置教学资源'),
  network('network', '来自 URL，依赖网络、缓存和失败重试'),
  file('file', '来自本机沙箱或相册选择结果，依赖文件生命周期');

  const MediaSourceKind(this.label, this.description);

  final String label;
  final String description;
}

enum FakeVideoStatus {
  idle('未初始化'),
  initializing('初始化中'),
  ready('已就绪'),
  playing('播放中'),
  paused('已暂停'),
  disposed('已释放');

  const FakeVideoStatus(this.label);

  final String label;
}

class FakeVideoController {
  FakeVideoController();

  FakeVideoStatus status = FakeVideoStatus.idle;
  final List<String> lifecycleLogs = <String>['controller created'];

  Future<void> initialize() async {
    if (status == FakeVideoStatus.disposed) return;
    status = FakeVideoStatus.initializing;
    lifecycleLogs.add('initialize() start');
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (status == FakeVideoStatus.disposed) return;
    status = FakeVideoStatus.ready;
    lifecycleLogs.add('initialize() complete');
  }

  void play() {
    if (status == FakeVideoStatus.disposed) return;
    if (status != FakeVideoStatus.ready &&
        status != FakeVideoStatus.paused &&
        status != FakeVideoStatus.playing) {
      lifecycleLogs.add('play() ignored: not ready');
      return;
    }
    status = FakeVideoStatus.playing;
    lifecycleLogs.add('play()');
  }

  void pause() {
    if (status == FakeVideoStatus.disposed) return;
    if (status != FakeVideoStatus.playing) {
      lifecycleLogs.add('pause() ignored: not playing');
      return;
    }
    status = FakeVideoStatus.paused;
    lifecycleLogs.add('pause()');
  }

  void dispose() {
    if (status == FakeVideoStatus.disposed) return;
    status = FakeVideoStatus.disposed;
    lifecycleLogs.add('dispose()');
  }
}
