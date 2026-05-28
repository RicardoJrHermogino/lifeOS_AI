import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_repository.g.dart';

class InsightModel {
  InsightModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.sourceMemoryIds,
    required this.evidence,
    required this.status,
    required this.feedback,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final List<String> sourceMemoryIds;
  final String evidence; // weak | moderate | strong
  final String status; // active | saved | dismissed | deleted
  final String? feedback; // helpful | not_helpful | wrong

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'pattern',
      title: json['title'] as String,
      body: json['body'] as String,
      sourceMemoryIds: (json['sourceMemoryIds'] as List? ?? const [])
          .map((e) => e as String)
          .toList(),
      evidence: json['evidence'] as String? ?? 'moderate',
      status: json['status'] as String? ?? 'active',
      feedback: json['feedback'] as String?,
    );
  }
}

class InsightsRepository {
  InsightsRepository(this._dio);
  final Dio _dio;

  List<InsightModel> _parseList(dynamic data) {
    final list = data as List? ?? const [];
    return list
        .map((e) => InsightModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<InsightModel>> list() async {
    final response = await _dio.get<dynamic>(ApiConstants.insights);
    return _parseList(response.data);
  }

  Future<List<InsightModel>> generate() async {
    final response = await _dio.post<dynamic>(ApiConstants.insightGenerate);
    return _parseList(response.data);
  }

  Future<void> save(String id) async {
    await _dio.patch<dynamic>(ApiConstants.insightSave(id));
  }

  Future<void> dismiss(String id) async {
    await _dio.patch<dynamic>(ApiConstants.insightDismiss(id));
  }

  Future<void> feedback(String id, String feedback) async {
    await _dio.post<dynamic>(
      ApiConstants.insightFeedback(id),
      data: {'feedback': feedback},
    );
  }
}

@Riverpod(keepAlive: true)
InsightsRepository insightsRepository(Ref ref) {
  return InsightsRepository(ref.watch(dioProvider));
}
