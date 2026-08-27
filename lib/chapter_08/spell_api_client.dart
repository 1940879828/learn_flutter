class SpellApiException implements Exception {
  const SpellApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FakeSpellApiClient {
  FakeSpellApiClient({Duration delay = const Duration(milliseconds: 500)})
    : _delay = delay;

  final Duration _delay;

  Future<List<Map<String, Object?>>> fetchGenerationTasks({
    bool shouldFail = false,
  }) async {
    await Future<void>.delayed(_delay);

    if (shouldFail) {
      throw const SpellApiException('模拟 DioException：服务暂时不可用');
    }

    return [
      {
        'id': 'draw_101',
        'prompt': 'Crystal mage portrait, neon rim light',
        'preview_url': 'https://example.com/previews/draw_101.png',
        'status': 'completed',
        'created_at': '2026-08-27T09:20:00.000Z',
      },
      {
        'id': 'video_204',
        'prompt': 'Turn a floating castle image into a 4s video',
        'preview_url': 'https://example.com/previews/video_204.mp4',
        'status': 'running',
        'created_at': '2026-08-27T09:24:00.000Z',
      },
      {
        'id': 'draw_305',
        'prompt': 'Warm potion shop icon set',
        'preview_url': 'https://example.com/previews/draw_305.png',
        'status': 'queued',
        'created_at': '2026-08-27T09:28:00.000Z',
      },
    ];
  }
}
