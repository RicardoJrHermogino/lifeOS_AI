// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ask_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(askRepository)
const askRepositoryProvider = AskRepositoryProvider._();

final class AskRepositoryProvider
    extends $FunctionalProvider<AskRepository, AskRepository, AskRepository>
    with $Provider<AskRepository> {
  const AskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'askRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$askRepositoryHash();

  @$internal
  @override
  $ProviderElement<AskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AskRepository create(Ref ref) {
    return askRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AskRepository>(value),
    );
  }
}

String _$askRepositoryHash() => r'486e681a6566604498f06893d54488099fa84ed8';
