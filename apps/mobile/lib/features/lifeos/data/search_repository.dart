import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_repository.g.dart';

class SearchHit {
  SearchHit({required this.memory, required this.score});

  final MemoryModel memory;
  final double score;

  String get memoryId => memory.id;
  String get title => memory.title;
  String get snippet => memory.summary;
  DateTime get eventDate => memory.eventDate;
  List<String> get matchedTopics => memory.topics;
}

class SearchRepository {
  SearchRepository(this._dio);
  final Dio _dio;

  Future<List<SearchHit>> search(String query, {int? limit}) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.search,
      data: {'query': query, if (limit != null) 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List? ?? const [];
    return results.map((item) {
      final map = item as Map<String, dynamic>;
      return SearchHit(
        memory: MemoryModel.fromJson(map['memory'] as Map<String, dynamic>),
        score: (map['score'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }
}

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(ref.watch(dioProvider));
}
