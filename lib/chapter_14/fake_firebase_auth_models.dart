import 'dart:async';

enum FakeAuthProvider {
  google('google.com', 'Google'),
  apple('apple.com', 'Apple'),
  facebook('facebook.com', 'Facebook'),
  line('line.me', 'LINE');

  const FakeAuthProvider(this.providerId, this.label);

  final String providerId;
  final String label;
}

enum FakeLoginState {
  idle('未登录'),
  logging('登录中'),
  signedIn('已登录'),
  canceled('用户取消'),
  authFailed('供应商认证失败'),
  backendFailed('后端创建用户失败');

  const FakeLoginState(this.label);

  final String label;
}

class FakeAuthUser {
  const FakeAuthUser({
    required this.uid,
    required this.email,
    required this.provider,
  });

  final String uid;
  final String email;
  final FakeAuthProvider provider;
}

class FakeAuthSnapshot {
  const FakeAuthSnapshot({required this.state, this.user, this.message = ''});

  final FakeLoginState state;
  final FakeAuthUser? user;
  final String message;

  bool get logged => user != null;
}

class FakeFirebaseAuthService {
  final StreamController<FakeAuthSnapshot> _controller =
      StreamController<FakeAuthSnapshot>.broadcast();

  FakeAuthSnapshot _snapshot = const FakeAuthSnapshot(
    state: FakeLoginState.idle,
    message: '等待选择登录方式',
  );
  int _requestSerial = 0;
  bool _disposed = false;

  FakeAuthSnapshot get current => _snapshot;

  Stream<FakeAuthSnapshot> get changes => _controller.stream;

  Future<FakeAuthSnapshot> signIn(
    FakeAuthProvider provider, {
    bool failProvider = false,
    bool failBackend = false,
  }) async {
    if (_snapshot.logged) {
      return _emit(
        FakeAuthSnapshot(
          state: FakeLoginState.signedIn,
          user: _snapshot.user,
          message: '已经登录，真实项目会直接返回 logged',
        ),
      );
    }

    final serial = ++_requestSerial;
    _emit(
      FakeAuthSnapshot(
        state: FakeLoginState.logging,
        message: '正在打开 ${provider.label} 登录',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (_disposed || serial != _requestSerial) return _snapshot;

    if (failProvider) {
      return _emit(
        FakeAuthSnapshot(
          state: FakeLoginState.authFailed,
          message: '${provider.label} credential 获取失败',
        ),
      );
    }

    _emit(
      FakeAuthSnapshot(
        state: FakeLoginState.logging,
        message: '已拿到 Firebase credential，正在创建后端用户',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (_disposed || serial != _requestSerial) return _snapshot;

    if (failBackend) {
      return _emit(
        const FakeAuthSnapshot(
          state: FakeLoginState.backendFailed,
          message: '后端 create current user 失败，需要退出 Firebase 用户',
        ),
      );
    }

    final user = FakeAuthUser(
      uid: '${provider.name}_demo_uid',
      email: '${provider.name}@example.test',
      provider: provider,
    );
    return _emit(
      FakeAuthSnapshot(
        state: FakeLoginState.signedIn,
        user: user,
        message: '登录成功，auth state 已广播',
      ),
    );
  }

  void cancel() {
    _requestSerial++;
    _emit(
      const FakeAuthSnapshot(
        state: FakeLoginState.canceled,
        message: '用户关闭供应商登录页',
      ),
    );
  }

  void signOut() {
    _requestSerial++;
    _emit(const FakeAuthSnapshot(state: FakeLoginState.idle, message: '已退出登录'));
  }

  FakeAuthSnapshot _emit(FakeAuthSnapshot snapshot) {
    _snapshot = snapshot;
    if (!_disposed) {
      _controller.add(snapshot);
    }
    return snapshot;
  }

  void dispose() {
    _disposed = true;
    _requestSerial++;
    _controller.close();
  }
}
