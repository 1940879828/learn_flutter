enum LearningLocale {
  en('en', 'English'),
  zh('zh', '中文'),
  ja('ja', '日本語');

  const LearningLocale(this.code, this.label);

  final String code;
  final String label;
}

class LearningMessageCatalog {
  const LearningMessageCatalog(this.locale);

  final LearningLocale locale;

  static const LearningLocale fallbackLocale = LearningLocale.en;

  static const Map<LearningLocale, Map<String, String>> _messages = {
    LearningLocale.en: {
      'title': 'Create with SpellAI',
      'promptHint': 'Describe your idea',
      'credits': '{count} credits left',
      'welcome': 'Welcome back, {name}',
      'missingOnlyInEnglish': 'Fallback text from English',
    },
    LearningLocale.zh: {
      'title': '用 SpellAI 创作',
      'promptHint': '描述你的想法',
      'credits': '剩余 {count} 个金币',
      'welcome': '欢迎回来，{name}',
    },
    LearningLocale.ja: {
      'title': 'SpellAI で作成',
      'promptHint': 'アイデアを入力',
      'credits': '残り {count} クレジット',
      'welcome': '{name} さん、おかえりなさい',
    },
  };

  String text(String key, [Map<String, Object> args = const {}]) {
    final localeMessages = _messages[locale] ?? const <String, String>{};
    final template =
        localeMessages[key] ?? _messages[fallbackLocale]?[key] ?? '[$key]';
    return args.entries.fold(template, (value, entry) {
      return value.replaceAll('{${entry.key}}', entry.value.toString());
    });
  }

  Map<String, String> preview({required String name, required int count}) {
    return {
      'title': text('title'),
      'promptHint': text('promptHint'),
      'credits': text('credits', {'count': count}),
      'welcome': text('welcome', {'name': name}),
      'fallback': text('missingOnlyInEnglish'),
    };
  }
}
