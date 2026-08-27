import 'spell_api_client.dart';
import 'spell_generation_models.dart';

class SpellTaskRepository {
  const SpellTaskRepository(this._client);

  final FakeSpellApiClient _client;

  Future<SpellTaskResult> loadTasks({bool fail = false}) async {
    try {
      final payload = await _client.fetchGenerationTasks(shouldFail: fail);
      final tasks = payload.map(SpellGenerationTask.fromJson).toList();
      return SpellTaskSuccess(tasks);
    } on SpellApiException catch (error) {
      return SpellTaskFailure(error.message);
    } on Exception catch (error) {
      return SpellTaskFailure('未知解析错误：$error');
    }
  }
}
