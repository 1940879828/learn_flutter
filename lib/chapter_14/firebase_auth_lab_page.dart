import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../learning_navigation_controls.dart';
import 'fake_firebase_auth_models.dart';
import 'spellai_auth_config.dart';
import 'spellai_auth_models.dart';
import 'spellai_auth_service.dart';

class FirebaseAuthLabPage extends StatefulWidget {
  const FirebaseAuthLabPage({super.key});

  @override
  State<FirebaseAuthLabPage> createState() => _FirebaseAuthLabPageState();
}

class _FirebaseAuthLabPageState extends State<FirebaseAuthLabPage> {
  late final FakeFirebaseAuthService _authService;
  StreamSubscription<FakeAuthSnapshot>? _subscription;
  FakeAuthSnapshot _snapshot = const FakeAuthSnapshot(
    state: FakeLoginState.idle,
    message: '等待选择登录方式',
  );
  bool _failProvider = false;
  bool _failBackend = false;

  @override
  void initState() {
    super.initState();
    _authService = FakeFirebaseAuthService();
    _subscription = _authService.changes.listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _login(FakeAuthProvider provider) async {
    final snapshot = await _authService.signIn(
      provider,
      failProvider: _failProvider,
      failBackend: _failBackend,
    );
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
    });
  }

  void _cancel() {
    setState(() {
      _authService.cancel();
      _snapshot = _authService.current;
    });
  }

  void _signOut() {
    setState(() {
      _authService.signOut();
      _snapshot = _authService.current;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogging = _snapshot.state == FakeLoginState.logging;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const LearningBackOrHomeButton(),
          title: const Text('14 Firebase 登录与账号状态'),
          actions: const [LearningHomeAction()],
          bottom: const TabBar(
            tabs: [
              Tab(text: '状态模拟'),
              Tab(text: '真实 SpellAI'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Firebase 登录链路模拟',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '先用 fake service 观察状态机，再切到真实 SpellAI 页签跑 Firebase + 后端同步。',
                  ),
                  const SizedBox(height: 16),
                  _AuthStateCard(snapshot: _snapshot),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _failProvider,
                    onChanged: isLogging
                        ? null
                        : (value) {
                            setState(() {
                              _failProvider = value;
                              if (value) _failBackend = false;
                            });
                          },
                    title: const Text('模拟供应商认证失败'),
                  ),
                  SwitchListTile(
                    value: _failBackend,
                    onChanged: isLogging
                        ? null
                        : (value) {
                            setState(() {
                              _failBackend = value;
                              if (value) _failProvider = false;
                            });
                          },
                    title: const Text('模拟后端创建用户失败'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...FakeAuthProvider.values.map((provider) {
                        return FilledButton(
                          onPressed: isLogging ? null : () => _login(provider),
                          child: Text(provider.label),
                        );
                      }),
                      OutlinedButton(
                        onPressed: isLogging ? _cancel : null,
                        child: const Text('取消登录'),
                      ),
                      OutlinedButton(
                        onPressed: _snapshot.logged ? _signOut : null,
                        child: const Text('退出登录'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _SpellAiAuthMappingCard(),
                ],
              ),
              const _RealSpellAiAuthTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RealSpellAiAuthTab extends StatefulWidget {
  const _RealSpellAiAuthTab();

  @override
  State<_RealSpellAiAuthTab> createState() => _RealSpellAiAuthTabState();
}

class _RealSpellAiAuthTabState extends State<_RealSpellAiAuthTab> {
  late final SpellAiAuthConfig _config;
  late final SpellAiAuthService _service;
  StreamSubscription<SpellAiAuthSnapshot>? _subscription;
  SpellAiAuthSnapshot _snapshot = const SpellAiAuthSnapshot(
    phase: SpellAiAuthPhase.anonymous,
    message: '等待登录',
  );

  @override
  void initState() {
    super.initState();
    _config = SpellAiAuthConfig.fromEnvironment();
    _service = SpellAiAuthService(config: _config);
    _subscription = _service.changes.listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '真实 SpellAI 登录链路',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          '用 SpellAI Firebase 项目登录，拿 Firebase ID token，同步 SpellAI 后端用户，再展示完整用户 JSON。配置和 token 只在运行时出现，不写进源码。',
        ),
        const SizedBox(height: 16),
        _RealConfigCard(config: _config),
        const SizedBox(height: 12),
        _RealAuthStateCard(snapshot: _snapshot),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _snapshot.isBusy ? null : _service.restoreCurrentUser,
              child: const Text('恢复当前用户'),
            ),
            for (final provider in SpellAiLoginProvider.values)
              FilledButton.tonal(
                onPressed: _snapshot.isBusy
                    ? null
                    : () => _service.signIn(provider),
                child: Text(provider.label),
              ),
            OutlinedButton(
              onPressed: _snapshot.isBusy ? null : _service.signOut,
              child: const Text('退出登录'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_snapshot.firebaseUser != null)
          _JsonCard(
            title: 'Firebase 用户',
            data: _snapshot.firebaseUser!.toJson(),
          ),
        if (_snapshot.token != null) ...[
          const SizedBox(height: 12),
          _JsonCard(title: 'ID token 摘要', data: _snapshot.token!.toJson()),
        ],
        if (_snapshot.userInfo != null) ...[
          const SizedBox(height: 12),
          _SpellAiUserInfoCard(userInfo: _snapshot.userInfo!),
          const SizedBox(height: 12),
          _JsonCard(
            title: '完整 SpellAI 用户 JSON',
            data: _snapshot.userInfo!.toJson(),
          ),
        ],
      ],
    );
  }
}

class _AuthStateCard extends StatelessWidget {
  const _AuthStateCard({required this.snapshot});

  final FakeAuthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final user = snapshot.user;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态：${snapshot.state.label}'),
            const SizedBox(height: 6),
            Text(snapshot.message),
            if (user != null) ...[
              const Divider(height: 24),
              Text('uid：${user.uid}'),
              Text('email：${user.email}'),
              Text('provider：${user.provider.providerId}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpellAiAuthMappingCard extends StatelessWidget {
  const _SpellAiAuthMappingCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SpellAI 对照'),
            SizedBox(height: 8),
            Text('Firebase 初始化：engine/service/thirds/firebase_service.dart'),
            Text('账号状态：engine/service/thirds/authentication.dart'),
            Text('登录 UI：ui/pages/login/login_page.dart + login_button.dart'),
            Text('登录成功后还要创建后端用户，失败时要退出 Firebase 用户'),
          ],
        ),
      ),
    );
  }
}

