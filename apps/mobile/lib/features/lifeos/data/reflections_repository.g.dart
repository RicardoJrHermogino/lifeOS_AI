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

@ProviderFor(reflectionForDate)
const reflectionForDateProvider = ReflectionForDateFamily._();

final class ReflectionForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReflectionModel>,
          ReflectionModel,
          FutureOr<ReflectionModel>
        >
    with $FutureModifier<ReflectionModel>, $FutureProvider<ReflectionModel> {
  const ReflectionForDateProvider._({
    required ReflectionForDateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'reflectionForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reflectionForDateHash();

  @override
  String toString() {
    return r'reflectionForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReflectionModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReflectionModel> create(Ref ref) {
    final argument = this.argument as String;
    return reflectionForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReflectionForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reflectionForDateHash() => r'e04f7be868afc5aa13cc16c0fec7b8b3a42aca2c';

final class ReflectionForDateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReflectionModel>, String> {
  const ReflectionForDateFamily._()
    : super(
        retry: null,
        name: r'reflectionForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReflectionForDateProvider call(String date) =>
      ReflectionForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'reflectionForDateProvider';
}
