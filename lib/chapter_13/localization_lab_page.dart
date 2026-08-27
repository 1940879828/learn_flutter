import 'package:flutter/material.dart';

import '../learning_navigation_controls.dart';
import 'localization_models.dart';

class LocalizationLabPage extends StatefulWidget {
  const LocalizationLabPage({super.key});

  @override
  State<LocalizationLabPage> createState() => _LocalizationLabPageState();
}

class _LocalizationLabPageState extends State<LocalizationLabPage> {
  LearningLocale _locale = LearningLocale.en;
  int _credits = 12;

  void _setLocale(LearningLocale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _spendCredit() {
    setState(() {
      if (_credits > 0) {
        _credits -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = LearningMessageCatalog(_locale);
    final preview = catalog.preview(name: 'Mia', count: _credits);

    return Scaffold(
      appBar: AppBar(
        leading: const LearningBackOrHomeButton(),
        title: const Text('13 多语言与本地化'),
        actions: const [LearningHomeAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('多语言字典实验', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              '先用小字典理解 key、fallback、占位符，再回到 SpellAI 的 .arb 和 gen-l10n。',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LearningLocale.values.map((locale) {
                return ChoiceChip(
                  selected: _locale == locale,
                  label: Text(locale.label),
                  onSelected: (_) => _setLocale(locale),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _PreviewCard(preview: preview, locale: _locale),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _spendCredit,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('模拟消耗 1 个金币'),
            ),
            const SizedBox(height: 16),
            const _SpellAiMappingCard(),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview, required this.locale});

  final Map<String, String> preview;
  final LearningLocale locale;

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
            Text('当前 locale：${locale.code}'),
            const SizedBox(height: 8),
            Text(
              preview['title']!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(preview['welcome']!),
            Text(preview['promptHint']!),
            Text(preview['credits']!),
            const Divider(height: 24),
            Text('fallback 示例：${preview['fallback']}'),
          ],
        ),
      ),
    );
  }
}

class _SpellAiMappingCard extends StatelessWidget {
  const _SpellAiMappingCard();

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
            Text('源文件：lib/l10n/intl_*.arb'),
            Text('生成文件：lib/l10n/localization_intl_*.dart'),
            Text(
              '入口：MaterialApp.router 的 localizationsDelegates / supportedLocales',
            ),
            Text('命令：fvm flutter gen-l10n'),
          ],
        ),
      ),
    );
  }
}
