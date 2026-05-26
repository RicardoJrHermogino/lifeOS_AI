// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(timelineRepository)
const timelineRepositoryProvider = TimelineRepositoryProvider._();

final class TimelineRepositoryProvider
    extends
        $FunctionalProvider<
          TimelineRepository,
          TimelineRepository,
          TimelineRepository
        >
    with $Provider<TimelineRepository> {
  const TimelineRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineRepositoryHash();

  @$internal
  @override
  $ProviderElement<TimelineRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TimelineRepository create(Ref ref) {
    return timelineRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimelineRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimelineRepository>(value),
    );
  }
}

String _$timelineRepositoryHash() =>
    r'72c74abc34c4f014146add4043c757fee7d25b18';

@ProviderFor(timeline)
const timelineProvider = TimelineProvider._();

final class TimelineProvider
    extends
        $FunctionalProvider<
          AsyncValue<TimelinePage>,
          TimelinePage,
          FutureOr<TimelinePage>
        >
    with $FutureModifier<TimelinePage>, $FutureProvider<TimelinePage> {
  const TimelineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineHash();

  @$internal
  @override
  $FutureProviderElement<TimelinePage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TimelinePage> create(Ref ref) {
    return timeline(ref);
  }
}

String _$timelineHash() => r'd9252866001cdf511c75e11cd554b02bd01b45ab';
