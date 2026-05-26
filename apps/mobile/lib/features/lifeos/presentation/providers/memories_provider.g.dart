// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoryCandidates)
const memoryCandidatesProvider = MemoryCandidatesProvider._();

final class MemoryCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemoryModel>>,
          List<MemoryModel>,
          FutureOr<List<MemoryModel>>
        >
    with
        $FutureModifier<List<MemoryModel>>,
        $FutureProvider<List<MemoryModel>> {
  const MemoryCandidatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryCandidatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryCandidatesHash();

  @$internal
  @override
  $FutureProviderElement<List<MemoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemoryModel>> create(Ref ref) {
    return memoryCandidates(ref);
  }
}

String _$memoryCandidatesHash() => r'b9d89a565625cd7cd85f03ce2fd258ed2e4787dc';

@ProviderFor(MemoryActions)
const memoryActionsProvider = MemoryActionsProvider._();

final class MemoryActionsProvider
    extends $NotifierProvider<MemoryActions, void> {
  const MemoryActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryActionsHash();

  @$internal
  @override
  MemoryActions create() => MemoryActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$memoryActionsHash() => r'68da81e6c4cf1eea84f780d9cca887bdd4f6ab3d';

abstract class _$MemoryActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
