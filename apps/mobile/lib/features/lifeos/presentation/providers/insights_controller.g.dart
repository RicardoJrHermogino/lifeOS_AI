// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads active + saved insights and exposes generate / save / dismiss /
/// feedback actions, refreshing the list after each.

@ProviderFor(InsightsController)
const insightsControllerProvider = InsightsControllerProvider._();

/// Loads active + saved insights and exposes generate / save / dismiss /
/// feedback actions, refreshing the list after each.
final class InsightsControllerProvider
    extends $AsyncNotifierProvider<InsightsController, List<InsightModel>> {
  /// Loads active + saved insights and exposes generate / save / dismiss /
  /// feedback actions, refreshing the list after each.
  const InsightsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsControllerHash();

  @$internal
  @override
  InsightsController create() => InsightsController();
}

String _$insightsControllerHash() =>
    r'85c9b9b32c329ae66da6f74b443b121c95b18e24';

/// Loads active + saved insights and exposes generate / save / dismiss /
/// feedback actions, refreshing the list after each.

abstract class _$InsightsController extends $AsyncNotifier<List<InsightModel>> {
  FutureOr<List<InsightModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<InsightModel>>, List<InsightModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<InsightModel>>, List<InsightModel>>,
              AsyncValue<List<InsightModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
