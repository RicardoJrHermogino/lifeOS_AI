import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lifeos/data/timeline_repository.dart';
import 'package:mobile/features/lifeos/presentation/providers/timeline_controller.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_helpers.dart';

void main() {
  test('initial build returns first page', () async {
    final repo = FakeTimelineRepository()
      ..pages.add(TimelinePage(groups: [], nextCursor: null));
    final container = makeContainer(timeline: repo);

    final state = await container.read(timelineControllerProvider.future);

    expect(state.groups, isEmpty);
    expect(repo.calls, hasLength(1));
  });

  test('loadMore appends a page with a new date', () async {
    final first = TimelineGroup(date: '2026-05-28', memories: [makeMemory()]);
    final second = TimelineGroup(
      date: '2026-05-27',
      memories: [makeMemory(id: '22222222-2222-4222-8222-222222222222')],
    );
    final repo = FakeTimelineRepository()
      ..pages.add(TimelinePage(groups: [first], nextCursor: 'cursor-1'))
      ..pages.add(TimelinePage(groups: [second], nextCursor: null));
    final container = makeContainer(timeline: repo);

    await container.read(timelineControllerProvider.future);
    await container.read(timelineControllerProvider.notifier).loadMore();

    final state = container.read(timelineControllerProvider).value!;
    expect(state.groups.map((g) => g.date), ['2026-05-28', '2026-05-27']);
    expect(repo.calls.last['cursor'], 'cursor-1');
  });

  test('loadMore merges adjacent groups with the same date', () async {
    final first = TimelineGroup(date: '2026-05-28', memories: [makeMemory()]);
    final second = TimelineGroup(
      date: '2026-05-28',
      memories: [makeMemory(id: '22222222-2222-4222-8222-222222222222')],
    );
    final repo = FakeTimelineRepository()
      ..pages.add(TimelinePage(groups: [first], nextCursor: 'cursor-1'))
      ..pages.add(TimelinePage(groups: [second], nextCursor: null));
    final container = makeContainer(timeline: repo);

    await container.read(timelineControllerProvider.future);
    await container.read(timelineControllerProvider.notifier).loadMore();

    final state = container.read(timelineControllerProvider).value!;
    expect(state.groups, hasLength(1));
    expect(state.groups.single.memories, hasLength(2));
  });

  test('loadMore is a no-op without a cursor', () async {
    final repo = FakeTimelineRepository()
      ..pages.add(TimelinePage(groups: [], nextCursor: null));
    final container = makeContainer(timeline: repo);

    await container.read(timelineControllerProvider.future);
    await container.read(timelineControllerProvider.notifier).loadMore();

    expect(repo.calls, hasLength(1));
  });

  test('loadMore resets loadingMore and rethrows on repo error', () async {
    final repo = FakeTimelineRepository()
      ..pages.add(TimelinePage(groups: [], nextCursor: 'cursor-1'));
    final container = makeContainer(timeline: repo);

    await container.read(timelineControllerProvider.future);
    repo.error = StateError('boom');

    await expectLater(
      container.read(timelineControllerProvider.notifier).loadMore(),
      throwsStateError,
    );
    expect(
      container.read(timelineControllerProvider).value!.loadingMore,
      false,
    );
  });
}
