import 'dart:async';
import 'dart:math';

import 'package:mobile/features/lifeos/data/captures_repository.dart';
import 'package:mobile/features/lifeos/data/models/queued_capture.dart';
import 'package:mobile/features/lifeos/presentation/providers/connectivity_provider.dart';
import 'package:mobile/services/storage/capture_queue_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_sync_controller.g.dart';

/// Owns the offline capture queue: persists locally, syncs to the backend when
/// online, and dedupes via each capture's `syncId` (backend is idempotent).
@Riverpod(keepAlive: true)
class CaptureSyncController extends _$CaptureSyncController {
  @override
  Future<List<QueuedCapture>> build() async {
    // Auto-sync whenever connectivity is (re)gained.
    ref.listen(isOnlineProvider, (_, next) {
      if (next.value == true) unawaited(syncNow());
    });

    final loaded = await ref.read(captureQueueStorageProvider).load();
    // Drain anything left over from a previous session if we're online now.
    if (loaded.isNotEmpty) {
      Future.microtask(() {
        if (ref.read(isOnlineProvider).value ?? true) unawaited(syncNow());
      });
    }
    return loaded;
  }

  String _newSyncId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(0x7fffffff)}';

  Future<void> _persist(List<QueuedCapture> queue) async {
    await ref.read(captureQueueStorageProvider).save(queue);
    state = AsyncData(queue);
  }

  /// Adds a text capture to the queue and attempts an immediate sync if online.
  Future<void> enqueueText({required String body, String? mood}) async {
    final queue = [
      ...(state.value ?? const <QueuedCapture>[]),
      QueuedCapture(
        syncId: _newSyncId(),
        type: 'text',
        body: body,
        audioUrl: null,
        mood: mood,
        createdAt: DateTime.now(),
      ),
    ];
    await _persist(queue);
    if (ref.read(isOnlineProvider).value == true) {
      unawaited(syncNow());
    }
  }

  /// Uploads every queued capture. Successful ones are removed; failures are
  /// kept and marked `failed` for retry.
  Future<void> syncNow() async {
    final current = state.value;
    if (current == null || current.isEmpty) return;

    await _persist(
      current
          .map((q) => q.copyWith(status: QueuedCaptureStatus.syncing))
          .toList(),
    );

    final repo = ref.read(capturesRepositoryProvider);
    final remaining = <QueuedCapture>[];
    for (final item in current) {
      try {
        await repo.createCapture(
          type: item.type,
          body: item.body,
          audioUrl: item.audioUrl,
          mood: item.mood,
          syncId: item.syncId,
        );
      } catch (_) {
        remaining.add(item.copyWith(status: QueuedCaptureStatus.failed));
      }
    }
    await _persist(remaining);
  }

  /// Drops a queued item without syncing it.
  Future<void> remove(String syncId) async {
    final queue = (state.value ?? const <QueuedCapture>[])
        .where((q) => q.syncId != syncId)
        .toList();
    await _persist(queue);
  }
}
