enum SpellGenerationStatus {
  queued('排队中'),
  running('生成中'),
  completed('已完成');

  const SpellGenerationStatus(this.label);

  final String label;

  static SpellGenerationStatus fromJson(String value) {
    return SpellGenerationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SpellGenerationStatus.queued,
    );
  }
}

class SpellGenerationTask {
  const SpellGenerationTask({
    required this.id,
    required this.prompt,
    required this.previewUrl,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String prompt;
  final String previewUrl;
  final SpellGenerationStatus status;
  final DateTime createdAt;

  factory SpellGenerationTask.fromJson(Map<String, Object?> json) {
    return SpellGenerationTask(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      previewUrl: json['preview_url'] as String? ?? '',
      status: SpellGenerationStatus.fromJson(json['status'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'preview_url': previewUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

sealed class SpellTaskResult {
  const SpellTaskResult();
}

class SpellTaskLoading extends SpellTaskResult {
  const SpellTaskLoading();
}

class SpellTaskSuccess extends SpellTaskResult {
  const SpellTaskSuccess(this.tasks);

  final List<SpellGenerationTask> tasks;
}

class SpellTaskFailure extends SpellTaskResult {
  const SpellTaskFailure(this.message);

  final String message;
}
