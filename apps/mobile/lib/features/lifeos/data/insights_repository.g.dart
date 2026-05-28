// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(insightsRepository)
const insightsRepositoryProvider = InsightsRepositoryProvider._();

final class InsightsRepositoryProvider
    extends
        $FunctionalProvider<
          InsightsRepository,
          InsightsRepository,
          InsightsRepository
        >
    with $Provider<InsightsRepository> {
  const InsightsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsRepositoryHash();

  @$internal
  @override
  $ProviderElement<InsightsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InsightsRepository create(Ref ref) {
    return insightsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InsightsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InsightsRepository>(value),
    );
  }
}

String _$insightsRepositoryHash() =>
    r'8024b67ef71f8c5f55a7849c2df2fe2c8ed08a66';
