import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reflections_repository.g.dart';

class ReflectionModel {
  ReflectionModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.content,
    required this.sourceMemoryIds,
    required this.isUserEdited,
    required this.feedback,
  });

  final String id;
  final String userId;
  final String date;
  final String content;
  final List<String> sourceMemoryIds;
  final bool isUserEdited;
  final String? feedback;

  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: json['date'] as String,
      content: json['content'] as String,
      sourceMemoryIds: (json['sourceMemoryIds'] as List? ?? const [])
          .map((e) => e as String)
          .toList(),
      isUserEdited: json['isUserEdited'] as bool? ?? false,
      feedback: json['feedback'] as String?,
    );
  }
}

class ReflectionsRepository {
  ReflectionsRepository(this._dio);
  final Dio _dio;

  Future<ReflectionModel> getByDate(String date) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.reflectionByDate(date),
    );
    return ReflectionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReflectionModel> submitFeedback({
    required String id,
    required String feedback,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.reflectionFeedback(id),
      data: {'feedback': feedback},
    );
    return ReflectionModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@Riverpod(keepAlive: true)
ReflectionsRepository reflectionsRepository(Ref ref) {
  return ReflectionsRepository(ref.watch(dioProvider));
}

@riverpod
Future<ReflectionModel> todayReflection(Ref ref) async {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return ref.read(reflectionsRepositoryProvider).getByDate(today);
}
