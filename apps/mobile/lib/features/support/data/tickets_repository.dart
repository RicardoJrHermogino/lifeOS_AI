import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tickets_repository.g.dart';

class TicketsRepository {
  TicketsRepository(this._dio);
  final Dio _dio;

  Future<void> submit({
    required String name,
    required String email,
    required String subject,
    required String priority,
    required String concern,
  }) async {
    await _dio.post<dynamic>(
      ApiConstants.tickets,
      data: {
        'name': name,
        'email': email,
        'subject': subject,
        'priority': priority,
        'concern': concern,
      },
    );
  }
}

@Riverpod(keepAlive: true)
TicketsRepository ticketsRepository(Ref ref) {
  return TicketsRepository(ref.watch(dioProvider));
}
