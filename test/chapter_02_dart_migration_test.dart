import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter/chapter_02/dart_migration.dart';

void main() {
  test('SpellTask keeps fields and supports JSON roundtrip', () {
    final task = SpellTask.create(
      id: 'task_001',
      prompt: 'Make a spell card',
      status: SpellTaskStatus.running,
      createdAt: DateTime(2026, 8, 20, 9, 30),
      resultUrl: 'https://example.com/result.png',
    );

    expect(task.id, 'task_001');
    expect(task.prompt, 'Make a spell card');
    expect(task.status, SpellTaskStatus.running);
    expect(task.createdAt, DateTime(2026, 8, 20, 9, 30));

    final roundTrip = SpellTask.fromJson(task.toJson());

    expect(roundTrip.id, task.id);
    expect(roundTrip.prompt, task.prompt);
    expect(roundTrip.status, task.status);
    expect(roundTrip.createdAt, task.createdAt);
    expect(roundTrip.resultUrl, task.resultUrl);
  });

  test('copyWith only changes the requested fields', () {
    final base = SpellTask(
      id: 'task_002',
      prompt: 'Build a rune',
      status: SpellTaskStatus.pending,
      createdAt: DateTime(2026, 8, 20, 10, 0),
    );

    final changed = base.copyWith(status: SpellTaskStatus.done);

    expect(changed.id, base.id);
    expect(changed.prompt, base.prompt);
    expect(changed.status, SpellTaskStatus.done);
    expect(changed.createdAt, base.createdAt);
  });

  test('DateTime extension formats a lesson stamp', () {
    final value = DateTime(2026, 8, 20, 9, 5);

    expect(value.toLessonStamp(), '2026-08-20 09:05');
  });

  test('createSpellTask returns a Future<SpellTask>', () async {
    final task = await createSpellTask(
      prompt: 'Draw a blue flame',
      id: 'task_003',
      now: () => DateTime(2026, 8, 20, 11, 15),
      delay: Duration.zero,
    );

    expect(task.id, 'task_003');
    expect(task.prompt, 'Draw a blue flame');
    expect(task.status, SpellTaskStatus.pending);
    expect(task.createdAt, DateTime(2026, 8, 20, 11, 15));
  });
}
