import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_repository.g.dart';

class TimelineGroup {
  TimelineGroup({required this.date, required this.memories});
  final String date;
  final List<MemoryModel> memories;
}

class TimelinePage {
  TimelinePage({required this.groups, required this.nextCursor});
  final List<TimelineGroup> groups;
  final String? nextCursor;
}

class TimelineRepository {
  TimelineRepository(this._dio);
  final Dio _dio;

  Future<TimelinePage> list({
    String? mood,
    String? person,
    String? topic,
    String? from,
    String? to,
    String? cursor,
    int? limit,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.timeline,
      queryParameters: {
        if (mood != null) 'mood': mood,
        if (person != null) 'person': person,
        if (topic != null) 'topic': topic,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final groups = (data['groups'] as List? ?? const []).map((g) {
      final map = g as Map<String, dynamic>;
      return TimelineGroup(
        date: map['date'] as String,
        memories: (map['memories'] as List)
            .map((m) => MemoryModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
    return TimelinePage(
      groups: groups,
      nextCursor: data['nextCursor'] as String?,
    );
  }
}

@Riverpod(keepAlive: true)
TimelineRepository timelineRepository(Ref ref) {
  return TimelineRepository(ref.watch(dioProvider));
}

@riverpod
Future<TimelinePage> timeline(Ref ref) async {
  return ref.read(timelineRepositoryProvider).list();
}
