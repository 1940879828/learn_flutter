enum SpellTaskStatus { pending, running, done, failed }

class SpellTask {
  final String id;
  final String prompt;
  final SpellTaskStatus status;
  final DateTime createdAt;
  final String? resultUrl;

  // 无参构造
  const SpellTask({
    required this.id,
    required this.prompt,
    required this.status,
    required this.createdAt,
    this.resultUrl,
  });

  // 工厂构造
  factory SpellTask.create({
    required String id,
    required String prompt,
    SpellTaskStatus status = SpellTaskStatus.pending,
    DateTime? createdAt,
    String? resultUrl,
  }) {
    return SpellTask(
      id: id,
      prompt: prompt,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      resultUrl: resultUrl,
    );
  }

  SpellTask copyWith({
    String? id,
    String? prompt,
    SpellTaskStatus? status,
    DateTime? createdAt,
    String? resultUrl,
  }) {
    return SpellTask(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resultUrl: resultUrl ?? this.resultUrl,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'prompt': prompt,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'resultUrl': resultUrl,
    };
  }

  factory SpellTask.fromJson(Map<String, Object?> json) {
    return SpellTask(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      status: SpellTaskStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resultUrl: json['resultUrl'] as String?,
    );
  }
}

extension DateTimeLessonFormat on DateTime {
  String toLessonStamp() {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${year.toString().padLeft(4, '0')}-${twoDigits(month)}-${twoDigits(day)} '
        '${twoDigits(hour)}:${twoDigits(minute)}';
  }
}

Future<SpellTask> createSpellTask({
  required String prompt,
  String? id,
  DateTime Function()? now,
  Duration delay = const Duration(milliseconds: 10),
}) async {
  final clock = now ?? DateTime.now;
  await Future<void>.delayed(delay);
  final createdAt = clock();

  return SpellTask.create(
    id: id ?? 'task_${createdAt.microsecondsSinceEpoch}',
    prompt: prompt,
    status: SpellTaskStatus.pending,
    createdAt: createdAt,
  );
}
