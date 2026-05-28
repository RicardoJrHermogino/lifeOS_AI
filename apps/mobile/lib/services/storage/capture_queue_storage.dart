import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/features/lifeos/data/models/queued_capture.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_queue_storage.g.dart';

/// Persists the offline capture queue in encrypted secure storage (captures may
/// contain private text, so plain shared_preferences is avoided).
class CaptureQueueStorage {
  CaptureQueueStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _key = 'capture_queue';

  Future<List<QueuedCapture>> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => QueuedCapture.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt payload — drop it rather than crash the queue.
      await _storage.delete(key: _key);
      return [];
    }
  }

  Future<void> save(List<QueuedCapture> queue) async {
    if (queue.isEmpty) {
      await _storage.delete(key: _key);
      return;
    }
    final raw = jsonEncode(queue.map((q) => q.toJson()).toList());
    await _storage.write(key: _key, value: raw);
  }
}

@Riverpod(keepAlive: true)
CaptureQueueStorage captureQueueStorage(Ref ref) {
  return CaptureQueueStorage();
}
