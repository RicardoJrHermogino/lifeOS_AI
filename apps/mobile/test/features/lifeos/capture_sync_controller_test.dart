import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lifeos/data/models/queued_capture.dart';
import 'package:mobile/features/lifeos/presentation/providers/capture_sync_controller.dart';
import 'package:mobile/features/lifeos/presentation/providers/connectivity_provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_helpers.dart';

void main() {
  test('enqueueText persists and calls repo when online', () async {
    final repo = FakeCapturesRepository();
    final storage = FakeCaptureQueueStorage();
    final container = makeContainer(captures: repo, storage: storage);

    await container.read(isOnlineProvider.future);
    await container.read(captureSyncControllerProvider.future);
    await container
        .read(captureSyncControllerProvider.notifier)
        .enqueueText(body: 'note');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(storage.saved, isNotEmpty);
    expect(repo.calls.single['body'], 'note');
  });

  test('offline enqueue retains queue and does not call repo', () async {
    final repo = FakeCapturesRepository();
    final storage = FakeCaptureQueueStorage();
    final container = makeContainer(
      captures: repo,
      storage: storage,
      isOnline: false,
    );

    await container.read(isOnlineProvider.future);
    await container.read(captureSyncControllerProvider.future);
    await container
        .read(captureSyncControllerProvider.notifier)
        .enqueueText(body: 'note');

    expect(repo.calls, isEmpty);
    expect(container.read(captureSyncControllerProvider).value, hasLength(1));
  });

  test(
    'syncNow clears queue on success and marks failed on repo throw',
    () async {
      final repo = FakeCapturesRepository();
      final storage = FakeCaptureQueueStorage()
        ..value = [
          QueuedCapture(
            syncId: 'sync-1',
            type: 'text',
            body: 'note',
            audioUrl: null,
            mood: null,
            createdAt: testNow,
          ),
        ];
      final container = makeContainer(captures: repo, storage: storage);

      await container.read(captureSyncControllerProvider.future);
      await container.read(captureSyncControllerProvider.notifier).syncNow();
      expect(container.read(captureSyncControllerProvider).value, isEmpty);

      storage.value = [
        QueuedCapture(
          syncId: 'sync-2',
          type: 'text',
          body: 'note',
          audioUrl: null,
          mood: null,
          createdAt: testNow,
        ),
      ];
      repo.error = StateError('boom');
      container.invalidate(captureSyncControllerProvider);
      await container.read(captureSyncControllerProvider.future);
      await container.read(captureSyncControllerProvider.notifier).syncNow();

      expect(
        container.read(captureSyncControllerProvider).value!.single.status,
        QueuedCaptureStatus.failed,
      );
    },
  );
}
