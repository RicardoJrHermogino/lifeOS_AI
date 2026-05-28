// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current timeline filter. [TimelineController] re-fetches whenever
/// this changes.

@ProviderFor(TimelineFilterController)
const timelineFilterControllerProvider = TimelineFilterControllerProvider._();

/// Holds the current timeline filter. [TimelineController] re-fetches whenever
/// this changes.
final class TimelineFilterControllerProvider
    extends $NotifierProvider<TimelineFilterController, TimelineFilter> {
  /// Holds the current timeline filter. [TimelineController] re-fetches whenever
  /// this changes.
  const TimelineFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineFilterControllerHash();

  @$internal
  @override
  TimelineFilterController create() => TimelineFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimelineFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimelineFilter>(value),
    );
  }
}

String _$timelineFilterControllerHash() =>
    r'97ed37ad076ee3d3fec9cd413c274dc7e02c1a3f';

/// Holds the current timeline filter. [TimelineController] re-fetches whenever
/// this changes.

abstract class _$TimelineFilterController extends $Notifier<TimelineFilter> {
  TimelineFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TimelineFilter, TimelineFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimelineFilter, TimelineFilter>,
              TimelineFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TimelineController)
const timelineControllerProvider = TimelineControllerProvider._();

final class TimelineControllerProvider
    extends $AsyncNotifierProvider<TimelineController, TimelineState> {
  const TimelineControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineControllerHash();

  @$internal
  @override
  TimelineController create() => TimelineController();
}

String _$timelineControllerHash() =>
    r'dfa66aa9f52ebd6fcba73fd0541d5835b3694e00';

abstract class _$TimelineController extends $AsyncNotifier<TimelineState> {
  FutureOr<TimelineState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<TimelineState>, TimelineState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TimelineState>, TimelineState>,
              AsyncValue<TimelineState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
