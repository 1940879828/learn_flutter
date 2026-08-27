import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

enum SpellAiServerEnvironment {
  test('测试服', 'https://sptv2.aimirror.fun'),
  production('正式服', 'https://sp.aimirror.fun');

  const SpellAiServerEnvironment(this.label, this.baseUrl);

  final String label;
  final String baseUrl;

  static SpellAiServerEnvironment fromName(String value) {
    return switch (value.trim().toLowerCase()) {
      'prod' || 'production' || 'release' => production,
      _ => test,
    };
  }
}

class SpellAiAuthConfig {
  const SpellAiAuthConfig({
    required this.environment,
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.storageBucket,
    required this.authDomain,
    required this.iosClientId,
    required this.iosBundleId,
    required this.androidClientId,
    required this.lineChannelId,
    required this.deviceId,
  });

  factory SpellAiAuthConfig.fromEnvironment() {
    return SpellAiAuthConfig(
      environment: SpellAiServerEnvironment.fromName(
        const String.fromEnvironment(
          'SPELLAI_SERVER_ENV',
          defaultValue: 'test',
        ),
      ),
      apiKey: const String.fromEnvironment('SPELLAI_FIREBASE_API_KEY'),
      appId: const String.fromEnvironment('SPELLAI_FIREBASE_APP_ID'),
      messagingSenderId: const String.fromEnvironment(
        'SPELLAI_FIREBASE_MESSAGING_SENDER_ID',
      ),
      projectId: const String.fromEnvironment('SPELLAI_FIREBASE_PROJECT_ID'),
      storageBucket: const String.fromEnvironment(
        'SPELLAI_FIREBASE_STORAGE_BUCKET',
      ),
      authDomain: const String.fromEnvironment('SPELLAI_FIREBASE_AUTH_DOMAIN'),
      iosClientId: const String.fromEnvironment(
        'SPELLAI_FIREBASE_IOS_CLIENT_ID',
      ),
      iosBundleId: const String.fromEnvironment(
        'SPELLAI_FIREBASE_IOS_BUNDLE_ID',
      ),
      androidClientId: const String.fromEnvironment(
        'SPELLAI_FIREBASE_ANDROID_CLIENT_ID',
      ),
      lineChannelId: const String.fromEnvironment('SPELLAI_LINE_CHANNEL_ID'),
      deviceId: const String.fromEnvironment(
        'SPELLAI_DEVICE_ID',
        defaultValue: 'learn-flutter-auth-lab',
      ),
    );
  }

  final SpellAiServerEnvironment environment;
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String storageBucket;
  final String authDomain;
  final String iosClientId;
  final String iosBundleId;
  final String androidClientId;
  final String lineChannelId;
  final String deviceId;

  bool get hasFirebaseOptions {
    return apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        messagingSenderId.isNotEmpty &&
        projectId.isNotEmpty &&
        storageBucket.isNotEmpty;
  }

  bool get canUseLine => lineChannelId.isNotEmpty;

  String get baseUrl => environment.baseUrl;

  FirebaseOptions get firebaseOptions {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket,
      authDomain: authDomain.isEmpty ? null : authDomain,
      iosClientId: iosClientId.isEmpty ? null : iosClientId,
      iosBundleId: iosBundleId.isEmpty ? null : iosBundleId,
      androidClientId: androidClientId.isEmpty ? null : androidClientId,
    );
  }

  List<String> get missingDartDefines {
    return [
      if (apiKey.isEmpty) 'SPELLAI_FIREBASE_API_KEY',
      if (appId.isEmpty) 'SPELLAI_FIREBASE_APP_ID',
      if (messagingSenderId.isEmpty) 'SPELLAI_FIREBASE_MESSAGING_SENDER_ID',
      if (projectId.isEmpty) 'SPELLAI_FIREBASE_PROJECT_ID',
      if (storageBucket.isEmpty) 'SPELLAI_FIREBASE_STORAGE_BUCKET',
      if (kIsWeb && authDomain.isEmpty) 'SPELLAI_FIREBASE_AUTH_DOMAIN',
    ];
  }
}
