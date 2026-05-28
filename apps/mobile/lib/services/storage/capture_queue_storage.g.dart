// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_queue_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(captureQueueStorage)
const captureQueueStorageProvider = CaptureQueueStorageProvider._();

final class CaptureQueueStorageProvider
    extends
        $FunctionalProvider<
          CaptureQueueStorage,
          CaptureQueueStorage,
          CaptureQueueStorage
        >
    with $Provider<CaptureQueueStorage> {
  const CaptureQueueStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureQueueStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureQueueStorageHash();

  @$internal
  @override
  $ProviderElement<CaptureQueueStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CaptureQueueStorage create(Ref ref) {
    return captureQueueStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureQueueStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureQueueStorage>(value),
    );
  }
}

String _$captureQueueStorageHash() =>
    r'9c159d072c47d104549bdcf08c57fcfe2ef8ffd9';
