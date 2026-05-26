// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memories_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoriesRepository)
const memoriesRepositoryProvider = MemoriesRepositoryProvider._();

final class MemoriesRepositoryProvider
    extends
        $FunctionalProvider<
          MemoriesRepository,
          MemoriesRepository,
          MemoriesRepository
        >
    with $Provider<MemoriesRepository> {
  const MemoriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoriesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemoriesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemoriesRepository create(Ref ref) {
    return memoriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoriesRepository>(value),
    );
  }
}

String _$memoriesRepositoryHash() =>
    r'318d7d8a27addafaca58dbc002e2d46cfc1b8222';
