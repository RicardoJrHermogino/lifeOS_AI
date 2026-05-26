import 'package:mobile/features/lifeos/data/memories_repository.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memories_provider.g.dart';

@riverpod
Future<List<MemoryModel>> memoryCandidates(Ref ref) async {
  final repo = ref.read(memoriesRepositoryProvider);
  return repo.listCandidates();
}

@riverpod
class MemoryActions extends _$MemoryActions {
  @override
  void build() {}

  Future<void> save({
    required String id,
    String? title,
    String? summary,
    DateTime? eventDate,
    List<String>? emotions,
    List<String>? people,
    List<String>? places,
    List<String>? topics,
    List<String>? goals,
    List<String>? decisions,
    List<String>? actions,
  }) async {
    final repo = ref.read(memoriesRepositoryProvider);
    await repo.update(
      id: id,
      title: title,
      summary: summary,
      eventDate: eventDate,
      emotions: emotions,
      people: people,
      places: places,
      topics: topics,
      goals: goals,
      decisions: decisions,
      actions: actions,
    );
    ref.invalidate(memoryCandidatesProvider);
  }

  Future<void> delete(String id) async {
    await ref.read(memoriesRepositoryProvider).delete(id);
    ref.invalidate(memoryCandidatesProvider);
  }

  Future<void> archive(String id) async {
    await ref.read(memoriesRepositoryProvider).archive(id);
    ref.invalidate(memoryCandidatesProvider);
  }
}
