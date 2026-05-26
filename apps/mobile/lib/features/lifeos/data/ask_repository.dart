import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ask_repository.g.dart';

class AskResult {
  AskResult({required this.answer, required this.citations});
  final String answer;
  final List<AskCitation> citations;
}

class AskCitation {
  AskCitation({required this.memoryId, required this.title});
  final String memoryId;
  final String title;
}

class AskRepository {
  AskRepository(this._dio);
  final Dio _dio;

  Future<AskResult> ask(String question) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.ask,
      data: {'question': question},
    );
    final data = response.data as Map<String, dynamic>;
    final cits = (data['citations'] as List? ?? const []).map((c) {
      final m = c as Map<String, dynamic>;
      return AskCitation(
        memoryId: m['memoryId'] as String,
        title: m['title'] as String,
      );
    }).toList();
    return AskResult(answer: data['answer'] as String, citations: cits);
  }
}

@Riverpod(keepAlive: true)
AskRepository askRepository(Ref ref) {
  return AskRepository(ref.watch(dioProvider));
}
