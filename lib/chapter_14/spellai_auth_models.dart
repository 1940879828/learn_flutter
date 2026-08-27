import 'dart:convert';

enum SpellAiLoginProvider {
  google('Google', 'google.com'),
  apple('Apple', 'apple.com'),
  facebook('Facebook', 'facebook.com'),
  line('LINE', 'line.me');

  const SpellAiLoginProvider(this.label, this.providerId);

  final String label;
  final String providerId;
}

enum SpellAiAuthPhase {
  missingConfig('缺少配置'),
  anonymous('未登录'),
  initializing('初始化 Firebase'),
  authenticating('供应商认证中'),
  firebaseSignedIn('Firebase 已登录'),
  syncingBackend('同步 SpellAI 后端用户'),
  authenticated('业务登录完成'),
  canceled('用户取消'),
  error('登录失败');

  const SpellAiAuthPhase(this.label);

  final String label;
}

class SpellAiFirebaseUserSnapshot {
  const SpellAiFirebaseUserSnapshot({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.isAnonymous,
    required this.providerIds,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final List<String> providerIds;

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
      'providerIds': providerIds,
    };
  }
}

class SpellAiTokenSnapshot {
  const SpellAiTokenSnapshot({
    required this.uid,
    required this.maskedIdToken,
    required this.issuedAt,
    required this.expiresAt,
    required this.signInProvider,
  });

  factory SpellAiTokenSnapshot.fromIdToken({
    required String uid,
    required String idToken,
  }) {
    final payload = readJwtPayload(idToken);
    return SpellAiTokenSnapshot(
      uid: uid,
      maskedIdToken: maskBearerToken(idToken),
      issuedAt: _dateFromSeconds(payload?['iat']),
      expiresAt: _dateFromSeconds(payload?['exp']),
      signInProvider: payload?['firebase'] is Map<String, dynamic>
          ? (payload!['firebase'] as Map<String, dynamic>)['sign_in_provider']
                as String?
          : null,
    );
  }

  final String uid;
  final String maskedIdToken;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String? signInProvider;

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'maskedIdToken': maskedIdToken,
      'issuedAt': issuedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'signInProvider': signInProvider,
    };
  }
}

class SpellAiUserInfo {
  const SpellAiUserInfo({
    required this.uuid,
    required this.userName,
    required this.userIcon,
    required this.isVip,
    required this.drawCount,
    required this.dailyAdLimit,
    required this.adultRating,
    required this.subscribedProductIds,
    required this.useCoinDiscount,
    required this.isLifetimeVip,
    required this.chatSmartAvailableCount,
    required this.chatSparkAvailableCount,
    required this.chatMuseAvailableCount,
    required this.registeredVersion,
    required this.rawJson,
  });

  factory SpellAiUserInfo.fromJson(Map<String, dynamic> json) {
    return SpellAiUserInfo(
      uuid: json['custom_uid'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      userIcon: json['user_icon'] as String? ?? '',
      isVip: json['is_vip'] as bool? ?? false,
      drawCount: _intValue(json['draw_num']),
      dailyAdLimit: _intValue(json['daily_ad_limit']),
      adultRating: _intValue(json['flag']),
      subscribedProductIds:
          (json['subscribed_product_ids'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      useCoinDiscount: json['use_coin_discount'] as bool? ?? false,
      isLifetimeVip: json['is_lifetime_vip'] as bool? ?? false,
      chatSmartAvailableCount: _intValue(json['remaining_chat_times']),
      chatSparkAvailableCount: _intValue(json['spark_remaining_chat_times']),
      chatMuseAvailableCount: _intValue(json['muse_remaining_chat_times']),
      registeredVersion: json['registered_version'] as String? ?? '',
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  final String uuid;
  final String userName;
  final String userIcon;
  final bool isVip;
  final int drawCount;
  final int dailyAdLimit;
  final int adultRating;
  final List<String> subscribedProductIds;
  final bool useCoinDiscount;
  final bool isLifetimeVip;
  final int chatSmartAvailableCount;
  final int chatSparkAvailableCount;
  final int chatMuseAvailableCount;
  final String registeredVersion;
  final Map<String, dynamic> rawJson;

  Map<String, dynamic> toJson() => rawJson;
}

class SpellAiAuthSnapshot {
  const SpellAiAuthSnapshot({
    required this.phase,
    required this.message,
    this.provider,
    this.firebaseUser,
    this.token,
    this.userInfo,
    this.error,
  });

  final SpellAiAuthPhase phase;
  final String message;
  final SpellAiLoginProvider? provider;
  final SpellAiFirebaseUserSnapshot? firebaseUser;
  final SpellAiTokenSnapshot? token;
  final SpellAiUserInfo? userInfo;
  final String? error;

  bool get isBusy {
    return phase == SpellAiAuthPhase.initializing ||
        phase == SpellAiAuthPhase.authenticating ||
        phase == SpellAiAuthPhase.syncingBackend;
  }

  bool get logged => userInfo != null && firebaseUser != null;
}

String maskBearerToken(String token) {
  if (token.length <= 16) return '***';
  return '${token.substring(0, 8)}...${token.substring(token.length - 8)}';
}

Map<String, dynamic>? readJwtPayload(String idToken) {
  final parts = idToken.split('.');
  if (parts.length < 2) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(payload);
    return json is Map<String, dynamic> ? json : null;
  } catch (_) {
    return null;
  }
}

DateTime? _dateFromSeconds(Object? value) {
  return switch (value) {
    final int seconds => DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    ),
    final num seconds => DateTime.fromMillisecondsSinceEpoch(
      seconds.toInt() * 1000,
      isUtc: true,
    ),
    _ => null,
  };
}

int _intValue(Object? value) {
  return switch (value) {
    final int number => number,
    final num number => number.toInt(),
    _ => 0,
  };
}
