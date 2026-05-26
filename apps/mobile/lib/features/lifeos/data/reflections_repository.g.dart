// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflections_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reflectionsRepository)
const reflectionsRepositoryProvider = ReflectionsRepositoryProvider._();

final class ReflectionsRepositoryProvider
    extends
        $FunctionalProvider<
          ReflectionsRepository,
          ReflectionsRepository,
          ReflectionsRepository
        >
    with $Provider<ReflectionsRepository> {
  const ReflectionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reflectionsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reflectionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReflectionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReflectionsRepository create(Ref ref) {
    return reflectionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReflectionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReflectionsRepository>(value),
    );
  }
}

String _$reflectionsRepositoryHash() =>
    r'0436ed9690833cfd30972dbeee854da4ef146009';

@ProviderFor(todayReflection)
const todayReflectionProvider = TodayReflectionProvider._();

final class TodayReflectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReflectionModel>,
          ReflectionModel,
          FutureOr<ReflectionModel>
        >
    with $FutureModifier<ReflectionModel>, $FutureProvider<ReflectionModel> {
  const TodayReflectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayReflectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayReflectionHash();

  @$internal
  @override
  $FutureProviderElement<ReflectionModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReflectionModel> create(Ref ref) {
    return todayReflection(ref);
  }
}

String _$todayReflectionHash() => r'fd7407e376f8a048e6ea4ce26a928989688ad069';