class _RealConfigCard extends StatelessWidget {
  const _RealConfigCard({required this.config});

  final SpellAiAuthConfig config;

  @override
  Widget build(BuildContext context) {
    final missing = config.missingDartDefines;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('运行配置'),
            const SizedBox(height: 8),
            _InfoRow(label: '后端环境', value: config.environment.label),
            _InfoRow(label: 'baseUrl', value: config.baseUrl),
            _InfoRow(
              label: 'Firebase project',
              value: config.projectId.isEmpty ? '未配置' : config.projectId,
            ),
            _InfoRow(
              label: 'LINE channel',
              value: config.canUseLine ? '已配置' : '未配置',
            ),
            if (missing.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                '缺少：${missing.join(', ')}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RealAuthStateCard extends StatelessWidget {
  const _RealAuthStateCard({required this.snapshot});

  final SpellAiAuthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态：${snapshot.phase.label}'),
            const SizedBox(height: 6),
            Text(snapshot.message),
            if (snapshot.provider != null)
              Text('provider：${snapshot.provider!.providerId}'),
            if (snapshot.error != null) ...[
              const Divider(height: 24),
              SelectableText(
                snapshot.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpellAiUserInfoCard extends StatelessWidget {
  const _SpellAiUserInfoCard({required this.userInfo});

  final SpellAiUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SpellAI 用户摘要'),
            const SizedBox(height: 8),
            _InfoRow(label: 'custom_uid', value: userInfo.uuid),
            _InfoRow(label: 'user_name', value: userInfo.userName),
            _InfoRow(label: 'is_vip', value: '${userInfo.isVip}'),
            _InfoRow(label: 'draw_num', value: '${userInfo.drawCount}'),
            _InfoRow(
              label: 'daily_ad_limit',
              value: '${userInfo.dailyAdLimit}',
            ),
            _InfoRow(
              label: 'subscribed_product_ids',
              value: userInfo.subscribedProductIds.join(', '),
            ),
            _InfoRow(
              label: 'chat remaining',
              value:
                  '${userInfo.chatSmartAvailableCount} / ${userInfo.chatSparkAvailableCount} / ${userInfo.chatMuseAvailableCount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _JsonCard extends StatelessWidget {
  const _JsonCard({required this.title, required this.data});

  final String title;
  final Map<String, Object?> data;

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                encoder.convert(data),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
