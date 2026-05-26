import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memories_repository.g.dart';

class MemoriesRepository {
  MemoriesRepository(this._dio);

  final Dio _dio;

  Future<List<MemoryModel>> listCandidates() async {
    final response = await _dio.get<dynamic>(ApiConstants.memoryCandidates);
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List? ?? const [];
    return items
        .map((e) => MemoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MemoryModel> update({
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
    String? sensitivity,
  }) async {
    final response = await _dio.patch<dynamic>(
      ApiConstants.memoryById(id),
      data: {
        if (title != null) 'title': title,
        if (summary != null) 'summary': summary,
        if (eventDate != null) 'eventDate': eventDate.toIso8601String(),
        if (emotions != null) 'emotions': emotions,
        if (people != null) 'people': people,
        if (places != null) 'places': places,
        if (topics != null) 'topics': topics,
        if (goals != null) 'goals': goals,
        if (decisions != null) 'decisions': decisions,
        if (actions != null) 'actions': actions,
        if (sensitivity != null) 'sensitivity': sensitivity,
      },
    );
    return MemoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete<dynamic>(ApiConstants.memoryById(id));
  }

  Future<MemoryModel> archive(String id) async {
    final response = await _dio.patch<dynamic>(ApiConstants.memoryArchive(id));
    return MemoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MemoryModel> restore(String id) async {
    final response = await _dio.patch<dynamic>(ApiConstants.memoryRestore(id));
    return MemoryModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@Riverpod(keepAlive: true)
MemoriesRepository memoriesRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MemoriesRepository(dio);
}
