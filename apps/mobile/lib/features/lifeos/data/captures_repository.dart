import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/lifeos/data/models/capture_model.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'captures_repository.g.dart';

class CapturesRepository {
  CapturesRepository(this._dio);

  final Dio _dio;

  Future<CaptureModel> createCapture({
    required String type,
    String? body,
    String? audioUrl,
    String? mood,
    String? syncId,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.captures,
      data: {
        'type': type,
        if (body != null) 'body': body,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (mood != null) 'mood': mood,
        if (syncId != null) 'syncId': syncId,
      },
    );
    return CaptureModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CaptureModel> getCapture(String id) async {
    final response = await _dio.get<dynamic>(ApiConstants.captureById(id));
    return CaptureModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CaptureModel> patchTranscript({
    required String id,
    required String transcript,
  }) async {
    final response = await _dio.patch<dynamic>(
      ApiConstants.captureTranscript(id),
      data: {'transcript': transcript},
    );
    return CaptureModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@Riverpod(keepAlive: true)
CapturesRepository capturesRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CapturesRepository(dio);
}
