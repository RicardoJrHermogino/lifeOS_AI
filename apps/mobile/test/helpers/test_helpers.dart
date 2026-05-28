import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lifeos/data/captures_repository.dart';
import 'package:mobile/features/lifeos/data/insights_repository.dart';
import 'package:mobile/features/lifeos/data/search_repository.dart';
import 'package:mobile/features/lifeos/data/settings_repository.dart';
import 'package:mobile/features/lifeos/data/timeline_repository.dart';
import 'package:mobile/features/lifeos/presentation/providers/connectivity_provider.dart';
import 'package:mobile/services/storage/capture_queue_storage.dart';

import 'fake_repositories.dart';

ProviderContainer makeContainer({
  FakeTimelineRepository? timeline,
  FakeCapturesRepository? captures,
  FakeInsightsRepository? insights,
  FakeSettingsRepository? settings,
  FakeSearchRepository? search,
  FakeCaptureQueueStorage? storage,
  bool isOnline = true,
}) {
  final container = ProviderContainer(
    overrides: [
      if (timeline != null)
        timelineRepositoryProvider.overrideWithValue(timeline),
      if (captures != null)
        capturesRepositoryProvider.overrideWithValue(captures),
      if (insights != null)
        insightsRepositoryProvider.overrideWithValue(insights),
      if (settings != null)
        settingsRepositoryProvider.overrideWithValue(settings),
      if (search != null) searchRepositoryProvider.overrideWithValue(search),
      if (storage != null)
        captureQueueStorageProvider.overrideWithValue(storage),
      isOnlineProvider.overrideWithValue(AsyncData(isOnline)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
