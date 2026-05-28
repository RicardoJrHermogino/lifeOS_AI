// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the offline capture queue: persists locally, syncs to the backend when
/// online, and dedupes via each capture's `syncId` (backend is idempotent).

@ProviderFor(CaptureSyncController)
const captureSyncControllerProvider = CaptureSyncControllerProvider._();

/// Owns the offline capture queue: persists locally, syncs to the backend when
/// online, and dedupes via each capture's `syncId` (backend is idempotent).
final class CaptureSyncControllerProvider
    extends $AsyncNotifierProvider<CaptureSyncController, List<QueuedCapture>> {
  /// Owns the offline capture queue: persists locally, syncs to the backend when
  /// online, and dedupes via each capture's `syncId` (backend is idempotent).
  const CaptureSyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureSyncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureSyncControllerHash();

  @$internal
  @override
  CaptureSyncController create() => CaptureSyncController();
}

String _$captureSyncControllerHash() =>
    r'9442e156e516d00c6ea455860d04fcc39c51dce1';

/// Owns the offline capture queue: persists locally, syncs to the backend when
/// online, and dedupes via each capture's `syncId` (backend is idempotent).

abstract class _$CaptureSyncController
    extends $AsyncNotifier<List<QueuedCapture>> {
  FutureOr<List<QueuedCapture>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<QueuedCapture>>, List<QueuedCapture>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<QueuedCapture>>, List<QueuedCapture>>,
              AsyncValue<List<QueuedCapture>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
