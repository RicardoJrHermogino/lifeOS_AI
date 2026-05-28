import 'package:mobile/features/lifeos/data/captures_repository.dart';
import 'package:mobile/features/lifeos/data/insights_repository.dart';
import 'package:mobile/features/lifeos/data/models/capture_model.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/features/lifeos/data/models/queued_capture.dart';
import 'package:mobile/features/lifeos/data/search_repository.dart';
import 'package:mobile/features/lifeos/data/settings_repository.dart';
import 'package:mobile/features/lifeos/data/timeline_repository.dart';
import 'package:mobile/services/storage/capture_queue_storage.dart';

final testNow = DateTime(2026, 5, 28);

MemoryModel makeMemory({
  String id = '11111111-1111-4111-8111-111111111111',
  String title = 'Memory',
  String summary = 'Summary',
  List<String> topics = const ['topic'],
}) {
  return MemoryModel(
    id: id,
    userId: 'user-1',
    rawCaptureId: null,
    title: title,
    summary: summary,
    eventDate: testNow,
    emotions: const [],
    people: const [],
    places: const [],
    topics: topics,
    goals: const [],
    decisions: const [],
    actions: const [],
    sensitivity: null,
    confidence: const {},
    status: 'saved',
    isUserCorrected: false,
    createdAt: testNow,
    updatedAt: testNow,
  );
}

CaptureModel makeCapture({String? syncId}) {
  return CaptureModel(
    id: 'capture-1',
    userId: 'user-1',
    type: 'text',
    body: 'body',
    audioUrl: null,
    transcript: null,
    transcriptCorrected: false,
    mood: null,
    status: 'done',
    syncId: syncId,
    capturedAt: testNow,
    createdAt: testNow,
    updatedAt: testNow,
  );
}

SettingsModel makeSettings({bool proactiveInsights = true}) {
  return SettingsModel(
    userId: 'user-1',
    aiProcessingConsent: true,
    aiPersonalization: true,
    proactiveInsights: proactiveInsights,
    reflectionTone: 'warm',
    sensitiveTopics: const [],
    dailyReminder: false,
    reminderTime: null,
    appLock: false,
  );
}

InsightModel makeInsight({String id = 'insight-1', String status = 'active'}) {
  return InsightModel(
    id: id,
    type: 'pattern',
    title: 'Insight',
    body: 'Body',
    sourceMemoryIds: const [],
    evidence: 'moderate',
    status: status,
    feedback: null,
  );
}

class FakeTimelineRepository implements TimelineRepository {
  final calls = <Map<String, Object?>>[];
  final pages = <TimelinePage>[];
  Object? error;

  @override
  Future<TimelinePage> list({
    String? mood,
    String? person,
    String? topic,
    String? from,
    String? to,
    String? cursor,
    int? limit,
  }) async {
    calls.add({
      'mood': mood,
      'person': person,
      'topic': topic,
      'from': from,
      'to': to,
      'cursor': cursor,
      'limit': limit,
    });
    final err = error;
    if (err != null) throw err;
    return pages.removeAt(0);
  }
}

class FakeCapturesRepository implements CapturesRepository {
  final calls = <Map<String, Object?>>[];
  Object? error;

  @override
  Future<CaptureModel> createCapture({
    required String type,
    String? body,
    String? audioUrl,
    String? mood,
    String? syncId,
  }) async {
    calls.add({
      'type': type,
      'body': body,
      'audioUrl': audioUrl,
      'mood': mood,
      'syncId': syncId,
    });
    final err = error;
    if (err != null) throw err;
    return makeCapture(syncId: syncId);
  }

  @override
  Future<CaptureModel> getCapture(String id) async => makeCapture();

  @override
  Future<CaptureModel> patchTranscript({
    required String id,
    required String transcript,
  }) async => makeCapture();
}

class FakeInsightsRepository implements InsightsRepository {
  final calls = <String>[];
  List<InsightModel> listResult = [makeInsight()];

  @override
  Future<List<InsightModel>> list() async {
    calls.add('list');
    return listResult;
  }

  @override
  Future<List<InsightModel>> generate() async {
    calls.add('generate');
    return [makeInsight(id: 'generated')];
  }

  @override
  Future<void> save(String id) async => calls.add('save:$id');

  @override
  Future<void> dismiss(String id) async => calls.add('dismiss:$id');

  @override
  Future<void> feedback(String id, String feedback) async =>
      calls.add('feedback:$id:$feedback');
}

class FakeSettingsRepository implements SettingsRepository {
  final patches = <Map<String, dynamic>>[];
  SettingsModel value = makeSettings();

  @override
  Future<SettingsModel> get() async => value;

  @override
  Future<SettingsModel> update(Map<String, dynamic> patch) async {
    patches.add(patch);
    value = makeSettings(proactiveInsights: patch['proactiveInsights'] as bool);
    return value;
  }
}

class FakeSearchRepository implements SearchRepository {
  final calls = <Map<String, Object?>>[];
  List<SearchHit> results = [SearchHit(memory: makeMemory(), score: 0.9)];

  @override
  Future<List<SearchHit>> search(String query, {int? limit}) async {
    calls.add({'query': query, 'limit': limit});
    return results;
  }
}

class FakeCaptureQueueStorage implements CaptureQueueStorage {
  List<QueuedCapture> value = [];
  final saved = <List<QueuedCapture>>[];

  @override
  Future<List<QueuedCapture>> load() async => value;

  @override
  Future<void> save(List<QueuedCapture> queue) async {
    value = queue;
    saved.add(queue);
  }
}
