import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository.g.dart';

class SettingsModel {
  SettingsModel({
    required this.userId,
    required this.aiProcessingConsent,
    required this.aiPersonalization,
    required this.proactiveInsights,
    required this.reflectionTone,
    required this.sensitiveTopics,
    required this.dailyReminder,
    required this.reminderTime,
    required this.appLock,
  });

  final String userId;
  final bool aiProcessingConsent;
  final bool aiPersonalization;
  final bool proactiveInsights;
  final String reflectionTone; // neutral | warm | direct
  final List<String> sensitiveTopics;
  final bool dailyReminder;
  final String? reminderTime; // HH:MM
  final bool appLock;

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      userId: json['userId'] as String,
      aiProcessingConsent: json['aiProcessingConsent'] as bool? ?? true,
      aiPersonalization: json['aiPersonalization'] as bool? ?? true,
      proactiveInsights: json['proactiveInsights'] as bool? ?? false,
      reflectionTone: json['reflectionTone'] as String? ?? 'warm',
      sensitiveTopics: (json['sensitiveTopics'] as List? ?? const [])
          .map((e) => e as String)
          .toList(),
      dailyReminder: json['dailyReminder'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String?,
      appLock: json['appLock'] as bool? ?? false,
    );
  }
}

class SettingsRepository {
  SettingsRepository(this._dio);
  final Dio _dio;

  Future<SettingsModel> get() async {
    final response = await _dio.get<dynamic>(ApiConstants.settings);
    return SettingsModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Partial update. Only include the keys you want to change. Pass an explicit
  /// `null` for `reminderTime` to clear it.
  Future<SettingsModel> update(Map<String, dynamic> patch) async {
    final response = await _dio.patch<dynamic>(
      ApiConstants.settings,
      data: patch,
    );
    return SettingsModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(dioProvider));
}
