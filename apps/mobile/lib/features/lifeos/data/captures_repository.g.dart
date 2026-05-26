// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captures_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(capturesRepository)
const capturesRepositoryProvider = CapturesRepositoryProvider._();

final class CapturesRepositoryProvider
    extends
        $FunctionalProvider<
          CapturesRepository,
          CapturesRepository,
          CapturesRepository
        >
    with $Provider<CapturesRepository> {
  const CapturesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'capturesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$capturesRepositoryHash();

  @$internal
  @override
  $ProviderElement<CapturesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CapturesRepository create(Ref ref) {
    return capturesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CapturesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CapturesRepository>(value),
    );
  }
}

String _$capturesRepositoryHash() =>
    r'03a6a186858ba3c521ab67008f5bf62f0680d794';
