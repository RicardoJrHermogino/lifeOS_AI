import 'package:mobile/features/lifeos/data/timeline_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_controller.g.dart';

/// Active timeline filters. All null/empty = unfiltered.
class TimelineFilter {
  const TimelineFilter({this.mood, this.person, this.topic, this.from, this.to});

  final String? mood;
  final String? person;
  final String? topic;
  final String? from; // YYYY-MM-DD
  final String? to; // YYYY-MM-DD

  bool get isEmpty =>
      mood == null &&
      person == null &&
      topic == null &&
      from == null &&
      to == null;

  /// Active filters as (key, label) pairs for chip rendering.
  List<MapEntry<String, String>> get entries => [
    if (mood != null) MapEntry('mood', 'Mood: $mood'),
    if (person != null) MapEntry('person', '@$person'),
    if (topic != null) MapEntry('topic', '#$topic'),
    if (from != null) MapEntry('from', 'From $from'),
    if (to != null) MapEntry('to', 'To $to'),
  ];

  /// Returns a copy with the named filter key cleared.
  TimelineFilter without(String key) {
    return TimelineFilter(
      mood: key == 'mood' ? null : mood,
      person: key == 'person' ? null : person,
      topic: key == 'topic' ? null : topic,
      from: key == 'from' ? null : from,
      to: key == 'to' ? null : to,
    );
  }
}

class TimelineState {
  const TimelineState({
    required this.groups,
    required this.nextCursor,
    this.loadingMore = false,
  });

  final List<TimelineGroup> groups;
  final String? nextCursor;
  final bool loadingMore;

  bool get hasMore => nextCursor != null;

  TimelineState copyWith({
    List<TimelineGroup>? groups,
    String? nextCursor,
    bool? loadingMore,
  }) {
    return TimelineState(
      groups: groups ?? this.groups,
      nextCursor: nextCursor ?? this.nextCursor,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

/// Holds the current timeline filter. [TimelineController] re-fetches whenever
/// this changes.
@riverpod
class TimelineFilterController extends _$TimelineFilterController {
  @override
  TimelineFilter build() => const TimelineFilter();

  void setFilter(TimelineFilter filter) => state = filter;
  void remove(String key) => state = state.without(key);
  void clear() => state = const TimelineFilter();
}

@riverpod
class TimelineController extends _$TimelineController {
  @override
  Future<TimelineState> build() async {
    final f = ref.watch(timelineFilterControllerProvider);
    final page = await ref
        .read(timelineRepositoryProvider)
        .list(
          mood: f.mood,
          person: f.person,
          topic: f.topic,
          from: f.from,
          to: f.to,
        );
    return TimelineState(groups: page.groups, nextCursor: page.nextCursor);
  }

  /// Fetches the next cursor page and appends it, merging same-date groups.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.nextCursor == null || current.loadingMore) {
      return;
    }
    final f = ref.read(timelineFilterControllerProvider);
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await ref
          .read(timelineRepositoryProvider)
          .list(
            mood: f.mood,
            person: f.person,
            topic: f.topic,
            from: f.from,
            to: f.to,
            cursor: current.nextCursor,
          );
      state = AsyncData(
        TimelineState(
          groups: _mergeGroups(current.groups, page.groups),
          nextCursor: page.nextCursor,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
      rethrow;
    }
  }

  static List<TimelineGroup> _mergeGroups(
    List<TimelineGroup> existing,
    List<TimelineGroup> incoming,
  ) {
    if (existing.isEmpty) return incoming;
    if (incoming.isEmpty) return existing;
    final merged = [...existing];
    final last = merged.last;
    final first = incoming.first;
    if (last.date == first.date) {
      merged[merged.length - 1] = TimelineGroup(
        date: last.date,
        memories: [...last.memories, ...first.memories],
      );
      merged.addAll(incoming.skip(1));
    } else {
      merged.addAll(incoming);
    }
    return merged;
  }
}
