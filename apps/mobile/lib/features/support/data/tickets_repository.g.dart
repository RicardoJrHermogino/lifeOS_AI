// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickets_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ticketsRepository)
const ticketsRepositoryProvider = TicketsRepositoryProvider._();

final class TicketsRepositoryProvider
    extends
        $FunctionalProvider<
          TicketsRepository,
          TicketsRepository,
          TicketsRepository
        >
    with $Provider<TicketsRepository> {
  const TicketsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ticketsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ticketsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TicketsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TicketsRepository create(Ref ref) {
    return ticketsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TicketsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TicketsRepository>(value),
    );
  }
}

String _$ticketsRepositoryHash() => r'f0361ce07243f94139968fba6c88e60ae4dc3eee';
