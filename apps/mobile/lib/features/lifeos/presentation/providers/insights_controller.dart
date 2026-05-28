import 'package:mobile/features/lifeos/data/insights_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_controller.g.dart';

/// Loads active + saved insights and exposes generate / save / dismiss /
/// feedback actions, refreshing the list after each.
@riverpod
class InsightsController extends _$InsightsController {
  @override
  Future<List<InsightModel>> build() {
    return ref.read(insightsRepositoryProvider).list();
  }

  Future<void> generate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(insightsRepositoryProvider).generate();
      return ref.read(insightsRepositoryProvider).list();
    });
  }

  Future<void> _refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(insightsRepositoryProvider).list(),
    );
  }

  Future<void> save(String id) async {
    await ref.read(insightsRepositoryProvider).save(id);
    await _refresh();
  }

  Future<void> dismiss(String id) async {
    await ref.read(insightsRepositoryProvider).dismiss(id);
    await _refresh();
  }

  Future<void> feedback(String id, String value) async {
    await ref.read(insightsRepositoryProvider).feedback(id, value);
    await _refresh();
  }
}
