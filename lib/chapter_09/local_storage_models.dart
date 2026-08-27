import 'dart:convert';
import 'dart:io';

enum MockPermissionState {
  notDetermined('未询问', '还没有到需要相册能力的场景'),
  granted('已授权', '可以保存到相册或读取需要的媒体'),
  limited('部分授权', 'iOS limited：只能访问用户选择的一部分照片'),
  denied('已拒绝', '需要给出说明，必要时引导去设置页');

  const MockPermissionState(this.label, this.description);

  final String label;
  final String description;
}

class PromptRecord {
  const PromptRecord({
    required this.id,
    required this.prompt,
    required this.createdAt,
  });

  final String id;
  final String prompt;
  final DateTime createdAt;

  factory PromptRecord.fromJson(Map<String, Object?> json) {
    return PromptRecord(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FakePromptPreferences {
  String? _recentPrompt;

  Future<void> saveRecentPrompt(String prompt) async {
    _recentPrompt = prompt;
  }

  Future<String?> readRecentPrompt() async {
    return _recentPrompt;
  }
}

class JsonPromptFileStore {
  JsonPromptFileStore({Directory? directory})
    : _directory =
          directory ??
          Directory.systemTemp.createTempSync('learn_flutter_prompts_');

  final Directory _directory;

  Future<File> writeRecords(List<PromptRecord> records) async {
    if (!await _directory.exists()) {
      await _directory.create(recursive: true);
    }

    final file = File('${_directory.path}/prompt_records.json');
    final payload = {
      'updated_at': DateTime.now().toIso8601String(),
      'records': records.map((record) => record.toJson()).toList(),
    };
    return file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  Future<List<PromptRecord>> readRecords(File file) async {
    final payload =
        jsonDecode(await file.readAsString()) as Map<String, Object?>;
    final records = payload['records'] as List<Object?>? ?? const [];
    return records.whereType<Map>().map((record) {
      return PromptRecord.fromJson(Map<String, Object?>.from(record));
    }).toList();
  }
}
