// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exports_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exportsRepository)
const exportsRepositoryProvider = ExportsRepositoryProvider._();

final class ExportsRepositoryProvider
    extends
        $FunctionalProvider<
          ExportsRepository,
          ExportsRepository,
          ExportsRepository
        >
    with $Provider<ExportsRepository> {
  const ExportsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExportsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExportsRepository create(Ref ref) {
    return exportsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportsRepository>(value),
    );
  }
}

String _$exportsRepositoryHash() => r'01df9601bf1b62c6d333618c5923bf004c0164c2';
