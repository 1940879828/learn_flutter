import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'spellai_auth_config.dart';
import 'spellai_auth_models.dart';

class SpellAiAuthService {
  SpellAiAuthService({required this.config})
    : _dio = Dio(
        BaseOptions(
          baseUrl: config.baseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

  final SpellAiAuthConfig config;
  final Dio _dio;
  final StreamController<SpellAiAuthSnapshot> _controller =
      StreamController<SpellAiAuthSnapshot>.broadcast();

  SpellAiAuthSnapshot _snapshot = const SpellAiAuthSnapshot(
    phase: SpellAiAuthPhase.anonymous,
    message: '等待登录',
  );
  bool _initializing = false;
  bool _logging = false;
  bool _disposed = false;
  bool _lineSetup = false;

  Stream<SpellAiAuthSnapshot> get changes => _controller.stream;

  SpellAiAuthSnapshot get current => _snapshot;

  Future<void> restoreCurrentUser() async {
    if (!_ensureConfig()) return;
    await _initializeFirebase();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _emit(
        const SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.anonymous,
          message: 'Firebase 当前没有登录用户',
        ),
      );
      return;
    }

    await _syncSignedInUser(user, null);
  }

  Future<void> signIn(SpellAiLoginProvider provider) async {
    if (!_ensureConfig()) return;
    if (_logging) {
      _emit(
        SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.authenticating,
          provider: provider,
          message: '已有登录请求进行中',
        ),
      );
      return;
    }

    _logging = true;
    try {
      await _initializeFirebase();
      _emit(
        SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.authenticating,
          provider: provider,
          message: '正在打开 ${provider.label} 登录',
        ),
      );

      final credential = await switch (provider) {
        SpellAiLoginProvider.google => _signInWithGoogle(),
        SpellAiLoginProvider.apple => _signInWithApple(),
        SpellAiLoginProvider.facebook => _signInWithFacebook(),
        SpellAiLoginProvider.line => _signInWithLine(),
      };

      final user = credential.user;
      if (user == null) {
        _emit(
          SpellAiAuthSnapshot(
            phase: SpellAiAuthPhase.error,
            provider: provider,
            message: 'Firebase 没有返回用户',
            error: 'UserCredential.user is null',
          ),
        );
        return;
      }

