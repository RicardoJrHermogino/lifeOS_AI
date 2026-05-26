// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captures_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateCapture)
const createCaptureProvider = CreateCaptureProvider._();

final class CreateCaptureProvider
    extends $NotifierProvider<CreateCapture, AsyncValue<CaptureModel?>> {
  const CreateCaptureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCaptureProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCaptureHash();

  @$internal
  @override
  CreateCapture create() => CreateCapture();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CaptureModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CaptureModel?>>(value),
    );
  }
}

String _$createCaptureHash() => r'ec8e3c9a4dac645702211f26cfd281cf3f083a55';

abstract class _$CreateCapture extends $Notifier<AsyncValue<CaptureModel?>> {
  AsyncValue<CaptureModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<CaptureModel?>, AsyncValue<CaptureModel?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CaptureModel?>, AsyncValue<CaptureModel?>>,
              AsyncValue<CaptureModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Polls capture status until done or failed.

@ProviderFor(captureStatus)
const captureStatusProvider = CaptureStatusFamily._();

/// Polls capture status until done or failed.

final class CaptureStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<CaptureModel>,
          CaptureModel,
          Stream<CaptureModel>
        >
    with $FutureModifier<CaptureModel>, $StreamProvider<CaptureModel> {
  /// Polls capture status until done or failed.
  const CaptureStatusProvider._({
    required CaptureStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'captureStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$captureStatusHash();

  @override
  String toString() {
    return r'captureStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<CaptureModel> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CaptureModel> create(Ref ref) {
    final argument = this.argument as String;
    return captureStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CaptureStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$captureStatusHash() => r'332ed235da6cf2779f098d803a56f7406df20add';

/// Polls capture status until done or failed.

final class CaptureStatusFamily extends $Family
    with $FunctionalFamilyOverride<Stream<CaptureModel>, String> {
  const CaptureStatusFamily._()
    : super(
        retry: null,
        name: r'captureStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Polls capture status until done or failed.

  CaptureStatusProvider call(String captureId) =>
      CaptureStatusProvider._(argument: captureId, from: this);

  @override
  String toString() => r'captureStatusProvider';
}
