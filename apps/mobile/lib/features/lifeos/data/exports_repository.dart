import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exports_repository.g.dart';

class ExportModel {
  ExportModel({
    required this.id,
    required this.status,
    required this.downloadUrl,
    required this.expiresAt,
  });

  final String id;
  final String status; // pending | ready | failed
  final String? downloadUrl;
  final DateTime? expiresAt;

  factory ExportModel.fromJson(Map<String, dynamic> json) {
    return ExportModel(
      id: json['id'] as String,
      status: json['status'] as String,
      downloadUrl: json['downloadUrl'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );
  }
}

class ExportsRepository {
  ExportsRepository(this._dio);
  final Dio _dio;

  Future<ExportModel> request() async {
    final response = await _dio.post<dynamic>(ApiConstants.exports);
    return ExportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ExportModel> get(String id) async {
    final response = await _dio.get<dynamic>(ApiConstants.exportById(id));
    return ExportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> deleteAccount() async {
    final response = await _dio.delete<dynamic>(ApiConstants.account);
    final data = response.data as Map<String, dynamic>;
    return data['success'] as bool? ?? false;
  }
}

@Riverpod(keepAlive: true)
ExportsRepository exportsRepository(Ref ref) {
  return ExportsRepository(ref.watch(dioProvider));
}