      await _syncSignedInUser(user, provider);
    } on _LoginCanceledException catch (error) {
      _emit(
        SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.canceled,
          provider: provider,
          message: error.message,
        ),
      );
    } catch (error) {
      _emit(
        SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.error,
          provider: provider,
          message: '${provider.label} 登录失败',
          error: _readableError(error),
        ),
      );
    } finally {
      _logging = false;
    }
  }

  Future<void> signOut() async {
    if (!_ensureConfig()) return;
    try {
      await _initializeFirebase();
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut().catchError((_) => null);
      await FacebookAuth.instance.logOut().catchError((_) => null);
      _emit(
        const SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.anonymous,
          message: '已退出 Firebase 和本地 provider 状态',
        ),
      );
    } catch (error) {
      _emit(
        SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.error,
          message: '退出登录失败',
          error: _readableError(error),
        ),
      );
    }
  }

  Future<void> _initializeFirebase() async {
    if (_initializing) return;
    if (Firebase.apps.isNotEmpty) return;

    _initializing = true;
    _emit(
      const SpellAiAuthSnapshot(
        phase: SpellAiAuthPhase.initializing,
        message: '正在用 SpellAI Firebase options 初始化',
      ),
    );
    try {
      await Firebase.initializeApp(options: config.firebaseOptions);
    } finally {
      _initializing = false;
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      return FirebaseAuth.instance.signInWithPopup(provider);
    }

    final googleUser = await GoogleSignIn(
      clientId: config.iosClientId.isEmpty ? null : config.iosClientId,
      serverClientId: config.androidClientId.isEmpty
          ? null
          : config.androidClientId,
    ).signIn();
    if (googleUser == null) {
      throw const _LoginCanceledException('用户关闭了 Google 登录');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> _signInWithApple() {
    final provider = AppleAuthProvider();
    return kIsWeb
        ? FirebaseAuth.instance.signInWithPopup(provider)
        : FirebaseAuth.instance.signInWithProvider(provider);
  }

  Future<UserCredential> _signInWithFacebook() async {
    if (kIsWeb) {
      return FirebaseAuth.instance.signInWithPopup(FacebookAuthProvider());
    }

    final rawNonce = _generateNonce();
    final nonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final result = await FacebookAuth.instance.login(
      loginTracking: LoginTracking.enabled,
      nonce: nonce,
    );
    if (result.status == LoginStatus.cancelled) {
      throw const _LoginCanceledException('用户关闭了 Facebook 登录');
    }
    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw StateError(result.message ?? 'Facebook credential 获取失败');
    }

    final token = result.accessToken!;
    final credential = token.type != AccessTokenType.limited
        ? FacebookAuthProvider.credential(token.tokenString)
        : OAuthProvider(
            'facebook.com',
          ).credential(idToken: token.tokenString, rawNonce: rawNonce);
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> _signInWithLine() async {
    if (!config.canUseLine) {
      throw StateError('缺少 SPELLAI_LINE_CHANNEL_ID，不能启动 LINE SDK');
    }
    if (!_lineSetup) {
      await LineSDK.instance.setup(config.lineChannelId);
      _lineSetup = true;
    }

    try {
      final result = await LineSDK.instance.login(
        scopes: ['profile', 'openid', 'email'],
      );
      final lineIdToken = result.accessToken.idTokenRaw;
      final lineUserId = result.userProfile?.userId;
      if (lineIdToken == null || lineUserId == null) {
        throw StateError('LINE 没有返回 idToken 或 userId');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/users/line/verify',
        data: {'line_token': lineIdToken},
        options: _baseOptions(),
      );
      final data = response.data ?? const {};
      final uid = data['uid'] as String?;
      final customToken = data['custom_token'] as String?;
      if (uid == null || customToken == null || !uid.contains(lineUserId)) {
        throw StateError('LINE 后端校验返回不完整');
      }

      return FirebaseAuth.instance.signInWithCustomToken(customToken);
    } on PlatformException catch (error) {
      if (error.code == 'CANCEL') {
        throw const _LoginCanceledException('用户关闭了 LINE 登录');
      }
      rethrow;
    }
  }

  Future<void> _syncSignedInUser(
    User user,
    SpellAiLoginProvider? provider,
  ) async {
    final idToken = await _getIdToken(user, forceRefresh: false);
    final token = SpellAiTokenSnapshot.fromIdToken(
      uid: user.uid,
      idToken: idToken,
    );
    final firebaseUser = _snapshotUser(user);
    _emit(
      SpellAiAuthSnapshot(
        phase: SpellAiAuthPhase.firebaseSignedIn,
        provider: provider,
        firebaseUser: firebaseUser,
        token: token,
        message: 'Firebase 已登录，正在同步 SpellAI 用户',
      ),
    );

    _emit(
      SpellAiAuthSnapshot(
        phase: SpellAiAuthPhase.syncingBackend,
        provider: provider,
        firebaseUser: firebaseUser,
        token: token,
        message: 'POST /users 后 GET /users/${user.uid}',
      ),
    );

    try {
      final userInfo = await _syncBackendProfile(user);
      final freshToken = await _getIdToken(user, forceRefresh: false);
      _emit(
        SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.authenticated,
          provider: provider,
          firebaseUser: _snapshotUser(user),
          token: SpellAiTokenSnapshot.fromIdToken(
            uid: user.uid,
            idToken: freshToken,
          ),
          userInfo: userInfo,
          message: 'SpellAI 业务用户同步完成',
        ),
      );
    } catch (error) {
      await FirebaseAuth.instance.signOut().catchError((_) => null);
      _emit(
        SpellAiAuthSnapshot(
          phase: SpellAiAuthPhase.error,
          provider: provider,
          firebaseUser: firebaseUser,
          token: token,
          message: 'SpellAI 后端同步失败，已退出 Firebase 用户以避免状态不一致',
          error: _readableError(error),
        ),
      );
    }
  }

  Future<SpellAiUserInfo> _syncBackendProfile(User user) async {
    await _withTokenRetry(
      user,
      (idToken) => _dio.post(
        '/users',
        options: _authOptions(uid: user.uid, idToken: idToken),
      ),
    );

    final response = await _withTokenRetry(
      user,
      (idToken) => _dio.get<Map<String, dynamic>>(
        '/users/${user.uid}',
        options: _authOptions(uid: user.uid, idToken: idToken),
      ),
    );
    final data = response.data;
    if (data == null) throw StateError('GET /users/${user.uid} 返回空数据');
    return SpellAiUserInfo.fromJson(data);
  }

  Future<Response<T>> _withTokenRetry<T>(
    User user,
    Future<Response<T>> Function(String idToken) request,
  ) async {
    var response = await request(await _getIdToken(user, forceRefresh: false));
    if (!_isAuthFailure(response.statusCode)) return response;

    response = await request(await _getIdToken(user, forceRefresh: true));
    if (_isAuthFailure(response.statusCode)) {
      throw StateError('SpellAI 后端仍返回 ${response.statusCode}，登录态不可恢复');
    }
    return response;
  }

  Future<String> _getIdToken(User user, {required bool forceRefresh}) async {
    final token = await user.getIdToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw StateError('Firebase 没有返回 ID token');
    }
    return token;
  }

  Options _authOptions({required String uid, required String idToken}) {
    return _baseOptions(extraHeaders: {'UID': uid, 'Id-Token': idToken});
  }

  Options _baseOptions({Map<String, Object?> extraHeaders = const {}}) {
    return Options(
      headers: {
        'Device-ID': config.deviceId,
        'Accept-Language': 'en-US',
        'User-Agent':
            'learn_flutter_auth_lab/1.0 (${defaultTargetPlatform.name})',
        'App-Version': '1.0.0+1',
        'Package-Name': 'learn_flutter',
        'Store': 'learning',
        ...extraHeaders,
      },
    );
  }

  bool _ensureConfig() {
    if (config.hasFirebaseOptions) return true;
    _emit(
      SpellAiAuthSnapshot(
        phase: SpellAiAuthPhase.missingConfig,
        message: '缺少运行时 Firebase 配置，请用 --dart-define 传入 SpellAI 配置',
        error: config.missingDartDefines.join(', '),
      ),
    );
    return false;
  }

  bool _isAuthFailure(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  SpellAiFirebaseUserSnapshot _snapshotUser(User user) {
    return SpellAiFirebaseUserSnapshot(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
      providerIds: user.providerData.map((info) => info.providerId).toList(),
    );
  }

  SpellAiAuthSnapshot _emit(SpellAiAuthSnapshot snapshot) {
    _snapshot = snapshot;
    if (!_disposed) _controller.add(snapshot);
    return snapshot;
  }

  String _generateNonce() {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List.generate(
      32,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _readableError(Object error) {
    if (error is FirebaseAuthException) {
      return '${error.code}: ${error.message ?? error.toString()}';
    }
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      return 'HTTP ${status ?? '-'}: ${data ?? error.message}';
    }
    if (error is PlatformException) {
      return '${error.code}: ${error.message ?? error.toString()}';
    }
    return error.toString();
  }

  void dispose() {
    _disposed = true;
    _controller.close();
  }
}

class _LoginCanceledException implements Exception {
  const _LoginCanceledException(this.message);

  final String message;
}
