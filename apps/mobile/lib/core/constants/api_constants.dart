import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  static String get versionedUrl => '$baseUrl/$apiVersion';

  // Auth endpoints (Better Auth - no envelope)
  static String get signIn => '$versionedUrl/auth/sign-in/email';
  static String get signUp => '$versionedUrl/auth/sign-up/email';
  static String get signOut => '$versionedUrl/auth/sign-out';
  static String get getSession => '$versionedUrl/auth/get-session';

  // Todo endpoints (NestJS - oRPC)
  static String get todos => '$versionedUrl/example/todos';
  static String todoById(int id) => '$versionedUrl/example/todos/$id';

  // LifeOS - Captures
  static String get captures => '$versionedUrl/captures';
  static String captureById(String id) => '$versionedUrl/captures/$id';
  static String captureTranscript(String id) =>
      '$versionedUrl/captures/$id/transcript';

  // LifeOS - Memories
  static String get memoryCandidates => '$versionedUrl/memories/candidates';
  static String memoryById(String id) => '$versionedUrl/memories/$id';
  static String memoryArchive(String id) =>
      '$versionedUrl/memories/$id/archive';
  static String memoryRestore(String id) =>
      '$versionedUrl/memories/$id/restore';

  // LifeOS - Timeline / Search / Ask / Reflections / Exports
  static String get timeline => '$versionedUrl/timeline';
  static String get search => '$versionedUrl/search';
  static String get ask => '$versionedUrl/ask';
  static String reflectionByDate(String date) =>
      '$versionedUrl/reflections/$date';
  static String reflectionById(String id) => '$versionedUrl/reflections/$id';
  static String reflectionFeedback(String id) =>
      '$versionedUrl/reflections/$id/feedback';
  static String get exports => '$versionedUrl/exports';
  static String exportById(String id) => '$versionedUrl/exports/$id';
  static String get account => '$versionedUrl/account';

  // LifeOS - Settings
  static String get settings => '$versionedUrl/settings';
}
