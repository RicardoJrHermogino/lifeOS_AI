// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits whether the device currently has a network connection. Defaults to
/// `true` until the first reading resolves so we don't wrongly block requests.

@ProviderFor(isOnline)
const isOnlineProvider = IsOnlineProvider._();

/// Emits whether the device currently has a network connection. Defaults to
/// `true` until the first reading resolves so we don't wrongly block requests.

final class IsOnlineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Emits whether the device currently has a network connection. Defaults to
  /// `true` until the first reading resolves so we don't wrongly block requests.
  const IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isOnline(ref);
  }
}

String _$isOnlineHash() => r'0dd1a7808d73b4394e9d3fa4e7d955571eb2bb8d';
